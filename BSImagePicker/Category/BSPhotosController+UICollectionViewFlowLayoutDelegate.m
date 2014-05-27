//
// Created by Joakim Gyllström on 2014-05-27.
// Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSPhotosController+UICollectionViewFlowLayoutDelegate.h"
#import "BSPhotoCollectionViewCellFactory.h"

@implementation BSPhotosController (UICollectionViewFlowLayoutDelegate)

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize itemSize = CGSizeZero;

    if(self.collectionCellFactory) {
        itemSize = [[self.collectionCellFactory class] sizeAtIndexPath:indexPath forCollectionView:collectionView withModel:self.collectionModel];
    }

    return itemSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return [[self.collectionCellFactory class] edgeInsetAtSection:section forCollectionView:collectionView withModel:self.collectionModel];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return [[self.collectionCellFactory class] minimumLineSpacingAtSection:section forCollectionView:collectionView withModel:self.collectionModel];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return [[self.collectionCellFactory class] minimumItemSpacingAtSection:section forCollectionView:collectionView withModel:self.collectionModel];
}

@end