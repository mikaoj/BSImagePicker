# Goals for 3.0

### Project
* ~~No cocoapods structure~~
* Better readme. Include description of how to add keys to info plist. Requesting camera access. How to use PHAsset

### Features
* ~~Videos~~
* Live images
* ~~When presenting album selection. Slide down from entire navigation bar~~
* Make album slide down view match navigation bar background
* Ñicer camera capture. And don't save captured photos to library - or no camera capture at all..? Hmm
* Helper methods on PHAsset to easier get images from them.
* ~~Haptic feedback on selection?~~

### Code
* Less subclassing
* Child view controllers
* ~~Data source shouldn't handle selections~~
* Handle updates to photo library better
* ~~No xib/storyboards~~
* ~~Don't handle photo library access, user of this library should do that~~

### iOS 13
* Drop down animation when opening albums view is a couple of pixels of, due to new default modal presentation style.
* Zoom animation is a couple of pixels of due to ^^
* Due to ^^, the image picker can be dismissed with swipe - not triggering Done/cancel callbacks. Look into isModalInPresentation property to disable this and force cancel/done to be used.
