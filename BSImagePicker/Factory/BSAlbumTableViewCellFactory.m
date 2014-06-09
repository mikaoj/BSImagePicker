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

#import "BSAlbumTableViewCellFactory.h"
#import "BSAlbumCell.h"
#import <AssetsLibrary/AssetsLibrary.h>

static NSString *kAlbumCellIdentifier =             @"albumCellIdentifier";

@implementation BSAlbumTableViewCellFactory

+ (void)registerCellIdentifiersForTableView:(UITableView *)aTableView {
    [aTableView registerClass:[BSAlbumCell class] forCellReuseIdentifier:kAlbumCellIdentifier];
}

+ (CGFloat)heightAtIndexPath:(NSIndexPath *)anIndexPath forModel:(id<BSItemsModel>)aModel {
    CGFloat height = 44.0;
    ALAssetsGroup *assetsGroup = [aModel itemAtIndexPath:anIndexPath];
    
    if([assetsGroup isKindOfClass:[ALAssetsGroup class]]) {
        //Get thumbnail size
        CGSize thumbnailSize = CGSizeMake(CGImageGetWidth(assetsGroup.posterImage), CGImageGetHeight(assetsGroup.posterImage));
        
        //We want 3 images in each row. So width should be viewWidth-(4*LEFT/RIGHT_INSET)/3
        //4*2.0 is edgeinset
        //Height should be adapted so we maintain the aspect ratio of thumbnail
        //original height / original width * new width
        CGSize itemSize = CGSizeMake((320.0 - (4*2.0))/3.0, 100);
        height = CGSizeMake(itemSize.width, thumbnailSize.height / thumbnailSize.width * itemSize.width).height;
    }
    
    return height;
}

- (UITableViewCell *)cellAtIndexPath:(NSIndexPath *)anIndexPath forTableView:(UITableView *)aTableView withModel:(id<BSItemsModel>)aModel {
    BSAlbumCell *albumCell = [aTableView dequeueReusableCellWithIdentifier:kAlbumCellIdentifier forIndexPath:anIndexPath];
    ALAssetsGroup *assetsGroup = [aModel itemAtIndexPath:anIndexPath];
    
    if([assetsGroup isKindOfClass:[ALAssetsGroup class]]) {

        
        [albumCell.imageView setImage:[UIImage imageWithCGImage:assetsGroup.posterImage]];
        [albumCell.textLabel setText:[assetsGroup valueForProperty:ALAssetsGroupPropertyName]];
        [albumCell setBackgroundColor:[UIColor clearColor]];
        [albumCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        //Reset
        [albumCell.secondImageView setImage:nil];
        [albumCell.thirdImageView setImage:nil];
        
        //Set new thumbs
        [assetsGroup enumerateAssetsWithOptions:NSEnumerationReverse
                               usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                   if(result) {
                                       if(index == 1) {
                                           [albumCell.secondImageView setImage:[UIImage imageWithCGImage:result.thumbnail]];
                                           *stop = YES;
                                       } else if(index == 2) {
                                           [albumCell.thirdImageView setImage:[UIImage imageWithCGImage:result.thumbnail]];
                                       }
                                   }
                               }];
    }
    
    return albumCell;
}

@end
