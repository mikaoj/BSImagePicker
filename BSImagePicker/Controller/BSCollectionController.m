//
//  BSCollectionController.m
//  BSImagePicker
//
//  Created by Joakim Gyllström on 2014-05-24.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSCollectionController.h"

@implementation BSCollectionController

#pragma mark - Init

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    if(self = [super initWithCollectionViewLayout:layout]) {
        
    }
    
    return self;
}

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
    return [self.cellFactory cellAtIndexPath:indexPath forCollectionView:collectionView withModel:self.model];
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

#pragma mark - Lazy load

- (UICollectionViewFlowLayout *)collectionViewFlowLayout {
    if(!_collectionViewFlowLayout) {
        _collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    }
    
    return _collectionViewFlowLayout;
}

@end
