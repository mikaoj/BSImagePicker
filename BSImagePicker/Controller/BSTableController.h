//
//  BSTableController.h
//  BSImagePicker
//
//  Created by Joakim Gyllström on 2014-05-23.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSItemsModel.h"
#import "BSTableViewCellFactory.h"

@interface BSTableController : UITableViewController

@property (nonatomic, strong) id<BSItemsModel> model;
@property (nonatomic, strong) id<BSTableViewCellFactory> cellFactory;

@end
