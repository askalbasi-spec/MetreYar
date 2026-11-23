"""Patches old Flutter plugins in the pub cache so they build with current Gradle/AGP.

flutter_poolakey 2.2.0 still uses jcenter() (removed in Gradle 9) and has no
`namespace` (required by AGP 8). Run after `flutter pub get`.
"""
import glob
import os
import re

cache = os.environ.get("PUB_CACHE") or os.path.expanduser("~/.pub-cache")
for d in glob.glob(os.path.join(cache, "hosted", "*", "flutter_poolakey-*")):
    gradle = os.path.join(d, "android", "build.gradle")
    if not os.path.exists(gradle):
        continue
    s = open(gradle, encoding="utf-8").read()
    s = s.replace("jcenter()", "mavenCentral()")
    if "namespace" not in s:
        manifest = os.path.join(d, "android", "src", "main", "AndroidManifest.xml")
        pkg = "com.example.flutter_poolakey"
        if os.path.exists(manifest):
            m = re.search(r'package="([^"]+)"', open(manifest, encoding="utf-8").read())
            if m:
                pkg = m.group(1)
        s = re.sub(r"(?m)^android\s*\{", 'android {\n    namespace "%s"' % pkg, s, count=1)
    open(gradle, "w", encoding="utf-8").write(s)
    print("patched", gradle)
    print(s)

# Poolakey's core library is published on JitPack.
root = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "android")
for name, line in (
    ("build.gradle.kts", '        maven { url = uri("https://jitpack.io") }\n'),
    ("build.gradle", "        maven { url 'https://jitpack.io' }\n"),
):
    path = os.path.join(root, name)
    if os.path.exists(path):
        t = open(path, encoding="utf-8").read()
        if "jitpack.io" not in t:
            t, n = re.subn(r"(?m)^(\s*)mavenCentral\(\)\s*$", lambda m: m.group(0) + "\n" + line.rstrip("\n"), t, count=1)
            if n:
                open(path, "w", encoding="utf-8").write(t)
                print("jitpack added to", path)
        break
settings = [os.path.join(root, f) for f in ("settings.gradle.kts", "settings.gradle")]

# Adivery bundles optional ad-network adapters whose classes are absent; R8
# aborts on them, so release minification is switched off.
app = os.path.join(root, "app")
for name in ("build.gradle.kts", "build.gradle"):
    path = os.path.join(app, name)
    if not os.path.exists(path):
        continue
    t = open(path, encoding="utf-8").read()
    if "isMinifyEnabled" in t or "minifyEnabled" in t:
        break
    kts = name.endswith(".kts")
    add = (
        "            isMinifyEnabled = false\n            isShrinkResources = false\n"
        if kts
        else "            minifyEnabled false\n            shrinkResources false\n"
    )
    t, n = re.subn(
        r'(?m)^(\s*)(?:getByName\("release"\)|release)\s*\{\s*$',
        lambda m: m.group(0) + "\n" + add.rstrip("\n"),
        t,
        count=1,
    )
    if n:
        open(path, "w", encoding="utf-8").write(t)
        print("minify disabled in", path)
    break
