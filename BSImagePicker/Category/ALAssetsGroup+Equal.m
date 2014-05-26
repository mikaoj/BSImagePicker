//
// Created by Joakim Gyllström on 2014-05-26.
// Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "ALAssetsGroup+Equal.h"


@implementation ALAssetsGroup (Equal)

- (BOOL)isEqual:(id)obj
{
    if(![obj isKindOfClass:[ALAssetsGroup class]]) {
        return NO;
    }

    NSURL *firstUrl = [self valueForProperty:ALAssetsGroupPropertyURL];
    NSURL *secondUrl = [obj valueForProperty:ALAssetsGroupPropertyURL];

    return ([firstUrl isEqual:secondUrl]);
}

@end