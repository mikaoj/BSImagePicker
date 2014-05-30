//
// Created by Joakim Gyllström on 2014-05-30.
// Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSPhotosController+UICollectionView.h"
#import "BSCollectionController+UICollectionView.h"
#import "BSCollectionViewCellFactory.h"
#import "BSPhotoCell.h"

@implementation BSPhotosController (UICollectionView)

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    [super collectionView:collectionView didDeselectItemAtIndexPath:indexPath];

    //Disable done button
    if([self.collectionModel.selectedItems count] == 0) {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [super collectionView:collectionView didSelectItemAtIndexPath:indexPath];

    //Enable done button
    if([self.collectionModel.selectedItems count] > 0) {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
}

@end