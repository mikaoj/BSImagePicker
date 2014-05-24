//
//  BSPhotoCollectionViewCellFactory.m
//  BSImagePicker
//
//  Created by Joakim Gyllström on 2014-05-24.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSPhotoCollectionViewCellFactory.h"
#import "BSPhotoCell.h"
#import <AssetsLibrary/AssetsLibrary.h>

static NSString *kUnknownCellIdentifier =           @"unknownCellIdentifier";
static NSString *kPhotoCellIdentifier =             @"photoCellIdentifier";

@implementation BSPhotoCollectionViewCellFactory

+ (void)registerCellIdentifiersForCollectionView:(UICollectionView *)aCollectionView {
    [aCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kUnknownCellIdentifier];
    [aCollectionView registerClass:[BSPhotoCell class] forCellWithReuseIdentifier:kPhotoCellIdentifier];
}

+ (CGSize)sizeAtIndexPath:(NSIndexPath *)anIndexPath forCollectionView:(UICollectionView *)aCollectionView withModel:(id<BSItemsModel>)aModel {
    CGSize itemSize = CGSizeZero;
    ALAsset *asset = [aModel itemAtIndexPath:anIndexPath];
    
    if([asset isKindOfClass:[ALAsset class]]) {
        //Get thumbnail size
        CGSize thumbnailSize = CGSizeMake(CGImageGetWidth(asset.thumbnail), CGImageGetHeight(asset.thumbnail));
        
        //We want 3 images in each row. So width should be viewWidth-(4*LEFT/RIGHT_INSET)/3
        //4*2.0 is edgeinset
        //Height should be adapted so we maintain the aspect ratio of thumbnail
        //original height / original width * new width
        itemSize = CGSizeMake((320.0 - (4*2.0))/3.0, 100);
        itemSize = CGSizeMake(itemSize.width, thumbnailSize.height / thumbnailSize.width * itemSize.width);
    }
    
    return itemSize;
}

- (UICollectionViewCell *)cellAtIndexPath:(NSIndexPath *)anIndexPath forCollectionView:(UICollectionView *)aCollectionView withModel:(id<BSItemsModel>)aModel {
    UICollectionViewCell *cell = nil;
    ALAsset *asset = [aModel itemAtIndexPath:anIndexPath];
    
    if([asset isKindOfClass:[ALAsset class]]) {
        BSPhotoCell *photoCell = [aCollectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellIdentifier forIndexPath:anIndexPath];
        
//        [photoCell setAssetIndex:anIndexPath.row];
        [photoCell.imageView setImage:[UIImage imageWithCGImage:asset.thumbnail]];
        
        cell = photoCell;
    } else {
        cell = [aCollectionView dequeueReusableCellWithReuseIdentifier:kUnknownCellIdentifier forIndexPath:anIndexPath];
        //TODO ADD SOME DEBUG INFO. THIS SHOULD NEVER HAPPEN
    }
    
    return cell;
}

@end
