# 2.3.0
* Initialize PhotosViewController AFTER we have permission to access photos.
* Buttons are now public vars.
* Fixed Swift 2.2 deprecation warnings

# 2.2.0
* Set default selection (by [AnthonyMDev])
* Special case when max allowed selections is 1 (by [taberrr])
* UI Test fix (by [barrault01])
* Carthage support

# 2.1.0
* Set camera icon

# 2.0.0
* Take photos

# 1.4.3
* Fixed a bug where album assets where fetch twice

# 1.4.2
* Converted to Swift 2
* Fixed a bug where settings (like selection color) didn’t get passed along to the cell

# 1.4.1
* Fixed crash when presenting for the first time

# 1.4.0
* Allows you to initialize the picker with your own fetch results or asset collection. And an array of assets that should be selected on presentation.

# 1.3.0
* Setting for cells per row
* Performance tweaks (final classes)

# 1.2.0
* More settings for you to tweak (relating to selection)

# 1.1.0
* Exposed cancel, album and done buttons for you to customize
* selectionCharacter property that you can set if you don’t want the numbered selection

# 1.0.1
* Fixed a crash with an IUO in the Photos framework

# 1.0 - Total rewrite in Swift
## What didn't make it for 1.0
* Video support (hoping to add it with 1.1)
* Picker configuration

## Whats new
* Everything
* iOS 8
* Fullscreen preview (as native gallery)
* Observes changes on assets
* Better support for landscape. Show more assets/row when in landscape.

# 0.7
* ?
