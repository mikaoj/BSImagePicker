//
//  ALAsset+Equal.m
//  MultipleImagePicker
//
//  Created by Joakim Gyllström on 2014-04-16.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "ALAsset+Equal.h"

@implementation ALAsset (Equal)

- (BOOL)isEqual:(id)obj
{
    if(![obj isKindOfClass:[ALAsset class]]) {
        return NO;
    }
    
    NSURL *firstUrl = [self valueForProperty:ALAssetPropertyAssetURL];
    NSURL *secondUrl = [obj valueForProperty:ALAssetPropertyAssetURL];
    
    return ([firstUrl isEqual:secondUrl]);
}

@end
