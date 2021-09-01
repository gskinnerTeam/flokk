import 'package:flokk/_internal/components/no_glow_scroll_behavior.dart';
import 'package:flokk/_internal/page_routes.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/commands/bootstrap_command.dart';
import 'package:flokk/commands/check_connection_command.dart';
import 'package:flokk/commands/social/poll_social_command.dart';
import 'package:flokk/globals.dart';
import 'package:flokk/models/app_model.dart';
import 'package:flokk/models/auth_model.dart';
import 'package:flokk/models/contacts_model.dart';
import 'package:flokk/models/github_model.dart';
import 'package:flokk/models/twitter_model.dart';
import 'package:flokk/services/github_rest_service.dart';
import 'package:flokk/services/google_rest/google_rest_service.dart';
import 'package:flokk/services/twitter_rest_service.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flokk/views/welcome/welcome_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_platform/universal_platform.dart';

//Developer hook to force login while testing locally (sidesteps Oauth flow)
const bool kForceWebLogin =
    bool.fromEnvironment('flokk.forceWebLogin', defaultValue: false);

bool tryAndLoadDevSpike(BuildContext c) {
  Widget? spike;

  /// Load spike if we have one
  if (spike != null)
    AppGlobals.nav?.pushReplacement(PageRoutes.fade(() => spike));
  return spike != null;
}

void main() {
  /// Need to add this in order to run on Desktop. See https://github.com/flutter/flutter/wiki/Desktop-shells#target-platform-override
  if (UniversalPlatform.isWindows ||
      UniversalPlatform.isLinux ||
      UniversalPlatform.isMacOS) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }

  /// Initialize models, negotiate dependencies
  var contactsModel = ContactsModel();
  var twitterModel = TwitterModel(contactsModel);
  var githubModel = GithubModel(contactsModel);
  var appModel = AppModel(contactsModel);
  contactsModel.twitterModel = twitterModel;
  contactsModel.gitModel = githubModel;

  /// Run MainApp, and provide all Models and Services
  runApp(
    MultiProvider(
      providers: [
        /// MODELS
        ChangeNotifierProvider.value(value: appModel),
        ChangeNotifierProvider.value(value: contactsModel),
        ChangeNotifierProvider.value(value: twitterModel),
        ChangeNotifierProvider.value(value: githubModel),
        ChangeNotifierProvider(create: (c) => AuthModel()),

        /// SERVICES
        Provider(create: (_) => GoogleRestService()),
        Provider(create: (_) => GithubRestService()),
        Provider(create: (_) => TwitterRestService()),

        /// ROOT CONTEXT, Allows Commands to retrieve a 'safe' context that is not tied to any one view. Allows them to work on async tasks without issues.
        Provider<BuildContext>(create: (c) => c),
      ],
      child: MainApp(),
      //child: SpikeApp(ImageTintSpike()),
    ),
  );
}

/// MainApp
/// * Binds to AppModel.theme, and injects current AppTheme to the rest of the App
/// * Runs the BootStrapperCommand
/// * Wraps a MaterialApp, assigning it a navKey so the Commands can access the root level navigator
class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final GlobalKey<WelcomePageState> _welcomePageKey = GlobalKey();
  late CheckConnectionCommand _connectionChecker;
  late PollSocialCommand _pollSocialCommand;
  bool _settingsLoaded = false;

  @override
  void initState() {
    /// Load appModel first, to fetch the appTheme ASAP
    context.read<AppModel>().load().then((value) async {
      /// Rebuild now that we have our loaded settings
      setState(() => _settingsLoaded = true);

      /// ///////////////////////////////////////////////
      /// Continous Background Services
      // Connection checker, will run continuously until cancelled
      _connectionChecker = CheckConnectionCommand(context)..execute(true);

      // Polling for social feeds, will run continuously until cancelled
      _pollSocialCommand = PollSocialCommand(context)..execute(true);

      /// ///////////////////////////////////////////////
      /// Bootstrap app
      /// When bootstrap is complete, we know whether to sign in, or not
      bool isSignedIn = await BootstrapCommand(context).execute();
      // First, allow dev-spike to take precedence over normal startup flow
      if (tryAndLoadDevSpike(context)) return;
      // Use welcome-page to complete remaining sign-in flow
      WelcomePageState? welcomePage = _welcomePageKey.currentState;
      if (isSignedIn == true) {
        // Login into the main app
        welcomePage?.refreshDataAndLoadApp();
      } else {
        // Show login panel so user can sign-in
        welcomePage?.showPanel(true);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _connectionChecker.cancel();
    _pollSocialCommand.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// If we've not loaded settings,
    if (!_settingsLoaded) return Container(color: Colors.white);

    // TODO: Use platform brightness to determine default theme. // MediaQuery.of(context).platformBrightness;
    /// Bind to AppModel.theme and get current theme
    ThemeType themeType =
        context.select<AppModel, ThemeType>((value) => value.theme);
    AppTheme theme = AppTheme.fromType(themeType);

    /// Disable shadows on web builds for better performance
    if (UniversalPlatform.isWeb && !AppModel.enableShadowsOnWeb) {
      Shadows.enabled = false;
    }

    /// ///////////////////////////////////////////////
    /// Main application
    return Provider.value(
      value: theme, // Provide the current theme to the entire app
      child: MaterialApp(
        title: "Flokk Contacts",
        debugShowCheckedModeBanner: false,
        navigatorKey: AppGlobals.rootNavKey,

        /// Pass active theme into MaterialApp
        theme: theme.themeData,

        /// Home defaults to SplashView, BootstrapCommand will load the initial page
        home: WelcomePage(key: _welcomePageKey),

        /// Wrap root navigator in various styling widgets
        builder: (_, navigator) {
          if (navigator == null) return Container();
          // Wrap root page in a builder, so we can make initial responsive tweaks based on MediaQuery
          return Builder(builder: (c) {
            //Responsive: Reduce size of our gutter scale when we're below a certain size
            Insets.gutterScale = c.widthPx < PageBreaks.TabletPortrait ? .5 : 1;
            // Disable all Material glow effects with [ NoGlowScrollBehavior ]
            return ScrollConfiguration(
              behavior: NoGlowScrollBehavior(),
              child: navigator,
            );
          });
        },
      ),
    );
  }
}
