//
//  BSPhotoCell.m
//  MultipleImagePicker
//
//  Created by Joakim Gyllström on 2014-04-11.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSPhotoCell.h"

@implementation BSPhotoCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.contentView.frame];
        [_imageView setContentMode:UIViewContentModeScaleAspectFill];
        [_imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [_imageView setClipsToBounds:YES];
        [self.contentView addSubview:_imageView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
