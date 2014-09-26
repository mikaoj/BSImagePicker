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

// Header
#import "BSPhotoCell.h"

// Views
#import "LNBorderView.h"

@interface BSPhotoCell ()

@property (strong, nonatomic) LNBorderView *borderView;

@end

@implementation BSPhotoCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.imageView];
		[self.imageView addSubview:self.borderView];
        [self.imageView addSubview:self.fadedCoverView];
        [self.imageView addSubview:self.checkmarkView];
		
        self.imageView.clipsToBounds         = NO;
        self.imageView.layer.masksToBounds   = NO;
        self.contentView.clipsToBounds       = NO;
        self.contentView.layer.masksToBounds = NO;
        self.clipsToBounds                   = NO;
        self.layer.masksToBounds             = NO;
    }
    return self;
}

//- (void)setSelected:(BOOL)selected {
//    [self setSelected:selected animated:NO];
//}

- (void)setPictureNumber:(NSUInteger)pictureNumber selected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected];

    [self.fadedCoverView setHidden:!selected];
	[self.checkmarkView setPictureNumber:pictureNumber];
    [self.checkmarkView setHidden:!selected];
	[self.borderView setHidden:!selected];
    
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
												  [self.checkmarkView setNeedsDisplay];
                                              } completion:nil];
                         }];
    }
}

- (UIImageView *)imageView {
    if(!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.contentView.frame, 4.5, 4.5)];
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

- (LNBorderView *)borderView {
	if(!_borderView) {
		_borderView = [[LNBorderView alloc] initWithFrame:self.contentView.frame];
		[_borderView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[_borderView setBackgroundColor:[UIColor clearColor]];
	}
	
	return _borderView;
}

- (BSCheckmarkView *)checkmarkView {
    if(!_checkmarkView) {
        _checkmarkView = [[BSCheckmarkView alloc] initWithFrame:CGRectMake(self.imageView.bounds.size.width - 12, -8, 25, 25)];
		_checkmarkView.contentMode = UIViewContentModeRedraw;
        [_checkmarkView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin];
        [_checkmarkView setBackgroundColor:[UIColor clearColor]];
    }
    
    return _checkmarkView;
}

@end
