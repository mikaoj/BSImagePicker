#  BSImageView
BSImageView is an image view which lets you animate contentMode changes.

![demo](https://github.com/mikaoj/demo/blob/master/ezgif-2-12b4be73cd.gif "Demo")

## Usage

```swift
import BSImageView
...

let imageView: BSImageView! = ...
...

UIView.animate(withDuration: 0.3) {
    imageView.contentMode = .scaleAspectFill // Or whichever contentMode you want to animate to.
}
```

## Author

Joakim Gyllström, joakim@backslashed.se

## License

BSImageView is available under the MIT license. See the LICENSE file for more info.
