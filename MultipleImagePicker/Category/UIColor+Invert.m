//
//  UIColor+Invert.m
//  MultipleImagePicker
//
//  Created by Joakim Gyllström on 2014-04-20.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "UIColor+Invert.h"

@implementation UIColor (Invert)

- (UIColor *)invertedColor
{
    CGFloat red, green, blue, alpha;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    
    return [UIColor colorWithRed:1-red green:1-green blue:1-blue alpha:1-alpha];
}

@end
