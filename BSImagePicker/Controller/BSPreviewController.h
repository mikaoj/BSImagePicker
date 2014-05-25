//
//  BSNewPreviewController.h
//  BSImagePicker
//
//  Created by Joakim Gyllström on 2014-05-24.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSCollectionController.h"

@interface BSPreviewController : BSCollectionController

@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, weak) NSMutableArray *selectedPhotos;

@end
