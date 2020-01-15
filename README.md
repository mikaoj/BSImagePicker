# BSImagePicker
[![CI Status](http://img.shields.io/travis/mikaoj/BSImagePicker.svg?style=flat)](https://travis-ci.org/mikaoj/BSImagePicker)
[![Version](https://img.shields.io/cocoapods/v/BSImagePicker.svg?style=flat)](http://cocoapods.org/pods/BSImagePicker)
[![License](https://img.shields.io/cocoapods/l/BSImagePicker.svg?style=flat)](http://cocoapods.org/pods/BSImagePicker)
[![Platform](https://img.shields.io/cocoapods/p/BSImagePicker.svg?style=flat)](http://cocoapods.org/pods/BSImagePicker)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

![alt text](https://cloud.githubusercontent.com/assets/4034956/15001931/254805de-119c-11e6-9f68-d815ccc712cd.gif "Demo gif")

A mix between the native iOS gallery and facebooks image picker.

## Usage

To run the example project, clone the repo, open BSImagePicker workspace and run the example app.
###### Info.plist
```
<key>NSPhotoLibraryUsageDescription</key>
<string>Why you want to access photo library</string>
```

###### Image picker
```
import BSImagePicker

let imagePicker = ImagePickerController()

presentImagePicker(imagePicker, select: { (asset) in
    // User selected an asset. Do something with it. Perhaps begin processing/upload?
}, deselect: { (asset) in
    // User deselected an asset. Cancel whatever you did when asset was selected.
}, cancel: { (assets) in
    // User canceled selection. 
}, finish: { (assets) in
    // User finished selection assets.
})
```

###### PHAsset
TODO: Add description of how to get image from asset.

## Features
* Multiple selection.
* Fullscreen preview
* Switch albums.
* Images, live image and videos supported.
* Customizable.

## Customization

There are a bunch of settings you can tweak. They are documented in Settings.swift.
[Documentation @ cocoadocs](http://cocoadocs.org/docsets/BSImagePicker/)

## Requirements

iOS 10

## Installation

### Cocoapods
Add the following line to your Podfile:

```
pod "BSImagePicker", "~> 3.0"
```
### Carthage
Add the following line to your Cartfile:
```
github "mikaoj/BSImagePicker" ~> 3.0
```

### Swift Package Manager
TODO: spm instructions

## Author

Joakim Gyllström, joakim@backslashed.se

## License

BSImagePicker is available under the MIT license. See the LICENSE file for more info.
