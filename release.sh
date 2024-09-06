#!/bin/sh

tag=$1

# Cleanup
rm -rf .build/output

# Build
swift build -c release --arch arm64 --arch x86_64

mkdir -p .build/output

cp .build/apple/Products/Release/swift-very .build/output/swift-very

cd .build/output

# Zip
zip swift-very.zip swift-very

cd .build/output

# SHA256

shasum=`shasum -a 256 swift-very.zip | cut -f1 -d ' '`

gh release delete "$tag" --yes
gh release create "$tag" -t "$tag" -n ""
gh release upload "$tag" swift-very.zip

git clone git@github.com:divadretlaw/homebrew-tap.git
cd homebrew-tap

sed "s/{{SHASUM}}/$shasum/" Templates/swift-very.rb | sed "s/{{TAG}}/$tag/" > Formula/swift-very.rb

git add Formula/swift-very.rb
git commit -m "Update swift-very"
git push

cd ..
rm -rf homebrew-tap