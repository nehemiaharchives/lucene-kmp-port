#!/usr/bin/env bash
# Copy ONLY real internet downloads into ./gradle-offline-cache and generate separate tarballs
set -euo pipefail

SRC="$HOME/.gradle"
DST="$(pwd)/gc"
RELEASE_DIR="$DST/releases"
RELEASE_VERSION="1.3"
KOTLIN_VERSION="2.2.0"

echo "➡️  Creating $DST"
mkdir -p "$DST/caches"
shopt -s nullglob

# 1. Copy modules-2 (actual JARs and POMs)
echo "📦  Copying modules-2 (all jars & poms)…"
rsync -a --delete "$SRC/caches/modules-2" "$DST/caches/"

# 2. Copy legacy jars-* caches
echo "📦  Copying legacy jars-* caches (if any)…"
for jdir in "$SRC"/caches/jars-*; do
  rsync -a --delete "$jdir" "$DST/caches/"
done

# 3. Copy Gradle Wrapper zips
echo "📦  Copying Gradle Wrapper zips…"
rsync -a --delete "$SRC/wrapper" "$DST/"

# 4. Copy Android plugin/Sdk cache if present
if [ -d "$SRC/android" ]; then
  echo "📦  Copying Android plugin/Sdk cache…"
  rsync -a --delete "$SRC/android" "$DST/"
fi

# 5. Copy Kotlin/Native toolchains from ~/.konan
echo "📦  Copying Kotlin/Native toolchains from ~/.konan…"
mkdir -p "$DST/.konan/dependencies"

if [ -d "$HOME/.konan/dependencies" ]; then
  rsync -a --delete "$HOME/.konan/dependencies/" "$DST/.konan/dependencies/"
else
  echo "⚠️  No ~/.konan/dependencies found; skipping."
fi

PREBUILT="kotlin-native-prebuilt-linux-x86_64-$KOTLIN_VERSION"
if [ -d "$HOME/.konan/$PREBUILT" ]; then
  echo "Copying $PREBUILT…"
  mkdir -p "$DST/.konan/$PREBUILT"
  rsync -a --delete "$HOME/.konan/$PREBUILT/" "$DST/.konan/$PREBUILT/"
else
  echo "⚠️  ~/.konan/$PREBUILT not found; ensure that version exists locally."
fi

# 6. Create release directory and individual tarballs
echo "📦  Creating release tarball directory: $RELEASE_DIR…"
mkdir -p "$RELEASE_DIR"

echo "📦  Creating individual tarballs in $RELEASE_DIR…"

# 6a. modules-2
if [ -d "$DST/caches/modules-2" ]; then
  tar -czf "$RELEASE_DIR/caches_modules-2.tar.gz" -C "$DST/caches" modules-2
  echo "✅  $RELEASE_DIR/caches_modules-2.tar.gz created"
fi

# 6b. jars-* (if any)
shopt -s nullglob
jars_dirs=("$DST/caches/jars-"*)
if [ ${#jars_dirs[@]} -gt 0 ]; then
  tar -czf "$RELEASE_DIR/caches_jars.tar.gz" -C "$DST/caches" "$(basename "${jars_dirs[0]}")"
  echo "✅  $RELEASE_DIR/caches_jars.tar.gz created"
else
  echo "⚠️  No jars-* directories to archive"
fi

# 6c. wrapper
if [ -d "$DST/wrapper" ]; then
  tar -czf "$RELEASE_DIR/wrapper.tar.gz" -C "$DST" wrapper
  echo "✅  $RELEASE_DIR/wrapper.tar.gz created"
fi

# 6d. android
if [ -d "$DST/android" ]; then
  tar -czf "$RELEASE_DIR/android.tar.gz" -C "$DST" android
  echo "✅  $RELEASE_DIR/android.tar.gz created"
else
  echo "⚠️  No Android cache to archive"
fi

# 6e. konan/dependencies
if [ -d "$DST/.konan/dependencies" ]; then
  tar -czf "$RELEASE_DIR/konan_dependencies.tar.gz" -C "$DST/.konan" dependencies
  echo "✅  $RELEASE_DIR/konan_dependencies.tar.gz created"
fi

# 6f. konan native prebuilt
if [ -d "$DST/.konan/$PREBUILT" ]; then
  tar -czf "$RELEASE_DIR/konan_native_prebuilt.tar.gz" -C "$DST/.konan" "$PREBUILT"
  echo "✅  $RELEASE_DIR/konan_native_prebuilt.tar.gz created"
fi

echo "✅  Offline cache tarballs generated in $RELEASE_DIR"

echo "download them from following urls:"

echo "https://github.com/nehemiaharchives/lucene-kmp-gc/releases/download/$RELEASE_VERSION/android.tar.gz"
echo "https://github.com/nehemiaharchives/lucene-kmp-gc/releases/download/$RELEASE_VERSION/caches_jars.tar.gz"
echo "https://github.com/nehemiaharchives/lucene-kmp-gc/releases/download/$RELEASE_VERSION/caches_modules-2.tar.gz"
echo "https://github.com/nehemiaharchives/lucene-kmp-gc/releases/download/$RELEASE_VERSION/wrapper.tar.gz"
echo "https://github.com/nehemiaharchives/lucene-kmp-gc/releases/download/$RELEASE_VERSION/konan_dependencies.tar.gz"
echo "https://github.com/nehemiaharchives/lucene-kmp-gc/releases/download/$RELEASE_VERSION/konan_native_prebuilt.tar.gz"
