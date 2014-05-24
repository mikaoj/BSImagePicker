//
//  BSItemModelDelegate.h
//  BSImagePicker
//
//  Created by Joakim Gyllström on 2014-05-25.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSItemsModel.h"

@protocol BSItemsModelDelegate <NSObject>

- (void)didUpdateModel:(id<BSItemsModel>)aModel;

@end
