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

#import "BSTableController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "BSAssetsGroupModel.h"
#import "BSAlbumTableViewCellFactory.h"
#import "BSTableController+BSItemsModel.h"
#import "BSTableController+UITableView.h"

@implementation BSTableController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [[self.tableCellFactory class] registerCellIdentifiersForTableView:self.tableView];
    }
    
    return self;
}

#pragma mark - Lazy load

- (id<BSItemsModel>)tableModel {
    if(!_tableModel) {
        _tableModel = [[BSAssetsGroupModel alloc] init];
        [_tableModel setDelegate:self];
        [_tableModel setupWithParentItem:[[ALAssetsLibrary alloc] init]];
    }
    
    return _tableModel;
}

- (UITableView *)tableView {
    if(!_tableView) {
        _tableView = [[UITableView alloc] init];
        [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [_tableView setBackgroundColor:[UIColor clearColor]];;
        [_tableView setAllowsSelection:YES];
        [_tableView setAllowsMultipleSelection:NO];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
    }
    
    return _tableView;
}

- (id<BSTableViewCellFactory>)tableCellFactory {
    if(!_tableCellFactory) {
        _tableCellFactory = [[BSAlbumTableViewCellFactory alloc] init];
    }
    
    return _tableCellFactory;
}

@end
