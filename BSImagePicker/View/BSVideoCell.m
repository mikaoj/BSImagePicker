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
//

#import "BSVideoCell.h"
#import "BSCameraView.h"

@interface BSVideoCell ()

@property (nonatomic, strong) BSCameraView *cameraView;

@end

@implementation BSVideoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.imageView addSubview:self.gradientView];
        [self.gradientView addSubview:self.durationLabel];
        [self.gradientView addSubview:self.cameraView];
    }
    return self;
}

- (UIView *)gradientView {
    if(!_gradientView){
        _gradientView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 30)];
        [_gradientView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        [gradientLayer setFrame:_gradientView.bounds];
        [gradientLayer setColors:@[(id)[UIColor colorWithWhite:0 alpha:1.0].CGColor,
                                   (id)[UIColor colorWithWhite:0 alpha:0.5].CGColor,
                                   (id)[UIColor colorWithWhite:0 alpha:0.0].CGColor]];
        [_gradientView.layer insertSublayer:gradientLayer atIndex:0];
    }
    
    return _gradientView;
}

- (UILabel *)durationLabel {
    if(!_durationLabel) {
        _durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, self.gradientView.bounds.size.width-10, 15)];
        [_durationLabel setTextColor:[UIColor whiteColor]];
        [_durationLabel setTextAlignment:NSTextAlignmentRight];
        [_durationLabel setFont:[UIFont systemFontOfSize:14.0]];
    }
    
    return _durationLabel;
}

- (BSCameraView *)cameraView {
    if(!_cameraView) {
        _cameraView = [[BSCameraView alloc] initWithFrame:CGRectMake(5, 2, 40, 10)];
        [_cameraView setBackgroundColor:[UIColor clearColor]];
        [_cameraView setColor:[UIColor whiteColor]];
    }
    
    return _cameraView;
}

@end
