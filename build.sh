#!/bin/bash
##############################################
# Build script - creates SamPerformance.zip
# Usage: ./build.sh
##############################################

VERSION=$(grep "^version=" module.prop | cut -d'=' -f2)
OUTPUT="SamPerformance-${VERSION}.zip"

echo "Building SamPerformance ${VERSION}..."

# Remove old build
rm -f SamPerformance*.zip

# Files to exclude from zip
EXCLUDES=(
    "-x" "*.git*"
    "-x" "*.md"
    "-x" "build.sh"
    "-x" "screenshots/*"
    "-x" "update.json"
    "-x" ".gitignore"
    "-x" "LICENSE"
    "-x" "*.DS_Store"
    "-x" "SamPerformance-Github/*"
)

# Set executable permissions
chmod +x scripts/*.sh service.sh action.sh post-fs-data.sh customize.sh uninstall.sh
chmod +x META-INF/com/google/android/update-binary

# Build zip
zip -r "$OUTPUT" . "${EXCLUDES[@]}" > /dev/null

# Also create generic name for releases
cp "$OUTPUT" "SamPerformance.zip"

echo "✅ Built: $OUTPUT"
echo "✅ Built: SamPerformance.zip"
ls -lh SamPerformance*.zip
