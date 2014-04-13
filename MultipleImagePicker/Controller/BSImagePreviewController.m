//
//  BSImagePreviewController.m
//  MultipleImagePicker
//
//  Created by Joakim Gyllström on 2014-04-13.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSImagePreviewController.h"

@interface BSImagePreviewController ()

@end

@implementation BSImagePreviewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.view setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:self.imageView];
    }
    return self;
}

- (UIImageView *)imageView
{
    if(!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
        [_imageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    }
    
    return _imageView;
}

@end
