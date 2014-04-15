//
//  BSAlbumCell.m
//  MultipleImagePicker
//
//  Created by Joakim Gyllström on 2014-04-11.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSAlbumCell.h"

@implementation BSAlbumCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.imageView setFrame:CGRectMake(4, 4, self.imageView.frame.size.width, self.contentView.frame.size.height-4)];
    [self.textLabel setFrame:CGRectMake(self.imageView.frame.origin.x + self.imageView.frame.size.width + 8, self.textLabel.frame.origin.y, self.textLabel.frame.size.width, self.textLabel.frame.size.height)];
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

@end
