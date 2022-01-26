import 'package:flokk/data/contact_data.dart';
import 'package:flokk/models/abstract_model.dart';
import 'package:flokk/models/contacts_model.dart';
import 'package:flokk/themes.dart';
import 'package:flokk/views/main_scaffold/main_scaffold.dart';
import 'package:flokk/views/search/search_engine.dart';

enum DashboardContactsSectionType { Favorites, RecentlyActive }

enum DashboardSocialSectionType { All, Git, Twitter }

/// //////////////////////////////////////////////////////
/// APP MODEL - Holds global state/settings for various app components and views.
/// A mix of different values: Current theme, app version, settings, online status, selected sections etc.
/// Some of the values are serialized in app.settings file
class AppModel extends AbstractModel {
  static const kCurrentVersion = "1.1.0";

  static bool forceIgnoreGoogleApiCalls = false;

  static bool get enableShadowsOnWeb => true;

  static bool get enableAnimationsOnWeb => true;

  /// Toggle fpsMeter
  static bool get showFps => false;

  /// Toggle Sketch Design Grid
  static bool get showDesignGrid => false;

  /// Ignore limiting cooldown periods (tweets, git events, git repos, groups), always fetch for each request
  static bool get ignoreCooldowns => false;

  ContactsModel contactsModel;

  AppModel(this.contactsModel) {
    enableSerialization("app.settings");
    contactsModel.addListener(_handleContactsChanged);
  }

  void _handleContactsChanged() {
    /// Update search engine with latest results
    searchEngine.contactsList = contactsModel.allContacts;
    searchEngine.groupsList = contactsModel.allGroups;

    /// Watch selected contact and keep it updated when contacts model changes
    if (selectedContact != null) {
      selectedContact = contactsModel.getContactById(selectedContact!.id);
    }
  }

  /// //////////////////////////////////////////////////
  /// Version Info (serialized)
  String version = "0.0.0";

  void upgradeToVersion(String value) {
    // Any version specific upgrade checks can go here
    version = value;
    scheduleSave();
  }

  /// /////////////////////////////////////////////////
  /// Current dashboard sections (serialized)
  DashboardContactsSectionType get dashContactsSection => _dashContactsSection;
  DashboardContactsSectionType _dashContactsSection = DashboardContactsSectionType.Favorites;

  set dashContactsSection(DashboardContactsSectionType value) {
    _dashContactsSection = value;
    notifyListeners();
  }

  DashboardSocialSectionType get dashSocialSection => _dashSocialSection;
  DashboardSocialSectionType _dashSocialSection = DashboardSocialSectionType.All;

  set dashSocialSection(DashboardSocialSectionType value) {
    _dashSocialSection = value;
    notifyListeners();
  }

  /// //////////////////////////////////////////////////
  /// Selected edit target, controls visibility of the edit panel and selected rows in the various views
  ContactData? get selectedContact => _selectedContact;
  ContactData? _selectedContact;

  void touchSelectedSocial() {
    final sc = selectedContact;
    if (sc != null) {
      contactsModel.touchSocialById(sc.id);
    }
  }

  /// Current selected edit target, controls visibility of the edit panel
  set selectedContact(ContactData? value) {
    _selectedContact = value;
    notifyListeners();
  }

  bool get showSocialTabOnInfoView => _showSocialTabOnInfoView;
  bool _showSocialTabOnInfoView = false;

  set showSocialTabOnInfoView(bool value) {
    _showSocialTabOnInfoView = value;
    if (_showSocialTabOnInfoView) {
      touchSelectedSocial();
    }
    notifyListeners();
  }

  /// //////////////////////////////////////////////////
  /// Global search settings, this is a changeNotifier itself, views can bind directly to it if they need.
  SearchEngine searchEngine = SearchEngine();

  /// //////////////////////////////////////////////////
  /// Holds current page type, synchronizes leftMenu with the mainContent
  PageType get currentMainPage => _currentMainPage;
  PageType _currentMainPage = PageType.Dashboard;

  set currentMainPage(PageType value) {
    _currentMainPage = value;
    notifyListeners();
  }

  /// //////////////////////////////////////////
  /// Current connection status
  bool get isOnline => _isOnline;
  bool _isOnline = true;

  set isOnline(bool value) {
    _isOnline = value;
    notifyListeners();
  }

  /// //////////////////////////////////////////
  /// Current Theme (serialized)
  ThemeType get theme => _theme;
  ThemeType _theme = ThemeType.FlockGreen;

  set theme(ThemeType value) {
    _theme = value;
    scheduleSave();
    notifyListeners();
  }

  @override
  void copyFromJson(Map<String, dynamic> json) {
    var v = ThemeType.values;
    int theme = json["_theme"] ?? 0;
    _theme = v[theme.clamp(0, v.length)];
    _dashContactsSection = DashboardContactsSectionType.values[json['_dashContactsSection'] ?? 0];
    _dashSocialSection = DashboardSocialSectionType.values[json['_dashSocialSection'] ?? 0];
    version = json['version'] ?? "0.0.0";
  }

  @override
  Map<String, dynamic> toJson() => {
        "_theme": _theme.index,
        'version': version,
        '_dashContactsSection': _dashContactsSection.index,
        '_dashSocialSection': _dashSocialSection.index
      };

  /// [SB] Just for easy testing, remove later
  void nextTheme() {
    theme = (theme == ThemeType.FlockGreen_Dark) ? ThemeType.FlockGreen : ThemeType.FlockGreen_Dark;
  }
}
