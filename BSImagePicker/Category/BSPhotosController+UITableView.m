//
// Created by Joakim Gyllström on 2014-05-27.
// Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "BSPhotosController+UITableView.h"
#import "BSAlbumTableViewCellFactory.h"
#import "BSTableViewCellFactory.h"
#import "BSPhotosController+Properties.h"
#import "BSAssetModel.h"
#import "BSPhotosController+Actions.h"

@implementation BSPhotosController (UITableView)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.tableModel numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableModel numberOfItemsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.tableCellFactory cellAtIndexPath:indexPath forTableView:tableView withModel:self.tableModel];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[self.tableCellFactory class] heightAtIndexPath:indexPath forModel:self.tableModel];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ALAssetsGroup *assetsGroup = [self.tableModel itemAtIndexPath:indexPath];

    //Only set if we have choosen a new group
    if(![self.assetsModel.assetGroup isEqual:assetsGroup]) {
        [self.assetsModel setAssetGroup:assetsGroup];
    }

    [self hideAlbumView];
}

@end