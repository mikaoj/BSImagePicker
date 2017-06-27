# BSImagePicker
[![CI Status](http://img.shields.io/travis/mikaoj/BSImagePicker.svg?style=flat)](https://travis-ci.org/mikaoj/BSImagePicker)
[![Version](https://img.shields.io/cocoapods/v/BSImagePicker.svg?style=flat)](http://cocoapods.org/pods/BSImagePicker)
[![License](https://img.shields.io/cocoapods/l/BSImagePicker.svg?style=flat)](http://cocoapods.org/pods/BSImagePicker)
[![Platform](https://img.shields.io/cocoapods/p/BSImagePicker.svg?style=flat)](http://cocoapods.org/pods/BSImagePicker)

![alt text](Misc/Gif/demo.gif "Demo gif")

A mix between the native iOS 8 gallery and facebooks image picker. It is intended as a replacement for UIImagePickerController for both selecting and taking photos.
This fork adds support for selecting videos also. ( See Instalation to configure new files properly )

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.<br />
To use it in you own project
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

###### Objective-C
``` Obj-C
BSImagePickerViewController *imagePicker = [BSImagePickerViewController new];

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

## Features
* Multiple selection.
* Fullscreen preview
* Switch albums.
* No localization needed (uses icons or system localizations).
* Take photos (it isn't enabled by default, so set takePhotos to true if you want it).
* Customizable - check out BSImagePickerSettings to see what you can tweak.

## Customization

You have access to the cancel, album and done button. Customize them as you would with any other UIBarButtonItem (cancel & finish) or UIButton (album).<br />
There are also a few other settings you can tweak.They are documented in BSImagePickerSettings.<br />
[Documentation @ cocoadocs](http://cocoadocs.org/docsets/BSImagePicker/)



## Custom fetch results

Not happy with the fetch results (camera roll and albums) that BSImagePicker uses as default? You can initialize it with your own!

## Requirements

iOS 8

## Installation

BSImagePicker is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "BSImagePicker", "~> 2.5.0"
```
After pod installation from podfile you need to apply changes made in this fork.<br />
Just replace all files and folders in your project's Pod folder.<br />
Then you need to manually add VideoPreviewViewController.swift in your project on Pod/Classes/Controller<br />
Also add PLAY_75x75.png in your project on Pod/Assets and target Membership to BSImagePicker-BSImagePicker


## Author

Joakim Gyllström, joakim@backslashed.se

## Fork by 

Henrique Ormonde

## License

BSImagePicker is available under the MIT license. See the LICENSE file for more info.
