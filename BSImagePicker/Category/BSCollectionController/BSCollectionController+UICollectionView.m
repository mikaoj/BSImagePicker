// The MIT License (MIT)
//
// Copyright (c) 2014 Joakim Gyllström
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "BSCollectionController+UICollectionView.h"
#import "BSPhotoCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
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

        id selectedItem = [self.collectionModel itemAtIndexPath:indexPath];
        NSInteger pictureNumber = [self.collectionModel.selectedItems indexOfObject:selectedItem]+1;
		[cell setPictureNumber:pictureNumber selected:YES animated:NO];
    } else {
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
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
    return [self.collectionModel.selectedItems count] < [[BSImagePickerSettings sharedSetting] maximumNumberOfImages] && !self.disableSelection;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    return !self.disableSelection;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    //Remove item
    [self.collectionModel deselectItemAtIndexPath:indexPath];
    
    BSPhotoCell *cell = (BSPhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
	[cell setPictureNumber:0 selected:NO animated:YES];

    if([[BSImagePickerSettings sharedSetting] toggleBlock]) {
        ALAsset *asset = [self.collectionModel itemAtIndexPath:indexPath];
        [BSImagePickerSettings sharedSetting].toggleBlock(asset, NO);
    }
    
    [self.collectionView reloadItemsAtIndexPaths:self.collectionView.indexPathsForSelectedItems];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //Add item
    [self.collectionModel selectItemAtIndexPath:indexPath];
    
    BSPhotoCell *cell = (BSPhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
	[cell setPictureNumber:[self.collectionModel.selectedItems count] selected:YES animated:YES];

    if([[BSImagePickerSettings sharedSetting] toggleBlock]) {
        ALAsset *asset = [self.collectionModel itemAtIndexPath:indexPath];
        [BSImagePickerSettings sharedSetting].toggleBlock(asset, YES);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize itemSize = CGSizeZero;

    if(self.collectionCellFactory) {
        itemSize = [[self.collectionCellFactory class]
                    sizeAtIndexPath:indexPath
                    forCollectionView:collectionView
                    withModel:self.collectionModel];
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