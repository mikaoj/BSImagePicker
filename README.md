# BSImagePicker
[![CI Status](http://img.shields.io/travis/mikaoj/BSImagePicker.svg?style=flat)](https://travis-ci.org/mikaoj/BSImagePicker)
[![Version](https://img.shields.io/cocoapods/v/BSImagePicker.svg?style=flat)](http://cocoapods.org/pods/BSImagePicker)
[![License](https://img.shields.io/cocoapods/l/BSImagePicker.svg?style=flat)](http://cocoapods.org/pods/BSImagePicker)
[![Platform](https://img.shields.io/cocoapods/p/BSImagePicker.svg?style=flat)](http://cocoapods.org/pods/BSImagePicker)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

![alt text](https://cloud.githubusercontent.com/assets/4034956/15001931/254805de-119c-11e6-9f68-d815ccc712cd.gif "Demo gif")

A multiple image picker for iOS.

## Features
* Multiple selection.
* Fullscreen preview
* Switching albums.
* Supports images, live photos and videos.
* Customizable.

## Usage

##### Info.plist
To be able to request permission to the users photo library you need to add this to your Info.plist
```
<key>NSPhotoLibraryUsageDescription</key>
<string>Why you want to access photo library</string>
```

##### Image picker
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

##### PHAsset
So you have a bunch of [PHAsset](https://developer.apple.com/documentation/photokit/phasset)s now, great. But how do you use them?
To get an UIImage from the asset you use a [PHImageManager](https://developer.apple.com/documentation/photokit/phimagemanager).

```
import Photos

// Request the maximum size. If you only need a smaller size make sure to request that instead.
PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: nil) { (image, info) in
    // Do something with image
}
```

For more example you can clone this repo and look at the example app.

## Installation

### Cocoapods
Add the following line to your Podfile:

```
pod "BSImagePicker", "~> 3.1"
```
### Carthage
Add the following line to your Cartfile:
```
github "mikaoj/BSImagePicker" ~> 3.1
```
### Swift Package Manager
Add it to the dependencies value of your Package.swift.:
```
dependencies: [
.package(url: "https://github.com/mikaoj/BSImagePicker.git", from: "version-tag")
]
```

## Xamarin

If you are Xamarin developer you can use [Net.Xamarin.iOS.BSImagePicker](https://github.com/SByteDev/Net.Xamarin.iOS.BSImagePicker)

## Contribution

Users are encouraged to become active participants in its continued development — by fixing any bugs that they encounter, or by improving the documentation wherever it’s found to be lacking.

If you wish to make a change, [open a Pull Request](https://github.com/mikaoj/BSImagePicker/pull/new) — even if it just contains a draft of the changes you’re planning, or a test that reproduces an issue — and we can discuss it further from there.

## License

BSImagePicker is available under the MIT license. See the LICENSE file for more info.
