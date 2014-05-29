//
// Created by Joakim Gyllström on 2014-05-27.
// Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "BSPhotosController+BSItemsModel.h"

@implementation BSPhotosController (BSItemsModel)

- (void)didUpdateModel:(id<BSItemsModel>)aModel {
    if(aModel == self.tableModel) {
        NSLog(@"Reload table view");
        [self.tableView reloadData];

        ALAssetsGroup *assetsGroup = [self.tableModel itemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];

        [self.albumButton setTitle:[assetsGroup valueForProperty:ALAssetsGroupPropertyName] forState:UIControlStateNormal];

        //If no selected album, select the first one
        if(!self.tableView.indexPathForSelectedRow) {
            [self.collectionModel setupWithParentItem:assetsGroup];
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    } else {
        [super didUpdateModel:aModel];
    }
}

@end