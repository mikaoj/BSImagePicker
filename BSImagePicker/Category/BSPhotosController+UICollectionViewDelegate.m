//
// Created by Joakim Gyllström on 2014-05-27.
// Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSPhotosController+UICollectionViewDelegate.h"
#import "BSImagePickerSettings.h"
#import "BSItemsModel.h"
#import "BSPhotosController+Properties.h"

@implementation BSPhotosController (UICollectionViewDelegate)

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.selectedItems count] < [[BSImagePickerSettings sharedSetting] maximumNumberOfImages];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    ALAsset *asset = [self.collectionModel itemAtIndexPath:indexPath];

    //Remove item
    [self.selectedItems removeObject:asset];

    //Disable done button
    if([self.selectedItems count] == 0) {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }

    if([[BSImagePickerSettings sharedSetting] toggleBlock]) {
        [BSImagePickerSettings sharedSetting].toggleBlock(asset, NO);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ALAsset *asset = [self.collectionModel itemAtIndexPath:indexPath];

    //Add item
    [self.selectedItems addObject:asset];

    //Enable done button
    if([self.selectedItems count] > 0) {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }

    if([[BSImagePickerSettings sharedSetting] toggleBlock]) {
        [BSImagePickerSettings sharedSetting].toggleBlock(asset, YES);
    }
}

@end