//
//  BSAlbumTableViewCellFactory.m
//  BSImagePicker
//
//  Created by Joakim Gyllström on 2014-05-23.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSAlbumTableViewCellFactory.h"
#import "BSAlbumCell.h"
#import <AssetsLibrary/AssetsLibrary.h>

static NSString *kUnknownCellIdentifier =           @"unknownCellIdentifier";
static NSString *kAlbumCellIdentifier =             @"albumCellIdentifier";

@implementation BSAlbumTableViewCellFactory

+ (void)registerCellIdentifiersForTableView:(UITableView *)aTableView {
    [aTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kUnknownCellIdentifier];
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
    UITableViewCell *cell = nil;
    ALAssetsGroup *assetsGroup = [aModel itemAtIndexPath:anIndexPath];
    
    if([assetsGroup isKindOfClass:[ALAssetsGroup class]]) {
        BSAlbumCell *albumCell = [aTableView dequeueReusableCellWithIdentifier:kAlbumCellIdentifier forIndexPath:anIndexPath];
        
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
        
        cell = albumCell;
    } else {
        UITableViewCell *unknownCell = [aTableView dequeueReusableCellWithIdentifier:kUnknownCellIdentifier forIndexPath:anIndexPath];
        //TODO: ADD SOME DEBUG INFO TO THE CELL TO HELP NARROW DOWN A BUG
        cell = unknownCell;
    }
    
    return cell;
}

@end
