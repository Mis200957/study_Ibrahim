# IBRAHIM SMART STUDY

Flutter study planner for Android, created for Ibrahim Sameh. The provided reference image was not available as a file in the workspace, so the interface follows the detailed visual description: midnight navy surfaces, restrained neon blue and violet accents, rounded cards, and right-to-left Arabic layout.

## Requirements

- Flutter 3.38 or newer and Dart 3.10 or newer
- Android Studio or Android SDK command-line tools
- Android SDK platform tools and JDK 17

The project uses Flutter Material widgets, SQLite (`sqflite`) for study data, and `file_picker` for profile photos and backup import/export. No external images or font files are required. The splash and motivation scenes are drawn with native Flutter widgets; a custom portrait can be selected later from Settings.

## Run on Android

```sh
flutter pub get
flutter run
```

To produce an installable debug APK:

```sh
flutter build apk --debug
```

In Android Studio, open this folder as a Flutter project, let Gradle sync, connect the device with USB debugging enabled, then choose **Run**. On first run, allow Android to open the file picker when selecting a profile image or restoring a backup.

## Included features

- Arabic and English interface toggle, saved profile name/photo, and theme switch
- Create, edit, search and delete subjects with selectable colors and icons
- Add and edit lessons and summaries, view lesson details, toggle completion, and delete with confirmation
- Daily tasks, completion tracking, due dates, study session logging, and notes
- Statistics computed from SQLite records, including subject progress and active study days
- JSON backup export through Android's save-file picker and backup restore through the file picker

All app data is stored locally on the device. Reinstalling the app may remove local data unless you export a backup first.
