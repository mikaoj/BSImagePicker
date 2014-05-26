//
//  BSCollectionController.m
//  BSImagePicker
//
//  Created by Joakim Gyllström on 2014-05-24.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "BSCollectionController.h"
#import "BSImagePickerSettings.h"
#import "BSPhotoCell.h"

@implementation BSCollectionController

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithCollectionViewLayout:self.collectionViewFlowLayout]) {
    }
    return self;
}

#pragma mark - Setters

- (void)setCellFactory:(id<BSCollectionViewCellFactory>)cellFactory {
    _cellFactory = cellFactory;
    
    [[_cellFactory class] registerCellIdentifiersForCollectionView:self.collectionView];
}

# pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger items = 0;
    
    if(self.model) {
        items = [self.model numberOfItemsInSection:section];
    }
    
    return items;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BSPhotoCell *cell = (BSPhotoCell *)[self.cellFactory cellAtIndexPath:indexPath forCollectionView:collectionView withModel:self.model];

    ALAsset *asset = [self.model itemAtIndexPath:indexPath];
    if([self.selectedItems containsObject:asset]) {
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        [cell setSelected:YES animated:NO];
    }

    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger sections = 0;
    
    if(self.model) {
        sections = [self.model numberOfSections];
    }
    
    return sections;
}

#pragma mark - UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize itemSize = CGSizeZero;
    
    if(self.cellFactory) {
        itemSize = [[self.cellFactory class] sizeAtIndexPath:indexPath forCollectionView:collectionView withModel:self.model];
    }
    
    return itemSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return [[self.cellFactory class] edgeInsetAtSection:section forCollectionView:collectionView withModel:self.model];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return [[self.cellFactory class] minimumLineSpacingAtSection:section forCollectionView:collectionView withModel:self.model];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return [[self.cellFactory class] minimumItemSpacingAtSection:section forCollectionView:collectionView withModel:self.model];
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.selectedItems count] < [[BSImagePickerSettings sharedSetting] maximumNumberOfImages];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    ALAsset *asset = [self.model itemAtIndexPath:indexPath];

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
    ALAsset *asset = [self.model itemAtIndexPath:indexPath];

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

#pragma mark - Lazy load

- (UICollectionViewFlowLayout *)collectionViewFlowLayout {
    if(!_collectionViewFlowLayout) {
        _collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    }
    
    return _collectionViewFlowLayout;
}

- (NSMutableArray *)selectedItems {
    if(!_selectedItems) {
        _selectedItems = [[NSMutableArray alloc] init];
    }

    return _selectedItems;
}

@end
