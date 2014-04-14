//
//  BSPhotoCell.m
//  MultipleImagePicker
//
//  Created by Joakim Gyllström on 2014-04-11.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSPhotoCell.h"

@interface BSPhotoCell ()

@property (nonatomic, strong) UIView *selectionView;

@end

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

- (void)setSelected:(BOOL)selected
{
    BOOL previous = self.selected;
    
    [super setSelected:selected];
    NSLog(@"Selected!");
    
    if(previous != selected) {
        if(selected) {
            [self.selectionView setFrame:CGRectMake(self.contentView.center.x, self.contentView.center.y, 1, 1)];
            [self.contentView addSubview:self.selectionView];
            
            [UIView animateWithDuration:0.1
                             animations:^{
                                 [self.selectionView setFrame:self.contentView.frame];
                             }];
        } else {
            [UIView animateWithDuration:0.1
                             animations:^{
                                 [self.selectionView setFrame:CGRectMake(self.contentView.center.x, self.contentView.center.y, 1, 1)];
                             } completion:^(BOOL finished) {
                                 [self.selectionView removeFromSuperview];
                             }];
        }
    }
}

- (UIView *)selectionView
{
    if(!_selectionView) {
        _selectionView = [[UIView alloc] initWithFrame:self.contentView.frame];
        [_selectionView setBackgroundColor:[UIColor colorWithWhite:0.7 alpha:0.5]];
    }
    
    return _selectionView;
}

@end
