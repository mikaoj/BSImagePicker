//
// Created by Joakim Gyllström on 2014-05-27.
// Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSCollectionController+UICollectionView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "BSPhotoCell.h"
#import "BSCollectionViewCellFactory.h"
#import "BSImagePickerSettings.h"

@implementation BSCollectionController (UICollectionView)

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger items = 0;

    if(self.collectionModel) {
        items = [self.collectionModel numberOfItemsInSection:section];
    }

    return items;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BSPhotoCell *cell = (BSPhotoCell *)[self.collectionCellFactory cellAtIndexPath:indexPath forCollectionView:collectionView withModel:self.collectionModel];

    if([self.collectionModel isItemAtIndexPathSelected:indexPath]) {
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        [cell setSelected:YES animated:NO];
    }

    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger sections = 0;

    if(self.collectionModel) {
        sections = [self.collectionModel numberOfSections];
    }

    return sections;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.collectionModel.selectedItems count] < [[BSImagePickerSettings sharedSetting] maximumNumberOfImages];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    //Remove item
    [self.collectionModel deselectItemAtIndexPath:indexPath];

    if([[BSImagePickerSettings sharedSetting] toggleBlock]) {
        ALAsset *asset = [self.collectionModel itemAtIndexPath:indexPath];
        [BSImagePickerSettings sharedSetting].toggleBlock(asset, NO);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //Add item
    [self.collectionModel selectItemAtIndexPath:indexPath];

    if([[BSImagePickerSettings sharedSetting] toggleBlock]) {
        ALAsset *asset = [self.collectionModel itemAtIndexPath:indexPath];
        [BSImagePickerSettings sharedSetting].toggleBlock(asset, YES);
    }
}

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