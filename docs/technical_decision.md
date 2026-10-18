# Technical decision — 18 October 2026

Use Godot 4.7.2 stable, typed GDScript, and the Compatibility renderer.

The workspace was empty at inspection. No existing code or assets were replaced.
No Godot executable was found on PATH or in the inspected Desktop, Downloads,
or local Programs folders. Java/ADB/git/python were not on PATH. An Android SDK
was found at `C:/Users/ASUS/AppData/Local/Android/Sdk`, with platforms 33–37,
build tools 35.0.0/36.0.0/36.1.0/37.0.0, platform-tools, and command-line tools.
JDK 18 was referenced by JAVA_HOME; Android Studio also provides a verified
OpenJDK 21.0.10 runtime, used for the Phase 1 export attempt. NDKs 28.2 and 30,
and CMake 3.22.1 and 4.1.2 are present. A custom Gradle/native build is unnecessary
for this prototype's APK, so missing exact NDK/CMake versions are not installed.

Godot's official Windows download page identified 4.7.2 stable. Downloaded the
portable standard editor from that official link; verified the binary reports
`4.7.2.stable.official.ed1daf0bf`. Windows found the expected Prehensile Tales
signer but could not build its certificate trust chain in this environment;
full signature trust verification is therefore not claimed. No security
settings were changed. Matching official export templates are used for export.

Godot directly supports lightweight 2D drawing, containers, Android export,
local files, and headless GDScript tests. GDScript avoids a .NET dependency.
Compatibility targets OpenGL ES 3 capable phones. A four-slot customer pool
with a 20 Hz simulation avoids physics and repeated object allocation.

Reference resolution is 480 × 900, portrait, canvas-item scaling with expanding
aspect; containers and a vertical scroll fallback handle shorter displays.
Android system bars remain visible for the prototype to avoid cutout overlap.

Three products, 500 starting coins, fixed batches of five, automatic checkout,
and a visible next action keep Phase 1 small. No fake level, upgrade, goals,
staff, or audio buttons are added before those systems exist.

Baseline save support is included early because essential progress must not
exist only in memory. This does not mark Phase 4 complete: migration policy,
more exhaustive fault injection, and Android process-death tests remain.
Sales show revenue separately from gross profit (sale price minus wholesale
cost of units sold); spending on unsold inventory is not counted as sold cost.

Sources consulted:
- https://godotengine.org/download/windows/
- https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html

The Android guide recommends JDK 17 and also supports newer JDKs. It lists
build-tools 35.0.1, platform 35, NDK r28b, and CMake 3.10.2 for the documented
toolchain. Actual export results, not the presence of newer versions alone,
determine prototype build compatibility. Recheck official engine requirements
and current Play policy in Phases 8–9; no publication readiness is claimed.
