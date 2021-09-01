import 'package:flokk/_internal/components/simple_value_notifier.dart';
import 'package:flokk/_internal/utils/string_utils.dart';
import 'package:flokk/_internal/utils/utils.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/data/group_data.dart';

class SearchEngine extends SimpleNotifier {
  bool _isDirty = false;
  List<ContactData> _cachedResults = [];
  List<String> _tagCache = [];

  get hasQuery =>
      query.isNotEmpty || tags.isNotEmpty || filterContacts.isNotEmpty;

  SearchEngine copy() => SearchEngine()..copyFrom(this);

  void copyFrom(SearchEngine se) {
    _query = se.query;
    _tags = se.tags;
    _filterContacts = se.filterContacts;
    _orderDesc = se.orderDesc;
    _contactsList = se.contactsList;
    _groupsList = se.groupsList;
    _orderBy = se._orderBy;
    _isDirty = true;
    notifyListeners();
  }

  /// ////////////////////////////////////////////
  /// QUERY STRING
  String get query => _query;

  set query(String query) => setAndMarkDirty(() => _query = query);
  String _query = "";

  /// ////////////////////////////////////////////
  /// Filter tags
  String get tags => _tags;

  set tags(String tags) => setAndMarkDirty(() => _tags = tags);

  List<String> get tagList =>
      tags.split(",").where((e) => e.isNotEmpty).toList();

  void addTag(String tag) {
    final tl = tagList;
    if (!tl.contains(tag)) {
      tl.add(tag);
      tags = tl.join(",");
    }
  }

  void removeTag(String tag) {
    final tl = tagList;
    if (tl.remove(tag)) {
      tags = tl.join(",");
    }
  }

  void clearTags() => tags = "";

  /// _tags is a comma separated list of tags
  String _tags = "";

  /// ////////////////////////////////////////////
  /// Filter contacts
  String get filterContacts => _filterContacts;

  set filterContacts(String filterContacts) =>
      setAndMarkDirty(() => _filterContacts = filterContacts);

  List<String> get filterContactList =>
      filterContacts.split(",").where((e) => e.isNotEmpty).toList();

  void addFilterContact(String filterContact) {
    final fcl = filterContactList;
    if (!fcl.contains(filterContact)) {
      fcl.add(filterContact);
      filterContacts = fcl.join(",");
    }
  }

  void removeFilterContact(String filterContact) {
    final fcl = filterContactList;
    if (fcl.remove(filterContact)) {
      filterContacts = fcl.join(",");
    }
  }

  void clearFilterContacts() => filterContacts = "";

  String _filterContacts = "";

  /// ////////////////////////////////////////////
  /// ORDER BY
  ContactOrderBy get orderBy => _orderBy;

  set orderBy(ContactOrderBy orderBy) =>
      setAndMarkDirty(() => _orderBy = orderBy);
  ContactOrderBy _orderBy = ContactOrderBy.FirstName;

  /// ////////////////////////////////////////////
  /// ORDER DESCENDING
  bool get orderDesc => _orderDesc;

  set orderDesc(bool value) => setAndMarkDirty(() => _orderDesc = value);
  bool _orderDesc = false;

  /// ////////////////////////////////////////////
  /// DATA SOURCE
  List<ContactData> get contactsList => _contactsList;

  set contactsList(List<ContactData> value) =>
      setAndMarkDirty(() => _contactsList = value);
  List<ContactData> _contactsList = [];

  List<GroupData> get groupsList => _groupsList;

  set groupsList(List<GroupData> value) =>
      setAndMarkDirty(() => _groupsList = value);
  List<GroupData> _groupsList = [];

  List<ContactData> getResults(
      [List<ContactData>? newContacts,
      ContactOrderBy _orderBy = ContactOrderBy.FirstName]) {
    if (newContacts != null) contactsList = newContacts;
    orderBy = _orderBy;
    // If we have no data
    if (_contactsList.isEmpty) return [];
    _updateCache();
    return _cachedResults;
  }

  List<String> getTagResults() {
    if (query.isEmpty) return <String>[];
    _updateCache();
    return _tagCache;
  }

  List<String> _buildGroups() {
    return _groupsList.map((g) => g.name).toList();
  }

  void _updateCache() {
    if (!_isDirty) return;

    Utils.benchmark("Search - Sorted and Filtered", () {
      List<ContactData> results = List.from(_contactsList);
      List<String> groups = _buildGroups();
      {
        final lowerQuery =
            !StringUtils.isEmpty(_query) ? _query.toLowerCase() : "";
        if (hasQuery) {
          results.retainWhere((c) {
            bool matchsGroups = false;
            for (var g in tagList) {
              if (c.searchable.contains(g.toLowerCase())) {
                matchsGroups = true;
                break;
              }
            }
            bool matchsContact = false;
            for (var g in filterContactList) {
              if (c.searchable.contains(g.toLowerCase())) {
                matchsContact = true;
                break;
              }
            }
            bool queryNotEmpty = lowerQuery.isNotEmpty;
            //bool hasTags = tagList.isNotEmpty || filterContactList.isNotEmpty;
            bool matchsTags = matchsGroups || matchsContact;
            return (queryNotEmpty && c.searchable.contains(lowerQuery)) ||
                matchsTags;
          });
        }
        groups.retainWhere((g) {
          return g.toLowerCase().contains(lowerQuery) && !tags.contains(g);
        });
      }
      if (orderBy == ContactOrderBy.FirstName) {
        results.sort(
            (a, b) => _nullSafeSort(a.nameGiven, b.nameGiven, _orderDesc));
      } else if (orderBy == ContactOrderBy.LastName) {
        results.sort(
            (a, b) => _nullSafeSort(a.nameFamily, b.nameFamily, _orderDesc));
      }
      _cachedResults = results;
      _tagCache = groups;
      _isDirty = false;
    });
  }

  int _nullSafeSort(String a, String b, bool orderDesc) {
    return a.compareTo(b) * (orderDesc ? -1 : 1);
  }

  void setAndMarkDirty(Function() setter) {
    setter();
    _isDirty = true;
    notifyListeners();
  }
}
