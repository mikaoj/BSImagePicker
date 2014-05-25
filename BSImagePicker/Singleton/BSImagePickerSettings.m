//
//  BSImagePickerSettings.m
//  BSImagePicker
//
//  Created by Joakim Gyllström on 2014-05-25.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSImagePickerSettings.h"

@implementation BSImagePickerSettings

+ (instancetype)sharedSetting {
    static BSImagePickerSettings *sharedSettings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSettings = [[self alloc] init];
    });
    
    return sharedSettings;
}

- (id)init {
    if(self = [super init]) {
        //Default to shitloads of images
        _maximumNumberOfImages = NSUIntegerMax;
    }
    
    return self;
}

@end
