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
        [_imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_imageView setClipsToBounds:YES];
        [self.contentView addSubview:_imageView];
        
        UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:frame];
        [selectedBackgroundView setBackgroundColor:self.tintColor];
        [self setSelectedBackgroundView:selectedBackgroundView];
        
        //Setup constraints
        NSDictionary *views = @{@"_imageView": _imageView};
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-2-[_imageView]-2-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[_imageView]-2-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:views]];
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
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
