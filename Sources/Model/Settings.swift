// The MIT License (MIT)
//
// Copyright (c) 2015 Joakim Gyllström
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit
import Photos

/// Settings for BSImagePicker
public struct Settings {
    public struct Theme {
        /// Main background color
        public var backgroundColor: UIColor = .white
        
        /// What color to fill the circle with
        public var checkmarkFillColor: UIColor = UIView().tintColor
        
        /// Color for the actual checkmark
        public var checkmarkStrokeColor: UIColor = .white
        
        /// Shadow color for the circle
        public var checkmarkShadowColor: UIColor = .black
    }

    public struct Selection {
        /// Max number of selections allowed
        public var max: Int = Int.max
        
        /// Min number of selections you have to make
        public var min: Int = 1
    }

    public struct List {
        /// How much spacing between cells
        public var spacing: CGFloat = 2
        
        /// How many cells per row
        public var cellsPerRow: (_ verticalSize: UIUserInterfaceSizeClass, _ horizontalSize: UIUserInterfaceSizeClass) -> Int = {(verticalSize: UIUserInterfaceSizeClass, horizontalSize: UIUserInterfaceSizeClass) -> Int in
            switch (verticalSize, horizontalSize) {
            case (.compact, .regular): // iPhone5-6 portrait
                return 3
            case (.compact, .compact): // iPhone5-6 landscape
                return 5
            case (.regular, .regular): // iPad portrait/landscape
                return 7
            default:
                return 3
            }
        }
    }

    public struct Fetch {
        public struct Album {
            /// Fetch options for albums/collections
            public var options: PHFetchOptions = {
                let fetchOptions = PHFetchOptions()
                fetchOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
                return fetchOptions
            }()
            
            /// Type of collections to fetch
            public var type: PHAssetCollectionType = .album
            
            /// Subtype of collections to fetch
            public var subtype: PHAssetCollectionSubtype = .any
        }

        public struct Assets {
            /// Fetch options for assets

            /// Simple wrapper around PHAssetMediaType to ensure we only expose the supported types.
            public enum MediaTypes {
                case image, video

                fileprivate func assetMediaType() -> PHAssetMediaType {
                    switch self {
                    case .image:
                        return PHAssetMediaType.image
                    case .video:
                        return PHAssetMediaType.video
                    }
                }
            }
            public var supportedMediaTypes = [MediaTypes.image]

            public var options: PHFetchOptions {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [
                    NSSortDescriptor(key: "creationDate", ascending: false)
                ]

                let rawMediaTypes = supportedMediaTypes.map { $0.assetMediaType().rawValue }
                let predicate = NSPredicate(format: "mediaType IN %@", rawMediaTypes)
                fetchOptions.predicate = predicate

                return fetchOptions
            }
        }

        /// Album fetch settings
        public var album = Album()
        
        /// Asset fetch settings
        public var assets = Assets()
    }
    
    public struct Dismiss {
        /// Should the image picker dismiss when done/cancelled
        public var enabled = true
    }
    
    public struct Camera {
        /// Should the camera feature be enabled
        public var enabled = false
        
        public var liveView = true
        
        public var icon: UIImage? = UIImage(named: "add_photo", in: Bundle(for: ImagePickerController.self), compatibleWith: nil)
    }

    /// Theme settings
    public var theme = Theme()
    
    /// Selection settings
    public var selection = Selection()
    
    /// List settings
    public var list = List()
    
    /// Fetch settings
    public var fetch = Fetch()
    
    /// Dismiss settings
    public var dismiss = Dismiss()
    
    /// Camera settings
    public var camera = Camera()
}
