import 'package:flokk/_internal/utils/date_utils.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/data/git_event_data.dart';
import 'package:flokk/data/git_repo_data.dart';
import 'package:flokk/models/abstract_model.dart';
import 'package:flokk/models/contacts_model.dart';
import 'package:github/github.dart';
import 'package:tuple/tuple.dart';

class GithubModel extends AbstractModel {
  final expiry = Duration(days: 30); //the period of which to cull events based on createdAt
  final repoStaleTime = Duration(hours: 72);
  ContactsModel contactsModel;

  //Each event has a repo reference, however not all fields populated in repo object because full set of data not returned in service call. Need separate calls to look up and rely on model to inject as needed
  Map<String, List<GitEvent>> _eventsHash = {};
  Map<String, GitRepo> _reposHash = {};

  GithubModel(this.contactsModel) {
    enableSerialization("github.dat");
  }

  @override
  void scheduleSave() {
    cull();
    super.scheduleSave();
  }

  /// //////////////////////////////////////////////////////////////////
  /// Serialization

  @override
  GithubModel copyFromJson(Map<String, dynamic> json) {
    _eventsHash = (json["_eventsHash"] as Map<String, dynamic>?)?.map((key, value) =>
            MapEntry<String, List<GitEvent>>(key, (value as List?)?.map((x) => GitEvent.fromJson(x)).toList() ?? [])) ??
        {};
    _reposHash = (json["_reposHash"] as Map<String, dynamic>?)
            ?.map((key, value) => MapEntry<String, GitRepo>(key, GitRepo.fromJson(value))) ??
        {};
    return this;
  }

  @override
  Map<String, dynamic> toJson() => {"_eventsHash": _eventsHash, "_reposHash": _reposHash};

  /// //////////////////////////////////////////////////////////////////
  /// Public API
  bool get isLoading => _isLoading;
  bool _isLoading = false;

  set isLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  /////////////////////////////////////////////////////////////////////
  // Repos
  bool repoExists(String repoFullName) => _reposHash.containsKey(repoFullName);

  bool repoIsStale(String repoFullName) =>
      !repoExists(repoFullName) ||
      DateTime.now().difference(_reposHash[repoFullName]?.lastUpdated ?? Dates.epoch) > repoStaleTime;

  //Get all user repos
  List<GitRepo> get allRepos {
    return _reposHash.values.toList();
  }

  void addRepos(List<GitRepo> repos) {
    for (var n in repos) {
      _reposHash[n.repository.fullName] = n;
    }
    notifyListeners();
  }

  void addRepo(GitRepo repo) {
    _reposHash[repo.repository.fullName] = repo;
  }

  //Get repos associated with contact (either it was part of their Event, or else they own it)
  List<GitRepo> getReposByContact(ContactData contact) {
    if (contact.hasGit) {
      List<GitEvent> events = getEventsByContact(contact);

      //Distinct (no duplicates) list of repo names from contact events
      List<String> repoNames = events.map((x) => x.event.repo?.name ?? "").toSet().toList();

      //Get repos either owned by contact or is part of the contact events
      List<GitRepo> repos = _reposHash.values
          .where((x) =>
              //x.owner.login == contact.gitUsername ||
              repoNames.any((e) => e == x.repository.fullName))
          .map((x) => x
            ..contacts = [contact]
            ..latestActivityDate = x.repository.updatedAt ?? Dates.epoch)
          .toList();
      return repos;
    } else {
      return [];
    }
  }

  //Get the most popular repos
  List<GitRepo> get popularRepos {
    List<Tuple2<int, GitRepo>> popular = [];
    for (var n in allRepos) {
      int pts = 0;
      pts += (n.repository.stargazersCount) * 3;
      pts += (n.repository.forksCount) * 2;
      pts += (n.repository.watchersCount) * 1;

      //All events associated with this repo
      List<GitEvent> associatedEvents = _eventsHash.values
          .expand((x) => x) //flatten
          .where((x) => x.event.repo?.name == n.repository.fullName)
          .toList();

      //All contacts associated with this repo
      List<ContactData> associatedContacts = associatedEvents
          .map((x) => x.event.actor?.login)
          .toSet()
          .toList() //get distinct git usernames for each event
          .map((x) => contactsModel.getContactByGit(x ?? "")) //get contact by gitusername
          .where((x) => x != null)
          .cast<ContactData>()
          .toList();

      //Get the latest date from the events associated with this repo or else fall back to repository.updatedAt
      associatedEvents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      DateTime latestActivityDate = (associatedEvents.isNotEmpty && n.repository.updatedAt != null)
          ? associatedEvents.first.createdAt
          : n.repository.updatedAt ?? Dates.epoch;

      if (associatedContacts.isNotEmpty) {
        popular.add(Tuple2<int, GitRepo>(
            pts,
            n
              ..contacts = associatedContacts
              ..latestActivityDate = latestActivityDate));
      }
    }
    popular.sort((a, b) => b.item1.compareTo(a.item1));
    List<GitRepo> repos = popular.map((x) => x.item2).toList();
    return repos;
  }

  /////////////////////////////////////////////////////////////////////
  // Events
  //Get all events sorted by time
  List<GitEvent> get allEvents {
    final sorted = _eventsHash.values.toList().expand((x) => x).toList();
    sorted.sort((a, b) => (b.createdAt).compareTo(a.createdAt));

    //inject the repos data for each event
    for (var n in sorted) {
      n.repository = _reposHash[n.event.repo?.name]?.repository ??
          Repository(
              id: n.event.repo?.id ?? 0, name: n.event.repo?.name ?? "", htmlUrl: n.event.repo?.htmlUrl ?? "");
    }

    return sorted;
  }

  //Get events for single contact
  List<GitEvent> getEventsByContact(ContactData contact) {
    return _eventsHash[contact.gitUsername] ?? [];
  }

  void addEvents(String gitUsername, List<GitEvent> events) {
    final current = DateTime.now();
    _eventsHash[gitUsername] = events.where((x) => (current.difference(x.createdAt)) < expiry).toList();
    notifyListeners();
  }

  void removeEvents(String gitUsername) {
    _eventsHash.remove(gitUsername);
  }

  void cull() {
    //remove old events
    final current = DateTime.now();
    for (List<GitEvent> n in _eventsHash.values) {
      n.removeWhere((x) => current.difference(x.createdAt) >= expiry);
    }
    _eventsHash.removeWhere((key, value) => value.isEmpty);

    //cull unused repos
    final repoKeys = _reposHash.keys.toList();
    for (String n in repoKeys) {
      if (allEvents.any((x) => x.event.repo?.name == n)) {
        continue;
      }
      _reposHash.remove(n);
    }
    notifyListeners();
  }
}
