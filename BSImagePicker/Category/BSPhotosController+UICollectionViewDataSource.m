//
// Created by Joakim Gyllström on 2014-05-27.
// Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSPhotosController+UICollectionViewDataSource.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "BSPhotoCell.h"
#import "BSItemsModel.h"
#import "BSPhotosController+Properties.h"
#import "BSCollectionViewCellFactory.h"

@implementation BSPhotosController (UICollectionViewDataSource)

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger items = 0;

    if(self.collectionModel) {
        items = [self.collectionModel numberOfItemsInSection:section];
    }

    return items;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BSPhotoCell *cell = (BSPhotoCell *)[self.collectionCellFactory cellAtIndexPath:indexPath forCollectionView:collectionView withModel:self.collectionModel];

    ALAsset *asset = [self.collectionModel itemAtIndexPath:indexPath];
    if([self.selectedItems containsObject:asset]) {
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

@end