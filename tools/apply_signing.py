"""Makes the generated Android project sign release builds with our keystore.

Used by CI after `flutter create`. Expects android/key.properties and the
keystore file to exist already. Edits android/app/build.gradle(.kts).
"""
import os
import re
import sys

root = os.path.join(os.path.dirname(__file__), "..", "android", "app")
kts = os.path.join(root, "build.gradle.kts")
groovy = os.path.join(root, "build.gradle")

if os.path.exists(kts):
    path = kts
    s = open(path, encoding="utf-8").read()
    if "keystoreProperties" in s:
        sys.exit(0)
    s = "import java.io.FileInputStream\nimport java.util.Properties\n\n" + s
    loader = (
        "val keystoreProperties = Properties()\n"
        "val keystorePropertiesFile = rootProject.file(\"key.properties\")\n"
        "if (keystorePropertiesFile.exists()) {\n"
        "    keystoreProperties.load(FileInputStream(keystorePropertiesFile))\n"
        "}\n\n"
    )
    s, n = re.subn(r"(?m)^android\s*\{", loader + "android {", s, count=1)
    if n != 1:
        sys.exit("could not find the android { block")
    signing = (
        "    signingConfigs {\n"
        "        create(\"release\") {\n"
        "            keyAlias = keystoreProperties[\"keyAlias\"] as String\n"
        "            keyPassword = keystoreProperties[\"keyPassword\"] as String\n"
        "            storeFile = file(keystoreProperties[\"storeFile\"] as String)\n"
        "            storePassword = keystoreProperties[\"storePassword\"] as String\n"
        "        }\n"
        "    }\n\n"
    )
    s, n = re.subn(r"(?m)^(\s*)buildTypes\s*\{", signing + r"\1buildTypes {", s, count=1)
    if n != 1:
        sys.exit("could not find the buildTypes block")
    s, n = re.subn(
        r'signingConfig\s*=\s*signingConfigs\.getByName\("debug"\)',
        'signingConfig = signingConfigs.getByName("release")',
        s,
    )
    if n < 1:
        sys.exit("could not find the debug signingConfig line")
    open(path, "w", encoding="utf-8").write(s)
elif os.path.exists(groovy):
    path = groovy
    s = open(path, encoding="utf-8").read()
    if "keystoreProperties" in s:
        sys.exit(0)
    loader = (
        "def keystoreProperties = new Properties()\n"
        "def keystorePropertiesFile = rootProject.file('key.properties')\n"
        "if (keystorePropertiesFile.exists()) {\n"
        "    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))\n"
        "}\n\n"
    )
    s, n = re.subn(r"(?m)^android\s*\{", loader + "android {", s, count=1)
    if n != 1:
        sys.exit("could not find the android { block")
    signing = (
        "    signingConfigs {\n"
        "        release {\n"
        "            keyAlias keystoreProperties['keyAlias']\n"
        "            keyPassword keystoreProperties['keyPassword']\n"
        "            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null\n"
        "            storePassword keystoreProperties['storePassword']\n"
        "        }\n"
        "    }\n\n"
    )
    s, n = re.subn(r"(?m)^(\s*)buildTypes\s*\{", signing + r"\1buildTypes {", s, count=1)
    if n != 1:
        sys.exit("could not find the buildTypes block")
    s, n = re.subn(
        r"signingConfig\s+signingConfigs\.debug",
        "signingConfig signingConfigs.release",
        s,
    )
    if n < 1:
        sys.exit("could not find the debug signingConfig line")
    open(path, "w", encoding="utf-8").write(s)
else:
    sys.exit("no android/app/build.gradle(.kts) found")
print("release signing configured in", path)
