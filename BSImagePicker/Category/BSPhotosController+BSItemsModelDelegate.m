//
// Created by Joakim Gyllström on 2014-05-27.
// Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "BSPhotosController+BSItemsModelDelegate.h"
#import "BSPhotosController+Properties.h"
#import "BSAssetModel.h"

@implementation BSPhotosController (BSItemsModelDelegate)

- (void)didUpdateModel:(id<BSItemsModel>)aModel {
    if(aModel == self.tableModel) {
        NSLog(@"Reload table view");
        [self.albumTableView reloadData];

        ALAssetsGroup *assetsGroup = [self.tableModel itemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];

        [self.albumButton setTitle:[assetsGroup valueForProperty:ALAssetsGroupPropertyName] forState:UIControlStateNormal];

        //If no selected album, select the first one
        if(!self.albumTableView.indexPathForSelectedRow) {
            [self.assetsModel setAssetGroup:assetsGroup];
            [self.albumTableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    } else {
        NSLog(@"Reload collection view");
        [self.collectionView  reloadSections:[NSIndexSet indexSetWithIndex:0]];
    }
}

@end