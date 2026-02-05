#!/bin/sh

set -e  # Saia no primeiro erro

ROOT=".build/xcframeworks"
FRAMEWORK_PATH="Products/Library/Frameworks/Inject.framework"
set -- "iOS" "iOS Simulator"

VERSION=1.5.2
REPO=exception7601/Inject
ARCHIVE_NAME=Inject
FRAMEWORK_NAME=Inject
ORIGIN=$(pwd)
BUILD=$(date +%s) 
BUILD_COMMIT=$(git log --oneline --abbrev=16 --pretty=format:"%h" -1)
NEW_VERSION=${VERSION}.${BUILD}
NAME=Inject-${BUILD_COMMIT}.zip

rm -rf $ROOT

for PLATAFORM in "$@"
do
xcodebuild archive \
    -project "$FRAMEWORK_NAME.xcodeproj" \
    -scheme "$FRAMEWORK_NAME" \
    -destination "generic/platform=$PLATAFORM"\
    -archivePath "$ROOT/$ARCHIVE_NAME-$PLATAFORM.xcarchive" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    CODE_SIGN_IDENTITY="Apple Development" \
    DEVELOPMENT_TEAM=PN8K78V28P \
    CODE_SIGN_STYLE=Automatic \
    DEBUG_INFORMATION_FORMAT=DWARF
done

xcodebuild -create-xcframework \
  -framework "$ROOT/$ARCHIVE_NAME-iOS.xcarchive/$FRAMEWORK_PATH" \
  -framework "$ROOT/$ARCHIVE_NAME-iOS Simulator.xcarchive/$FRAMEWORK_PATH" \
   -output "$ROOT/$FRAMEWORK_NAME.xcframework"

cd "$ROOT"
zip -r -X "$NAME" "$FRAMEWORK_NAME.xcframework/"
mv "$NAME" "$ORIGIN"
rm -rf "*.xcframework"
cd "$ORIGIN"

SUM=$(swift package compute-checksum "${NAME}" )
echo "$NEW_VERSION" > version

DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${NEW_VERSION}/${NAME}"

# update submodule
if ! git diff --quiet $FRAMEWORK_NAME; then
  git add $FRAMEWORK_NAME
fi

git add version
git commit -m "new Version ${NEW_VERSION}"
git tag -s -a "${NEW_VERSION}" -m "v${NEW_VERSION}"
git push origin HEAD --tags

NOTES=$(cat <<END
SPM binaryTarget
\`\`\`swift
.binaryTarget(
    name: "Inject",
    url: "${DOWNLOAD_URL}",
    checksum: "${SUM}"
)
\`\`\`
END
)

gh release create "${NEW_VERSION}" "${NAME}" --notes "${NOTES}"
echo "${NOTES}"
