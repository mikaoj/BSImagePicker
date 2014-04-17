// The MIT License (MIT)
//
// Copyright (c) 2014 Joakim Gyllström
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
//
//  UIImagePickerControllerMediaType
//  Specifies the media type selected by the user.
//  The value for this key is an NSString object containing a type code such as kUTTypeImage or kUTTypeMovie.

//  UIImagePickerControllerOriginalImage
//  Specifies the original, uncropped image selected by the user.
//  The value for this key is a UIImage object.

//  UIImagePickerControllerEditedImage
//  Specifies an image edited by the user.
//  The value for this key is a UIImage object.

//  UIImagePickerControllerCropRect
//  Specifies the cropping rectangle that was applied to the original image.
//  The value for this key is an NSValue object containing a CGRect opaque type.

//  UIImagePickerControllerReferenceURL
//  The Assets Library URL for the original version of the picked item.
//  After the user edits a picked item—such as by cropping an image or trimming a movie—the URL continues to point to the original version of the picked item.
//  The value for this key is an NSURL object.


#import "NSDictionary+ALAsset.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

@implementation NSDictionary (ALAsset)

+ (NSDictionary *)dictionaryWithAsset:(ALAsset *)asset
{
    return @{
             UIImagePickerControllerMediaType: (__bridge_transfer NSString *)kUTTypeImage,
             UIImagePickerControllerOriginalImage: [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage],
             UIImagePickerControllerReferenceURL: asset.defaultRepresentation.url
             };
}

@end
