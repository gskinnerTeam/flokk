import 'package:collection/collection.dart';
import 'package:flokk/_internal/log.dart';
import 'package:flokk/_internal/utils/date_utils.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/data/group_data.dart';
import 'package:flokk/data/social_contact_data.dart';
import 'package:flokk/models/abstract_model.dart';
import 'package:flokk/models/github_model.dart';
import 'package:flokk/models/twitter_model.dart';
import 'package:flokk/services/google_rest/google_rest_service.dart';
import 'package:tuple/tuple.dart';

class ContactsModel extends AbstractModel {
  final gitEventsCooldown = Duration(minutes: 5);
  final tweetsCooldown = Duration(minutes: 1);
  final contactGroupsCooldown = Duration(seconds: 20);

  DateTime lastUpdatedGroups = Dates.epoch;

  ContactsModel() {
    enableSerialization("contacts.dat");
  }

  late TwitterModel twitterModel;
  late GithubModel gitModel;

  //Groups
  List<GroupData> get allGroups => _allGroups;
  List<GroupData> _allGroups = [GroupData()..name = ""];

  set allGroups(List<GroupData> value) {
    _allGroups = value;
    _updateContactsGroups();
    notifyListeners();
  }

  GroupData? getGroupById(String value) => _allGroups.firstWhereOrNull((g) => g.id == value);

  GroupData? getGroupByName(String value) => _allGroups.firstWhereOrNull((g) => g.name == value);

  //Contacts List
  List<ContactData> get activeContacts => allContacts.where((c) => !c.isDeleted).toList();

  List<ContactData> get starred => allContacts.where((c) => c.isStarred).toList();

  List<ContactData> get allContacts => _allContacts;
  List<ContactData> _allContacts = [];

  set allContacts(List<ContactData> value) {
    _allContacts = value;
    _updateSocialContacts();
    notifyListeners();
  }

  ContactData? getContactById(String id) => _allContacts.firstWhereOrNull((c) => c.id == id);

  void addContact(ContactData contact) {
    _allContacts.add(contact);
    _updateSocialContacts();
    notifyListeners();
  }

  void removeContact(ContactData contact) {
    _allContacts.removeWhere((c) => c.id == contact.id);
    _updateSocialContacts();
    notifyListeners();
  }

  void swapContactById(ContactData newContact) {
    final ContactData? oldContact = getContactById(newContact.id);
    if (oldContact != null) {
      //[SB] Keep isStarred in sync when we swap contents since this is injected by the [updateContactsWithGroupData] fxn.
      newContact.isStarred = oldContact.isStarred;
      newContact.groupList = oldContact.groupList;
      _allContacts[_allContacts.indexOf(oldContact)] = newContact;
      notifyListeners();
    }
  }

  void swapGroupById(GroupData newGroup) {
    for (var i = _allGroups.length; i-- > 0;) {
      if (_allGroups[i].id != newGroup.id) continue;
      _allGroups[i] = newGroup;
      notifyListeners();
      break;
    }
  }

  //Social contacts
  List<SocialContactData> _allSocialContacts = [];

  List<SocialContactData> get allSocialContacts {
    _updateSocialContacts();
    return _allSocialContacts;
  }

  void touchSocialById(String id) {
    SocialContactData? social = getSocialById(id);
    if (social != null) {
      social.lastCheckedTweets = DateTime.now();
      social.lastCheckedGit = DateTime.now();
      notifyListeners();
      scheduleSave();
    }
  }

  void clearGitCooldown(ContactData contact) {
    getSocialById(contact.id)?.lastUpdatedGit = Dates.epoch;
    getSocialById(contact.id)?.lastCheckedGit = Dates.epoch;
  }

  void clearTwitterCooldown(ContactData contact) {
    getSocialById(contact.id)?.lastUpdatedTwitter = Dates.epoch;
    getSocialById(contact.id)?.lastCheckedTweets = Dates.epoch;
  }

  bool canRefreshGitEventsFor(String gitUsername) {
    final socialContactData = getSocialContactByGit(gitUsername);
    if (socialContactData == null)
      return false;
    DateTime lastUpdate = socialContactData.lastUpdatedGit;
    return DateTime.now().difference(lastUpdate) > gitEventsCooldown;
  }

  bool canRefreshTweetsFor(String twitterHandle) {
    final socialContactData = getSocialContactByTwitter(twitterHandle);
    if (socialContactData == null)
      return false;
    DateTime lastUpdate = socialContactData.lastUpdatedTwitter;
    return DateTime.now().difference(lastUpdate) > tweetsCooldown;
  }

  bool get canRefreshContactGroups => DateTime.now().difference(lastUpdatedGroups) > contactGroupsCooldown;

  //Updates the timestamps when social feeds are refreshed for contact
  void updateSocialTimestamps({String twitterHandle = "", String gitUsername = ""}) {
    if (twitterHandle.isNotEmpty) {
      getSocialContactByTwitter(twitterHandle)?.lastUpdatedTwitter = DateTime.now();
    }
    if (gitUsername.isNotEmpty) {
      getSocialContactByGit(gitUsername)?.lastUpdatedGit = DateTime.now();
    }
  }

  void updateContactDataGithubValidity(String gitUsername, bool isValid) {
    allContacts.firstWhereOrNull((x) => x.gitUsername == gitUsername)?.hasValidGit = isValid;
  }

  void updateContactDataTwitterValidity(String twitterHandle, bool isValid) {
    allContacts.firstWhereOrNull((x) => x.twitterHandle == twitterHandle)?.hasValidTwitter = isValid;
  }

  ContactData? getContactByGit(String gitUsername) =>
      allContacts.firstWhereOrNull((x) => x.gitUsername == gitUsername);

  ContactData? getContactByTwitter(String twitterHandle) =>
      allContacts.firstWhereOrNull((x) => x.twitterHandle == twitterHandle);

  SocialContactData? getSocialContactByGit(String gitUsername) =>
      getSocialById(getContactByGit(gitUsername)?.id ?? "");

  SocialContactData? getSocialContactByTwitter(String twitterHandle) =>
      getSocialById(getContactByTwitter(twitterHandle)?.id ?? "");

  //Get a list of contacts with the most activity (based on their calculated "points" for each social activity)
  List<SocialContactData> get mostActiveSocialContacts =>
      allSocialContacts..sort((a, b) => b.points.compareTo(a.points));

  //Get a list of contacts with the most recent activity
  List<SocialContactData> get mostRecentSocialContacts =>
      allSocialContacts..sort((a, b) => (b.latestActivity.createdAt).compareTo(a.latestActivity.createdAt));

  SocialContactData? getSocialById(String id) {
    if (id.isEmpty) return null;
    return allSocialContacts.firstWhereOrNull((c) => c.contactId == id);
  }

  //Get a list of contacts with upcoming dates (repeated contacts are expected if they have multiple events that are upcoming)
  List<Tuple2<ContactData, DateMixin>> get upcomingDateContacts {
    //List of all dates (birthday and events) with their contact id
    List<Tuple2<String, DateMixin>> flattenedDates = allContacts
        .map((contact) => contact.allDates.map((x) => Tuple2<String, DateMixin>(contact.id, x)).toList())
        .toList()
        .expand((element) => element)
        .where((element) => element.item2.daysTilAnniversary < 90) //limit to upcoming dates for next 3 months
        .toList();

    //Sort by the closest upcoming dates
    flattenedDates.sort((a, b) => a.item2.daysTilAnniversary.compareTo(b.item2.daysTilAnniversary));

    List<Tuple2<ContactData, DateMixin>> contactsWithDates = [];
    for (var n in flattenedDates) {
      contactsWithDates.add(Tuple2<ContactData, DateMixin>(getContactById(n.item1)!, n.item2));
    }
    return contactsWithDates;
  }

  void _updateContactsGroups() {
    if (_allContacts.isEmpty) return;

    /// Clear all known existing groups
    _allContacts..forEach((c) => c.groupList = []);

    /// Set the labels for each contact (groupList)
    for (GroupData g in _allGroups) {
      if (g.groupType == GroupType.UserContactGroup) {
        for (String id in g.members) {
          final ContactData? contact = getContactById(id);
          if (contact != null) {
            contact.groupList.add(g);
            // print("name: ${contact.nameFull} labels: ${contact.groupList.join(',')}");
          }
        }
      }
      //Set the isStarred property for each ContactData who is member of Starred contact group
      if (g.id == GoogleRestService.kStarredGroupId) {
        for (ContactData c in _allContacts) {
          c.isStarred = g.members.contains(c.id);
        }
      }
    }
  }

  void _updateSocialContacts() {
    //clean up any social contacts that are NOT found in all contacts
    _allSocialContacts.removeWhere((x) => !_allContacts.any((c) => c.id == x.contactId));

    //create social contact if needed, otherwise just update tweets/events
    for (var n in _allContacts) {
      if (n.hasAnySocial) {
        if (!_allSocialContacts.any((x) => x.contactId == n.id)) {
          _allSocialContacts.add(SocialContactData()
            ..contactId = n.id
            ..contact = n
            ..gitEvents = gitModel.getEventsByContact(n)
            ..tweets = twitterModel.getTweetsByContact(n));
        } else {
          SocialContactData socialContact = _allSocialContacts.firstWhere((x) => x.contactId == n.id);
          socialContact.contact = n;
          socialContact.gitEvents = gitModel.getEventsByContact(n);
          socialContact.tweets = twitterModel.getTweetsByContact(n);
        }
      }
    }
  }

  @override
  void reset([bool notify = true]) {
    Log.p("[ContactsModel] Reset");
    copyFromJson({});
    super.reset(notify);
  }

  /////////////////////////////////////////////////////////////////////
  // Define serialization methods

  //Json Serialization
  @override
  ContactsModel copyFromJson(Map<String, dynamic> value) {
    _allContacts = toList(value['_allContacts'], (j) => ContactData.fromJson(j));
    _allGroups = toList(value['_allGroups'], (j) => GroupData.fromJson(j));
    _allSocialContacts = toList(value['_allSocialContacts'], (j) => SocialContactData.fromJson(j));
    _updateSocialContacts();
    return this;
  }

  @override
  Map<String, dynamic> toJson() {
    return {'_allContacts': _allContacts, '_allGroups': _allGroups, '_allSocialContacts': _allSocialContacts};
  }
}
