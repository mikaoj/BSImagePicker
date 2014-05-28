//
// Created by Joakim Gyllström on 2014-05-28.
// Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSPreviewController.h"
#import "BSPreviewCollectionViewCellFactory.h"


@implementation BSPreviewController

- (UICollectionView *)previewCollectionView {
    if(!_previewCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];

        _previewCollectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
        [_previewCollectionView setBackgroundColor:[UIColor clearColor]];
        [_previewCollectionView setShowsHorizontalScrollIndicator:NO];
        [_previewCollectionView setShowsVerticalScrollIndicator:NO];
        [_previewCollectionView setAllowsMultipleSelection:YES];
        [_previewCollectionView setPagingEnabled:YES];
        [_previewCollectionView setAlwaysBounceHorizontal:YES];
        
        [_previewCollectionView setDelegate:self];
        [_previewCollectionView setDataSource:self];
    }
    
    return _previewCollectionView;
}
- (BSPreviewCollectionViewCellFactory *)previewCellFactory {
    if(!_previewCellFactory) {
        _previewCellFactory = [[BSPreviewCollectionViewCellFactory alloc] init];
    }
    
    return _previewCellFactory;
}

@end