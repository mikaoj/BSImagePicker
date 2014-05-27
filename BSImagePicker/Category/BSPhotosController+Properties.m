//
// Created by Joakim Gyllström on 2014-05-27.
// Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "BSPhotosController+Properties.h"
#import "BSAssetModel.h"
#import "BSAssetsGroupModel.h"
#import "BSPhotoCollectionViewCellFactory.h"
#import "BSPreviewCollectionViewCellFactory.h"
#import "BSAlbumTableViewCellFactory.h"
#import "BSSpeechBubbleView.h"
#import "BSPhotosController+Actions.h"
#import "BSPhotosController+BSItemsModelDelegate.h"
#import "BSImagePickerSettings.h"
#import "BSPhotosController+UICollectionViewDataSource.h"
#import "BSPhotosController+UICollectionViewFlowLayoutDelegate.h"
#import "BSPhotosController+UITableViewDataSource.h"
#import "BSPhotosController+UITableViewDelegate.h"


@implementation BSPhotosController (Properties)

- (BSAssetModel *)assetsModel {
    if(!_assetsModel) {
        _assetsModel = [[BSAssetModel alloc] init];
        [_assetsModel setDelegate:self];
    }

    return _assetsModel;
}

- (BSAssetsGroupModel *)assetsGroupModel {
    if(!_assetsGroupModel) {
        _assetsGroupModel = [[BSAssetsGroupModel alloc] init];
        [_assetsGroupModel setDelegate:self];
        [_assetsGroupModel setAssetsLibrary:[[ALAssetsLibrary alloc] init]];
    }

    return _assetsGroupModel;
}

- (UIBarButtonItem *)cancelButton {
    if(!_cancelButton) {
        _cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                      target:self
                                                                      action:@selector(finishButtonPressed:)];
    }

    return _cancelButton;
}

- (UIBarButtonItem *)doneButton {
    if(!_doneButton) {
        _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                    target:self
                                                                    action:@selector(finishButtonPressed:)];
    }

    return _doneButton;
}

- (UIButton *)albumButton {
    if(!_albumButton) {
        _albumButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_albumButton setFrame:CGRectMake(0, 0, 200, 35)];
        [_albumButton setTitleColor:self.navigationController.view.tintColor forState:UIControlStateNormal];
        [_albumButton addTarget:self action:@selector(albumButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }

    return _albumButton;
}

- (BSSpeechBubbleView *)speechBubbleView {
    if(!_speechBubbleView) {
        _speechBubbleView = [[BSSpeechBubbleView alloc] initWithFrame:CGRectMake(0, 0, 300, 320)];
        [_speechBubbleView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        [[_speechBubbleView contentView] addSubview:self.albumTableView];
    }

    //Set speechbubble color to match tab bar color
    if(![[BSImagePickerSettings sharedSetting] albumTintColor]) {
        [_speechBubbleView setBackgroundColor:self.navigationController.navigationBar.barTintColor];
    }

    return _speechBubbleView;
}

- (UITableView *)albumTableView {
    if(!_albumTableView) {
        _albumTableView = [[UITableView alloc] init];
        [_albumTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [_albumTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [_albumTableView setBackgroundColor:[UIColor clearColor]];;
        [_albumTableView setAllowsSelection:YES];
        [_albumTableView setAllowsMultipleSelection:NO];
        [_albumTableView setDelegate:self];
        [_albumTableView setDataSource:self];

        [_albumTableView reloadData];
    }

    return _albumTableView;
}

- (UIView *)coverView {
    if(!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
        [_coverView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];

        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideAlbumView)];
        [recognizer setNumberOfTapsRequired:1];
        [_coverView addGestureRecognizer:recognizer];
    }

    return _coverView;
}

- (UICollectionView *)photosCollectionView {
    if(!_photosCollectionView) {
        [self.collectionViewFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        _photosCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.collectionViewFlowLayout];
        [_photosCollectionView setBackgroundColor:[UIColor clearColor]];
        [_photosCollectionView setAllowsMultipleSelection:YES];
        [_photosCollectionView setScrollEnabled:YES];
        [_photosCollectionView setAlwaysBounceVertical:YES];

        [_photosCollectionView setDelegate:self];
        [_photosCollectionView setDataSource:self];
    }

    return _photosCollectionView;
}

- (UICollectionView *)previewCollectionView {
    if(!_previewCollectionView) {
        [self.collectionViewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];

        _previewCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.collectionViewFlowLayout];
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

- (BSPhotoCollectionViewCellFactory *)photoCellFactory {
    if(!_photoCellFactory) {
        _photoCellFactory = [[BSPhotoCollectionViewCellFactory alloc] init];
    }

    return _photoCellFactory;
}

- (BSPreviewCollectionViewCellFactory *)previewCellFactory {
    if(!_previewCellFactory) {
        _previewCellFactory = [[BSPreviewCollectionViewCellFactory alloc] init];
    }

    return _previewCellFactory;
}

- (BSAlbumTableViewCellFactory *)albumCellFactory {
    if(!_albumCellFactory) {
        _albumCellFactory = [[BSAlbumTableViewCellFactory alloc] init];
    }
    
    return _albumCellFactory;
}

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