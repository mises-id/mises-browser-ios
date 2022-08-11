#!/bin/sh

#  sync.sh
#  all
#
#  Created by baoge on 2022/7/15.
#  

# cp -R /Users/baoge/Library/Developer/Xcode/DerivedData/MetaMask-ajaxbftsamxqvrabyxosvqvsgjuq/Build/Products/Debug-iphonesimulator/**/*.bundle ios/third_party/mises/Bundles


rm -R ios/third_party/mises/Sim/Frameworks/*
rm -R ios/third_party/mises/Device/Frameworks/*
rm -R ios/third_party/mises/Distribution/Frameworks/*



rm -R /Users/baoge/Documents/work/chromium/chromium98/src/out/Official-iphoneos/Mises.app

rm -R /Users/baoge/Documents/work/chromium/chromium98/src/out/Official-iphoneos/*.appex
rm -R /Users/baoge/Documents/work/chromium/chromium98/src/out/Official-iphoneos/ios_clang_arm64_13_0/*.appex


rm -R /Users/baoge/Documents/work/chromium/chromium98/src/out/Debug-iphoneos/Mises.app

rm -R /Users/baoge/Documents/work/chromium/chromium98/src/out/Debug-iphoneos/*.appex
rm -R /Users/baoge/Documents/work/chromium/chromium98/src/out/Debug-iphoneos/ios_clang_arm64_13_0/*.appex

rm -R /Users/baoge/Documents/work/chromium/chromium98/src/out/Debug-iphonesimulator/Mises.app
rm -R /Users/baoge/Documents/work/chromium/chromium98/src/out/Debug-iphonesimulator/*.appex
rm -R /Users/baoge/Documents/work/chromium/chromium98/src/out/Debug-iphonesimulator/ios_clang_arm64_13_0/*.appex


cp /Users/baoge/Documents/work/metamask-mobile/ios/main.jsbundle ios/third_party/mises/Bundles

cp -R /Users/baoge/Library/Developer/Xcode/DerivedData/MetaMask-ajaxbftsamxqvrabyxosvqvsgjuq/Build/Products/Debug-iphonesimulator/**/*.a ios/third_party/mises/Sim/Libs

cp -R /Users/baoge/Library/Developer/Xcode/DerivedData/MetaMask-ajaxbftsamxqvrabyxosvqvsgjuq/Build/Products/Debug-iphonesimulator/MetaMask.app/Frameworks/*.framework ios/third_party/mises/Sim/Frameworks

cp -R /Users/baoge/Documents/work/sdk/sdk.xcframework/ios-arm64_x86_64-simulator/*.framework ios/third_party/mises/Sim/Frameworks


cp -R /Users/baoge/Library/Developer/Xcode/DerivedData/MetaMask-ajaxbftsamxqvrabyxosvqvsgjuq/Build/Products/Debug-iphoneos/**/*.a ios/third_party/mises/Device/Libs

cp -R /Users/baoge/Library/Developer/Xcode/DerivedData/MetaMask-ajaxbftsamxqvrabyxosvqvsgjuq/Build/Products/Debug-iphoneos/MetaMask.app/Frameworks/*.framework ios/third_party/mises/Device/Frameworks


cp -R /Users/baoge/Documents/work/sdk/sdk.xcframework/ios-arm64/*.framework ios/third_party/mises/Device/Frameworks




cp -R /Users/baoge/Library/Developer/Xcode/DerivedData/MetaMask-ajaxbftsamxqvrabyxosvqvsgjuq/Build/Products/Release-iphoneos/**/*.a ios/third_party/mises/Distribution/Libs

cp -R /Users/baoge/Library/Developer/Xcode/DerivedData/MetaMask-ajaxbftsamxqvrabyxosvqvsgjuq/Build/Products/Release-iphoneos/MetaMask.app/Frameworks/*.framework ios/third_party/mises/Distribution/Frameworks


cp -R /Users/baoge/Documents/work/sdk/sdk.xcframework/ios-arm64/*.framework ios/third_party/mises/Distribution/Frameworks