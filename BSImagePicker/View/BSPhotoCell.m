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

@interface BSPhotoCell ()

@end

@implementation BSPhotoCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.imageView];
        [self.imageView addSubview:self.fadedCoverView];
        [self.imageView addSubview:self.checkmarkView];
    }
    return self;
}

- (void)setPictureNumber:(NSUInteger)pictureNumber selected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected];

    [self.fadedCoverView setHidden:!selected];
	[self.checkmarkView setPictureNumber:pictureNumber];
    [self.checkmarkView setHidden:!selected];
    
    if(animated) {
        [UIView animateWithDuration:0.08
                              delay:0.0
                            options:0
                         animations:^{
                             [self.imageView setTransform:CGAffineTransformMakeScale(0.95, 0.95)];
                         } completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.08
                                                   delay:0.0
                                                 options:0
                                              animations:^{
                                                  [self.imageView setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                                              } completion:nil];
                         }];
    }
}

- (UIImageView *)imageView {
    if(!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        [_imageView setContentMode:UIViewContentModeScaleAspectFill];
        [_imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [_imageView setClipsToBounds:YES];
    }
    
    return _imageView;
}

- (UIView *)fadedCoverView {
    if(!_fadedCoverView) {
        _fadedCoverView = [[UIView alloc] initWithFrame:self.contentView.frame];
        [_fadedCoverView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [_fadedCoverView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.3]];
    }
    
    return _fadedCoverView;
}

- (BSNumberedSelectionView *)checkmarkView {
    if(!_checkmarkView) {
        _checkmarkView = [[BSNumberedSelectionView alloc] initWithFrame:CGRectMake(self.imageView.bounds.size.width-25, self.imageView.bounds.size.height-25, 25, 25)];
		_checkmarkView.contentMode = UIViewContentModeRedraw;
        [_checkmarkView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin];
        [_checkmarkView setBackgroundColor:[UIColor clearColor]];
    }
    
    return _checkmarkView;
}

@end
