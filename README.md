# Flokk
A fresh and modern Google Contacts manager that integrates with GitHub and Twitter.

## Demo Builds
- Web: https://flokk.app
- Linux: https://snapcraft.io/flokk-contacts
- macOS: https://flokk.app/macos/Flokk_Contacts_v1.0.1.dmg
- Windows: https://flokk.app/windows/flokk-v1.0.1-signed.zip
  
## Contributing

You are invited to improve Flokk Contacts! Submitting pull requests, answering and asking questions in the [Issues](https://github.com/gskinnerTeam/flokk/issues) page, and updating documentation are all ways you can contribute to the app.

Please note that although we are monitoring GitHub issues, we aren't actively maintaining the codebase, so community involvement and contributions are really appreciated going forward. We're aiming to review pull requests on a weekly basis.

## Getting Set Up

### 1. Flutter

- Follow the install instructions here: https://flutter.dev/docs/get-started/install
  - Desktop-specific info: https://flutter.dev/desktop, https://github.com/flutter/flutter/wiki/Desktop-shells
- Flokk was built on the bleeding edge of Flutter, so make sure to use the `master` branch in their git repo and checkout commit `9c3f0faa6d` for Web, Linux, and macOS builds, or `78929661fb` for Windows builds.
  - We're aiming to upgrade to an official Flutter version soon to make this easier.

### 2. Add Required API Keys

Google Sign In is required in order to run the app (unless running with [cached data](#running-with-cached-data)). The app uses the Google People API, and you will need to provide your own Google OAuth 2 client credentials in the `/lib/api_keys.dart` file. 

Follow the instructions here to enable the People API and create credentials:
- https://developers.google.com/people/v1/getting-started
- https://developers.google.com/people/v1/how-tos/authorizing
In your Google API Console, ensure you add the People API scope, "https://www.googleapis.com/auth/contacts". Please see below for details:
- https://developers.google.com/identity/protocols/oauth2/scopes#people

To optionally fetch social data for your contacts, add your own API keys for those as well:
- Twitter: https://developer.twitter.com/en/docs/basics/getting-started
- GitHub: https://developer.github.com/v3/guides/basics-of-authentication/

Although the Twitter and GitHub keys are optional, they are recommended. Otherwise the app will not be able to fetch tweets and GitHub calls will be subject to a rate limit (https://developer.github.com/v3/#rate-limiting).

### Web Builds
If you're building for web:
- Edit `/web/index.html` to include your web credentials (web client Id) `<meta name="google-signin-client_id" content="YOUR_GOOGLE_SIGN_IN_OAUTH_CLIENT_ID.apps.googleusercontent.com">`.
- This is needed for Google Sign In to work on web builds. For more details, see https://pub.dev/packages/google_sign_in_web

#### CORS Proxy
For Twitter support to work on web builds, it is necessary to use a CORS proxy. You can set up a proxy on your own domain, or else run a localhost instance with `proxy/app.js`.

If setting up on your domain, ensure you have enabled https (https://letsencrypt.org/). Once you have the security certificate, edit `proxy/app.js` and insert your cert and key. This is not necessary if running a localhost instance.

After the proxy is set up, edit `services/twitter_rest_service.dart` to point to your running proxy instance (e.g. "https://my-proxy.com", "http://localhost", etc.)

For more information, see https://github.com/Rob--W/cors-anywhere

## Running With Cached Data
If you simply want to see the app running, it is possible to run the app using cached data:
- Run the app at least once, to create your data folders
- Extract the _contents_ of /sample_data.zip to the newly created data folder on your machine:
  - Windows: \Users\\[USER]\AppData\Roaming\flokk
  - Linux: $HOME/.local/share/flokk-contacts
  - macOS: /Users/[USER]/Library/Containers/app.flokk/Data/Library/Application Support/app.flokk
- Overwrite any files that are there
- Launch the app again, it should now sign in, and load with existing data.
- If you sign out, your saved data will be wiped and you will need to repeat the process.

Note: This is meant as a 'read-only' mode so you can quickly explore all the widgets and features of the app. Updates, deletes, etc are not expected to work.

## Test & Build
Debug Builds
- Use `flutter run -d DEVICE_ID`  to deploy a test build
- To get a list of available DEVICE_ID, use `flutter run`
- Typical values are: `windows`, `linux`, `macos`, `chrome`
- Add `--release` to deploy an optimized build

Release Builds
- Use `flutter build PACKAGE_TYPE` to build a release package
- To get a list of available PACKAGE_TYPE, use `flutter build`
- Typical values are `windows`, `linux`, `apk`, `ios`
- In order to build the snap package one must first run `lxd init` on your system if you haven't already.
   ** Then execute `snapcraft --use-lxd` to create the snap from the flutter build

Force Log In
- The app uses a `kForceWebLogin` flag to force release builds to skip the oauth screen.
- Add `--dart-define=flokk.forceWebLogin=true` to your build command to enable
- E.g. `flutter build web --dart-define=flokk.forceWebLogin=true`

## Desktop Runners
The /linux and /windows folders contain modifications and should not be upgraded to upstream without first verifying that each plugin works correctly with the new upstream code and any modifications are made.

Since the desktop runners for this project may contain modifications, upgrades should not be made without first verifying that every plugin and embedder can be upgraded and that they remain compatible after an upgrade. Hopefully this will not be as much of an issue once Flutter's desktop support becomes more mature.

--

Happy Flokking!
