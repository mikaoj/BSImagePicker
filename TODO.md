# Goals for 3.0

### Project
* ~~No cocoapods structure~~
* Better readme. Include description of how to add keys to info plist. Requesting camera access. How to use PHAsset

### Features
* ~~Videos~~
* ~~Live images~~
* ~~When presenting album selection. Slide down from entire navigation bar~~
* ~~Make album slide down view match navigation bar background~~
* ~~Haptic feedback on selection?~~
* ~~zoom when previewing photos~~

### Code
* ~~Data source shouldn't handle selections~~
* Handle updates to photo library better
* ~~No xib/storyboards~~
* ~~Don't handle photo library access, user of this library should do that~~
* ~~Make arrow image into a shape so we can use swift package manager (which currently doesn't support resources).~~

### Performance
* Fetching assets of specific types (either with NSPredicate or PHAsset.fetchAssets(with: <TYPE>)) is sloooooow. Much faster to just fetch all...

### iOS 13
* ~~ Drop down animation when opening albums view is a couple of pixels of, due to new default modal presentation style.~~
* ~~Zoom animation is a couple of pixels of due to ^^~~
* ~~Due to ^^, the image picker can be dismissed with swipe - not triggering Done/cancel callbacks. Look into isModalInPresentation property to disable this and force cancel/done to be used.~~
* ~~When using modal presentation style fullscreen. No lines between cells. An iOS 13 bug..?~~ traitCollectionDidChange isn't called on initial trait collection set/init like in iOS 12.
* ~~albumButton with 'long' (not really) titles like Panoramas. Title gets shifted down a line. Doesn't happen on iOS 12. Radar?~~
* Dark mode
* ~~Match drop down color with navigation bar color~~

### Other
* ~~Filter out collections with 0 assets~~
* Include collection asset count in album cell
* Perhaps some shadow/border to album image?
* Settings - Look into how to simplify this. Not a fan of how it is sprinkled all over the code. Perhaps a singelton would be acceptable here.
* Rubber/bounce effect in preview (Zoom) animation?
* Replace Settings.Theme with UIAppearance
* Fix TODOs
