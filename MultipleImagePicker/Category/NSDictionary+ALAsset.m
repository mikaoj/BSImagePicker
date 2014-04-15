//
//  NSDictionary+ALAsset.m
//  MultipleImagePicker
//
//  Created by Joakim Gyllström on 2014-04-15.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
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
