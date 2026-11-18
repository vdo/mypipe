<div align="center">

<img src="android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" width="112" alt="MyPipe logo">

# MyPipe

**Your YouTube feeds, signed in. Every video opens in [NewPipe](https://newpipe.net).**

[![CI](https://github.com/vdo/mypipe/actions/workflows/ci.yml/badge.svg)](https://github.com/vdo/mypipe/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/vdo/mypipe?sort=semver)](https://github.com/vdo/mypipe/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/vdo/mypipe/total)](https://github.com/vdo/mypipe/releases)
[![License: MIT](https://img.shields.io/github/license/vdo/mypipe)](LICENSE)
![Android](https://img.shields.io/badge/Android-3DDC84?logo=android&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)

</div>

---

NewPipe is a great YouTube player, but it can't sign in to your account, so there's no Home feed, no
subscriptions synced from YouTube, no Watch Later. MyPipe fills that gap: it shows the mobile YouTube
site signed in as you, and hands every video you tap to NewPipe.

## Features

- **Signed-in feeds**: Home, Shorts, Subscriptions, Watch Later, History, playlists. Everything the mobile site has.
- **Plays in NewPipe**: tapping a video or Short opens it in NewPipe instead of playing it.
- **No feed ads**: promoted videos, ad slots, and Premium banners are hidden.
- **Tiny**: one Dart file, one WebView, no tracking, no server.

<!-- Screenshots: add docs/screenshots/home.png and subscriptions.png, then uncomment.
<p align="center">
  <img src="docs/screenshots/home.png" width="260" alt="Home feed">
  <img src="docs/screenshots/subscriptions.png" width="260" alt="Subscriptions">
</p>
-->

## Install

1. Install [NewPipe](https://newpipe.net) if you haven't.
2. Download the APK from the [latest release](https://github.com/vdo/mypipe/releases/latest):
   - `mypipe-*-arm64-v8a.apk` for almost every modern phone
   - `mypipe-*-universal.apk` if you're unsure
3. Open MyPipe, tap ⚙ → **Sign in**.

You can also use [Obtainium](https://github.com/ImranR98/Obtainium) to get updates: add `https://github.com/vdo/mypipe`.

## How it works

MyPipe is a WebView showing `m.youtube.com`. A small injected script:

- intercepts taps on `/watch` and `/shorts/` links and sends them to NewPipe through an Android intent (falling back to an app chooser if NewPipe isn't installed);
- adds a stylesheet that hides ad elements.

Your sign-in lives only in the app's WebView cookies on your device. MyPipe has no server and collects nothing.

The ⚙ menu has: Sign in, Watch later, History, YouTube settings, Sign out, Reload.

## Build from source

Requires Flutter (stable) and the Android SDK.

```sh
flutter pub get
flutter run               # on a connected device
flutter build apk --release
```

Release builds are signed with the key described in `android/key.properties` (git-ignored) and fall back to
debug keys when it's missing:

```properties
storeFile=/absolute/path/to/release.jks
storePassword=...
keyAlias=mypipe
keyPassword=...
```

## Releasing

Push a semver tag (`vMAJOR.MINOR.PATCH`, optionally `-rc.1` etc.). The [Release workflow](.github/workflows/release.yml) builds universal and per-ABI
APKs, writes `SHA256SUMS`, and publishes a GitHub release with generated notes.

```sh
git tag v1.0.0 && git push origin v1.0.0
```

To sign releases with your key, add these repository secrets (Settings → Secrets and variables → Actions):

| Secret | Value |
| --- | --- |
| `KEYSTORE_BASE64` | `base64 -i release.jks` |
| `KEYSTORE_PASSWORD` | keystore password (also used as the key password) |
| `KEY_ALIAS` | key alias, e.g. `mypipe` |

Without them, releases are signed with a throwaway debug key, and users can't update from one release to the next.

## Troubleshooting

- **Ads showing again**: YouTube renamed something. Update the selector list in [`lib/main.dart`](lib/main.dart). PRs welcome.
- **Google says the browser isn't secure**: the app sends a regular Chrome user agent to avoid this. If Google changes its check, open an issue.

## Disclaimer

MyPipe is not affiliated with YouTube, Google, or the NewPipe project. YouTube is a trademark of Google LLC.

## License

[MIT](LICENSE)
