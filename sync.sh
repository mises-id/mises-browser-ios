#!/bin/sh

#  sync.sh
#  all
#
#  Created by baoge on 2022/7/15.
#  

cp -R /Users/baoge/Library/Developer/Xcode/DerivedData/MetaMask-ajaxbftsamxqvrabyxosvqvsgjuq/Build/Products/Debug-iphonesimulator/**/*.bundle ios/third_party/mises/Bundles


cp -R /Users/baoge/Library/Developer/Xcode/DerivedData/MetaMask-ajaxbftsamxqvrabyxosvqvsgjuq/Build/Products/Debug-iphonesimulator/**/*.a ios/third_party/mises/Sim/Libs

cp -R /Users/baoge/Library/Developer/Xcode/DerivedData/MetaMask-ajaxbftsamxqvrabyxosvqvsgjuq/Build/Products/Debug-iphonesimulator/**/*.framework ios/third_party/mises/Sim/Frameworks



cp -R /Users/baoge/Library/Developer/Xcode/DerivedData/MetaMask-ajaxbftsamxqvrabyxosvqvsgjuq/Build/Products/Debug-iphoneos/**/*.a ios/third_party/mises/Device/Libs

cp -R /Users/baoge/Library/Developer/Xcode/DerivedData/MetaMask-ajaxbftsamxqvrabyxosvqvsgjuq/Build/Products/Debug-iphoneos/MetaMask.app/Frameworks/*.framework ios/third_party/mises/Device/Frameworks
