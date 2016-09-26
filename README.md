# BSImagePicker
[![CI Status](http://img.shields.io/travis/mikaoj/BSImagePicker.svg?style=flat)](https://travis-ci.org/mikaoj/BSImagePicker)
[![Version](https://img.shields.io/cocoapods/v/BSImagePicker.svg?style=flat)](http://cocoapods.org/pods/BSImagePicker)
[![License](https://img.shields.io/cocoapods/l/BSImagePicker.svg?style=flat)](http://cocoapods.org/pods/BSImagePicker)
[![Platform](https://img.shields.io/cocoapods/p/BSImagePicker.svg?style=flat)](http://cocoapods.org/pods/BSImagePicker)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

![alt text](https://cloud.githubusercontent.com/assets/4034956/15001931/254805de-119c-11e6-9f68-d815ccc712cd.gif "Demo gif")

A mix between the native iOS 8 gallery and facebooks image picker. It is intended as a replacement for UIImagePickerController for both selecting and taking photos.

## Usage
Put stuff into info.plist TODO: ADD WHAT
```swift
// Make sure you ask for permission first!
PHPhotoLibrary.requestAuthorization { (status) in

}
```
To use it in you own project
###### Swift
```swift
let vc = ImagePicker()
presentImagePicker(vc,
    onSelect: { (photo) in
        print("Select")
    }, onDeselect: { (photo) in
        print("deselect")
    }, onCancel: { (photos) in
        print("cancel")
    }, onFinish: { (photos) in
        print("finish")
    })
```

## Customization


## Requirements

iOS 8

## Installation


## Author

Joakim Gyllström, joakim@backslashed.se

## License

BSImagePicker is available under the MIT license. See the LICENSE file for more info.
