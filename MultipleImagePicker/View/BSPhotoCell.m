//
//  BSPhotoCell.m
//  MultipleImagePicker
//
//  Created by Joakim Gyllström on 2014-04-11.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSPhotoCell.h"
#import "BSCheckmarkView.h"

@interface BSPhotoCell ()

@property (nonatomic, strong) UIView *selectionView;
@property (nonatomic, strong) BSCheckmarkView *checkmarkView;

@end

@implementation BSPhotoCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.checkmarkView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
    BOOL previous = self.selected;
    
    [super setSelected:selected];
    
    if(previous != selected) {
        [UIView animateWithDuration:0.05
                              delay:0.0
                            options:0
                         animations:^{
                             [self setTransform:CGAffineTransformMakeScale(0.95, 0.95)];
                             [self.checkmarkView setChecked:selected];
                         } completion:^(BOOL finished) {
                             if(selected) {
                                 [self.selectionView setFrame:CGRectMake(self.imageView.center.x, self.imageView.center.y, 1, 1)];
                                 [self.imageView addSubview:self.selectionView];
                                 
                                 [UIView animateWithDuration:0.1
                                                  animations:^{
                                                      [self setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                                                      [self.selectionView setFrame:self.imageView.frame];
                                                  }];
                             } else {
                                 [UIView animateWithDuration:0.1
                                                  animations:^{
                                                      [self setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                                                      [self.selectionView setFrame:CGRectMake(self.imageView.center.x, self.imageView.center.y, 1, 1)];
                                                  } completion:^(BOOL finished) {
                                                      [self.selectionView removeFromSuperview];
                                                  }];
                             }
                         }];
    }
}

- (UIImageView *)imageView
{
    if(!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.contentView.frame];
        [_imageView setContentMode:UIViewContentModeScaleAspectFill];
        [_imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [_imageView setClipsToBounds:YES];
    }
    
    return _imageView;
}

- (UIView *)selectionView
{
    if(!_selectionView) {
        _selectionView = [[UIView alloc] initWithFrame:self.contentView.frame];
        [_selectionView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.3]];
    }
    
    return _selectionView;
}

- (BSCheckmarkView *)checkmarkView
{
    if(!_checkmarkView) {
        _checkmarkView = [[BSCheckmarkView alloc] initWithFrame:CGRectMake(self.imageView.frame.size.width-25, self.imageView.frame.size.height-25, 25, 25)];
        [_checkmarkView setBackgroundColor:[UIColor clearColor]];
    }
    
    return _checkmarkView;
}

@end
