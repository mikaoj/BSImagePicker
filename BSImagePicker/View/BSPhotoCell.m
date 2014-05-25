// The MIT License (MIT)
//
// Copyright (c) 2014 Joakim Gyllström
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
    [self setSelected:selected animated:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    BOOL previous = self.selected;
    
    [super setSelected:selected];
    
    if(previous != selected) {
        [UIView animateWithDuration:(animated)?0.05:0
                              delay:0.0
                            options:0
                         animations:^{
                             [self setTransform:CGAffineTransformMakeScale(0.95, 0.95)];
                         } completion:^(BOOL finished) {
                             if(selected) {
                                 [self.contentView addSubview:self.checkmarkView];
                                 [self.selectionView setFrame:CGRectMake(self.imageView.center.x, self.imageView.center.y, 1, 1)];
                                 [self.imageView addSubview:self.selectionView];
                                 
                                 [UIView animateWithDuration:(animated)?0.1:0
                                                  animations:^{
                                                      [self setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                                                      [self.selectionView setFrame:self.imageView.frame];
                                                  }];
                             } else {
                                 [self.checkmarkView removeFromSuperview];
                                 [UIView animateWithDuration:(animated)?0.1:0
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
