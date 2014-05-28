//
// Created by Joakim Gyllström on 2014-05-27.
// Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSCollectionController.h"

@protocol BSCollectionViewCellFactory;
@protocol BSItemsModel;
@class BSAlbumTableViewCellFactory;
@protocol BSTableViewCellFactory;

@interface BSPhotosController : BSCollectionController {
    id _assetsModel, _assetsGroupModel, _cancelButton, _doneButton, _albumButton, _speechBubbleView,
            _albumTableView, _coverView, _photosCollectionView, _previewCollectionView, _photoCellFactory, _previewCellFactory, _selectedItems, _collectionViewFlowLayout, _albumCellFactory;
}

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) id<BSItemsModel> tableModel;
@property (nonatomic, weak) id<BSTableViewCellFactory> tableCellFactory;

@end