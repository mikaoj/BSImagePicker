//
//  NSDictionary+ALAsset.h
//  MultipleImagePicker
//
//  Created by Joakim Gyllström on 2014-04-15.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ALAsset;
@interface NSDictionary (ALAsset)

/**
 Creates a dictionary compatible with the imagePickerController:didFinishPickingMediaWithInfo: info dictionary.
 @param asset An ALAsset object to create the dictionary from
 @return imagePickerController:didFinishPickingMediaWithInfo: compatible dictionary.
 */
+ (NSDictionary *)dictionaryWithAsset:(ALAsset *)asset;

@end
