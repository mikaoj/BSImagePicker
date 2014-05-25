//
//  BSFullscreenPhotoCollectionViewCellFactory.m
//  BSImagePicker
//
//  Created by Joakim Gyllström on 2014-05-24.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSPreviewCollectionViewCellFactory.h"
#import "BSPhotoCell.h"
#import <AssetsLibrary/AssetsLibrary.h>

static NSString *kUnknownCellIdentifier =           @"unknownCellIdentifier";
static NSString *kPreviewCellIdentifier =           @"previewCellIdentifier";

@implementation BSPreviewCollectionViewCellFactory

+ (void)registerCellIdentifiersForCollectionView:(UICollectionView *)aCollectionView {
    [aCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kUnknownCellIdentifier];
    [aCollectionView registerClass:[BSPhotoCell class] forCellWithReuseIdentifier:kPreviewCellIdentifier];
}

+ (CGSize)sizeAtIndexPath:(NSIndexPath *)anIndexPath forCollectionView:(UICollectionView *)aCollectionView withModel:(id<BSItemsModel>)aModel {
    return aCollectionView.bounds.size;
}

- (UICollectionViewCell *)cellAtIndexPath:(NSIndexPath *)anIndexPath forCollectionView:(UICollectionView *)aCollectionView withModel:(id<BSItemsModel>)aModel {
    UICollectionViewCell *cell = nil;
    ALAsset *asset = [aModel itemAtIndexPath:anIndexPath];
    
    if([asset isKindOfClass:[ALAsset class]]) {
        BSPhotoCell *previewCell = [aCollectionView dequeueReusableCellWithReuseIdentifier:kPreviewCellIdentifier forIndexPath:anIndexPath];
        
        [previewCell.imageView setImage:[UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage scale:asset.defaultRepresentation.scale orientation:(UIImageOrientation)asset.defaultRepresentation.orientation]];
        
        cell = previewCell;
    } else {
        cell = [aCollectionView dequeueReusableCellWithReuseIdentifier:kUnknownCellIdentifier forIndexPath:anIndexPath];
        //TODO ADD SOME DEBUG INFO. THIS SHOULD NEVER HAPPEN
    }
    
    return cell;
}

@end
