# Setup and launch

## This computer

1. Open the project folder and double-click `play.cmd`.
2. The worker shop opens immediately. Touch/drag anywhere in gameplay for the floating joystick or use
   WASD/arrow keys. Menu opens the preserved grocery features.
3. To edit, double-click `editor.cmd`; press **F5** to run the main scene.
4. To run automated checks, double-click `test.cmd`.

The scripts use a portable Godot 4.7.2 under `tools/godot` and a project-local
APPDATA profile. They do not change your system JAVA_HOME, PATH, or SDK.
The source remains a normal Godot project; another editor can import
`project.godot`. Using another profile creates a separate desktop save.

To recreate the engine installation, use the official Windows download at
https://godotengine.org/download/windows/ and choose standard 4.7.2, then extract
the two executable files under `tools/godot`. No .NET edition is required.
`tools` is excluded from Godot imports and source control.

## Android testing — floating touch update

Transfer `builds/MiniShopTycoon-touch-update.apk` to your phone over USB,
open it in Files, and allow installation from that file app only if Android asks
and you want to install this development build. Do not disable Play Protect.
Launch **Mini Shop Tycoon**. It requires Android 7.0+ and an OpenGL ES 3 capable phone.
The `.apk.idsig` file is an auxiliary signing output; ordinary file-based
installation uses the `.apk` file.

If an earlier checkpoint is installed, install this as an **update**. Do not uninstall or
clear data: that can erase local progress. The package ID and debug signing
key are retained, with version code increased to 11. Existing coins, stock,
levels/upgrades, machine/carried/counter inventory and cash stay intact. Schema 8
adds owned fries production/inventory and furniture; prior machine upgrades, staff
and cash remain intact. Older saves initialize new content locked/unowned. Do not downgrade after migration.
It launches into the new world; Menu opens the preserved grocery business.

This is a locally signed debug build, not a Play Store release. It does not
request internet access. No release signing keys or Play account are required
for this checkpoint. Installation on this phone still needs your verification.

On this computer, **build-android.cmd** repeats the verified export using the
local editor profile. Only Android templates were extracted to save disk space;
other platform exports need their own matching templates. The SDK was already
installed; no global environment settings were changed.

To rebuild manually, open the editor and choose **Editor → Editor Settings →
Export → Android**. Set Android SDK Path to your SDK and Java SDK Path to JDK
17 or a supported newer JDK. On this PC the inspected JDK is
`C:/Program Files/Android/Android Studio/jbr` (21.0.10).
Install matching **4.7.2** export templates using **Editor → Manage Export
Templates**. Choose **Project → Export → Android Phase K → Export Project**,
keep debug enabled, and save to `builds/MiniShopTycoon-phaseK.apk`.

The Android preset uses both ARMv7 and ARM64, portrait configuration and package
`com.minishoptycoon.offlinegame` (provisional; global uniqueness not verified).
Phase K adds unsigned APK/AAB candidates and static API/native alignment checks.
See release_preparation.md for build/signing commands and remaining device/store
acceptance. No release key has been generated and nothing has been published.
