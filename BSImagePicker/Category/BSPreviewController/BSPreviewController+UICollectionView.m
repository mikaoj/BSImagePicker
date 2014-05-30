//
// Created by Joakim Gyllström on 2014-05-30.
// Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSPreviewController+UICollectionView.h"
#import "BSCollectionController+UICollectionView.h"
#import "BSCollectionViewCellFactory.h"

@implementation BSPreviewController (UICollectionView)

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    [super collectionView:collectionView didDeselectItemAtIndexPath:indexPath];

    [self.navigationItem setRightBarButtonItem:nil animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [super collectionView:collectionView didSelectItemAtIndexPath:indexPath];

    [self.navigationItem setRightBarButtonItem:self.checkMarkButton animated:YES];
}

@end