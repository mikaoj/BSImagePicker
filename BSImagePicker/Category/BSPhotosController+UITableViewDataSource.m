//
// Created by Joakim Gyllström on 2014-05-27.
// Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSPhotosController+UITableViewDataSource.h"
#import "BSAlbumTableViewCellFactory.h"
#import "BSTableViewCellFactory.h"
#import "BSPhotosController+Properties.h"

@implementation BSPhotosController (UITableViewDataSource)

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

@end