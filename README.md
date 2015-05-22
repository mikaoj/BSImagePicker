# BSImagePicker
(build is failing because travis doesn't like Swift 1.2)<br />
[![CI Status](http://img.shields.io/travis/mikaoj/BSImagePicker.svg?style=flat)](https://travis-ci.org/Joakim Gyllstrom/BSImagePicker)
[![Version](https://img.shields.io/cocoapods/v/BSImagePicker.svg?style=flat)](http://cocoapods.org/pods/BSImagePicker)
[![License](https://img.shields.io/cocoapods/l/BSImagePicker.svg?style=flat)](http://cocoapods.org/pods/BSImagePicker)
[![Platform](https://img.shields.io/cocoapods/p/BSImagePicker.svg?style=flat)](http://cocoapods.org/pods/BSImagePicker)

![alt text](Misc/Gif/demo.gif "Demo gif")

A mix between the native iOS 8 gallery and facebooks image picker.

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.<br />
To use it in you own project
###### Objective-C
```objc
BSImagePickerViewController *imagePicker = [BSImagePickerViewController new];

// Present image picker. Any of the blocks can be nil
[self bs_presentImagePickerController:imagePicker
                             animated:YES
                               select:^(PHAsset * __nonnull asset) {
                                 // User selected an asset.
                                 // Do something with it, start upload perhaps?
                               } deselect:^(PHAsset * __nonnull asset) {
                                 // User deselected an assets.
                                 // Do something, cancel upload?
                               } cancel:^(NSArray * __nonnull assets) {
                                 // User cancelled. And this where the assets currently selected.
                               } finish:^(NSArray * __nonnull assets) {
                                 // User finished with these assets
                               } completion:nil];
```
###### Swift
```swift
let vc = BSImagePickerViewController()

bs_presentImagePickerController(vc, animated: true,
    select: { (asset: PHAsset) -> Void in
      // User selected an asset.
      // Do something with it, start upload perhaps?
    }, deselect: { (asset: PHAsset) -> Void in
      // User deselected an assets.
      // Do something, cancel upload?
    }, cancel: { (assets: [PHAsset]) -> Void in
      // User cancelled. And this where the assets currently selected.
    }, finish: { (assets: [PHAsset]) -> Void in
      // User finished with these assets
}, completion: nil)
```

## Requirements

iOS 8

## Installation

BSImagePicker is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "BSImagePicker"
```

## Author

Joakim Gyllström, joakim@backslashed.se

## License

BSImagePicker is available under the MIT license. See the LICENSE file for more info.
