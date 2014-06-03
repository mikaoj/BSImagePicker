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

#import "BSAlbumCell.h"

@interface BSAlbumCell ()

@end

@implementation BSAlbumCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[self.imageView superview] addSubview:self.secondImageView];
        [[self.imageView superview] addSubview:self.thirdImageView];
        
        [self.imageView.layer setShadowColor:[[UIColor whiteColor] CGColor]];
        [self.imageView.layer setShadowRadius:1.0];
        [self.imageView.layer setShadowOffset:CGSizeMake(0.5, -0.5)];
        [self.imageView.layer setShadowOpacity:1.0];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.imageView setFrame:CGRectMake(4, 10, self.imageView.frame.size.width, self.contentView.frame.size.height-10)];
    [self.textLabel setFrame:CGRectMake(self.imageView.frame.origin.x + self.imageView.frame.size.width + 8, self.textLabel.frame.origin.y, self.textLabel.frame.size.width, self.textLabel.frame.size.height)];
    
    [self.secondImageView.layer setZPosition:self.imageView.layer.zPosition-1];
    [self.thirdImageView.layer setZPosition:self.imageView.layer.zPosition-2];
    
    CGRect imageViewFrame = self.imageView.frame;
    [self.secondImageView setFrame:CGRectMake(imageViewFrame.origin.x+3, imageViewFrame.origin.y-3, imageViewFrame.size.width-6, imageViewFrame.size.height-6)];
    imageViewFrame = self.secondImageView.frame;
    [self.thirdImageView setFrame:CGRectMake(imageViewFrame.origin.x+3, imageViewFrame.origin.y-3, imageViewFrame.size.width-6, imageViewFrame.size.height-6)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    if(selected) {
        [self setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [self setAccessoryType:UITableViewCellAccessoryNone];
    }
}

- (UIImageView *)secondImageView
{
    if(!_secondImageView) {
        _secondImageView = [[UIImageView alloc] init];
        
        [_secondImageView.layer setShadowColor:[[UIColor whiteColor] CGColor]];
        [_secondImageView.layer setShadowRadius:1.0];
        [_secondImageView.layer setShadowOffset:CGSizeMake(0.5, -0.5)];
        [_secondImageView.layer setShadowOpacity:1.0];
    }
    
    return _secondImageView;
}

- (UIImageView *)thirdImageView
{
    if(!_thirdImageView) {
        _thirdImageView = [[UIImageView alloc] init];
        
        [_thirdImageView.layer setShadowColor:[[UIColor whiteColor] CGColor]];
        [_thirdImageView.layer setShadowRadius:1.0];
        [_thirdImageView.layer setShadowOffset:CGSizeMake(0.5, -0.5)];
        [_thirdImageView.layer setShadowOpacity:1.0];
    }
    
    return _thirdImageView;
}

@end
