//
//  BSNewPreviewController.m
//  BSImagePicker
//
//  Created by Joakim Gyllström on 2014-05-24.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSNewPreviewController.h"
#import "BSPreviewCollectionViewCellFactory.h"

@interface BSNewPreviewController ()

@property (nonatomic, strong) UIBarButtonItem *toggleButton;

- (void)toggleButtonPressed:(UIBarButtonItem *)sender;

@end

@implementation BSNewPreviewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.collectionViewFlowLayout setMinimumInteritemSpacing:0.0];
        [self.collectionViewFlowLayout setMinimumLineSpacing:0.0];
        [self.collectionViewFlowLayout setSectionInset:UIEdgeInsetsZero];
        [self.collectionViewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        
        [self.collectionView setBackgroundColor:[UIColor clearColor]];
        [self.collectionView setShowsHorizontalScrollIndicator:NO];
        [self.collectionView setShowsVerticalScrollIndicator:NO];
        [self.collectionView setPagingEnabled:YES];
        [self.collectionView setAlwaysBounceHorizontal:YES];
        
        [self setCellFactory:[[BSPreviewCollectionViewCellFactory alloc] init]];
    }
    return self;
}

@end
