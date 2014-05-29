//
//  BSFullscreenPhotoCollectionViewCellFactory.m
//  BSImagePicker
//
//  Created by Joakim Gyllström on 2014-05-24.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSPreviewCollectionViewCellFactory.h"
#import "BSPhotoCell.h"
#import "BSCheckmarkView.h"
#import <AssetsLibrary/AssetsLibrary.h>

static NSString *kPhotoCellIdentifier =             @"previewCellIdentifier";

@implementation BSPreviewCollectionViewCellFactory

+ (void)registerCellIdentifiersForCollectionView:(UICollectionView *)aCollectionView {
    [aCollectionView registerClass:[BSPhotoCell class] forCellWithReuseIdentifier:kPhotoCellIdentifier];
}

+ (CGSize)sizeAtIndexPath:(NSIndexPath *)anIndexPath forCollectionView:(UICollectionView *)aCollectionView withModel:(id<BSItemsModel>)aModel {
    return aCollectionView.bounds.size;
}

+ (UIEdgeInsets)edgeInsetAtSection:(NSUInteger)aSection forCollectionView:(UICollectionView *)aCollectionView withModel:(id<BSItemsModel>)aModel {
    return UIEdgeInsetsZero;
}

+ (CGFloat)minimumLineSpacingAtSection:(NSUInteger)aSection forCollectionView:(UICollectionView *)aCollectionView withModel:(id<BSItemsModel>)aModel {
    return 0.0;
}

+ (CGFloat)minimumItemSpacingAtSection:(NSUInteger)aSection forCollectionView:(UICollectionView *)aCollectionView withModel:(id<BSItemsModel>)aModel {
    return 0.0;
}

- (UICollectionViewCell *)cellAtIndexPath:(NSIndexPath *)anIndexPath forCollectionView:(UICollectionView *)aCollectionView withModel:(id<BSItemsModel>)aModel {
    
    BSPhotoCell *cell = (BSPhotoCell *)[aCollectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellIdentifier forIndexPath:anIndexPath];
    ALAsset *asset = [aModel itemAtIndexPath:anIndexPath];
    
    if([asset isKindOfClass:[ALAsset class]]) {
        [cell.fadedCoverView setHidden:YES];
        [cell.checkmarkView setHidden:YES];
        [cell.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [cell.imageView setImage:[UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage scale:asset.defaultRepresentation.scale orientation:(UIImageOrientation)asset.defaultRepresentation.orientation]];
    }
    
    return cell;
}

@end
