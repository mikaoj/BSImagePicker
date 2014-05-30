//
// Created by Joakim Gyllström on 2014-05-28.
// Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSPreviewController.h"
#import "BSCollectionController+UICollectionView.h"
#import "BSPreviewCollectionViewCellFactory.h"
#import "BSPhotoCell.h"
#import "BSCheckmarkView.h"

@implementation BSPreviewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self setAutomaticallyAdjustsScrollViewInsets:YES];

        //Setup layout
        [self.collectionViewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];

        //Setup collection view
        [self.collectionView setShowsHorizontalScrollIndicator:NO];
        [self.collectionView setShowsVerticalScrollIndicator:NO];
        [self.collectionView setAllowsMultipleSelection:YES];
        [self.collectionView setPagingEnabled:YES];
        [self.collectionView setAlwaysBounceHorizontal:YES];

        //TODO: REMOVE ME
        [self.collectionView setBackgroundColor:[UIColor whiteColor]];

        //Setup factory
        [self setCollectionCellFactory:[[BSPreviewCollectionViewCellFactory alloc] init]];

        //Register identifiers
        [[self.collectionCellFactory class] registerCellIdentifiersForCollectionView:self.collectionView];
    }

    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.collectionView scrollToItemAtIndexPath:self.onViewWillAppearScrollToPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

    [self.collectionView performBatchUpdates:^{
        [self.collectionView.collectionViewLayout invalidateLayout];

    } completion:nil];
}

#pragma mark - Lazy load

- (UIBarButtonItem *)checkMarkButton {
    if(!_checkMarkButton) {
        BSCheckmarkView *checkmarkView = [[BSCheckmarkView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [checkmarkView setBackgroundColor:[UIColor clearColor]];
        _checkMarkButton = [[UIBarButtonItem alloc] initWithCustomView:checkmarkView];
    }

    return _checkMarkButton;
}

@end