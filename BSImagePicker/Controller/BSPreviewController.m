//
//  BSNewPreviewController.m
//  BSImagePicker
//
//  Created by Joakim Gyllström on 2014-05-24.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSPreviewController.h"
#import "BSPreviewCollectionViewCellFactory.h"
#import "BSImagePickerSettings.h"

#import <AssetsLibrary/AssetsLibrary.h>

typedef NS_ENUM(NSInteger, BSToggleButtonAction) {
    BSToggleButtonActionSelect,
    BSToggleButtonActionDeselect
};

@interface BSPreviewController ()

@property (nonatomic, strong) UIBarButtonItem *toggleButton;

- (void)toggleButtonPressed:(UIBarButtonItem *)sender;
- (void)setupToggleButton;

@end

@implementation BSPreviewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
        
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationItem setRightBarButtonItem:self.toggleButton];
    
    //Scroll to the correct image
    [self.collectionView scrollToItemAtIndexPath:self.currentIndexPath
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:NO];
    
    [self setupToggleButton];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.collectionView reloadData];
    
    //Scroll to the correct image
    [self.collectionView scrollToItemAtIndexPath:self.currentIndexPath
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:NO];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self setCurrentIndexPath:[NSIndexPath indexPathForItem:(scrollView.contentOffset.x / scrollView.frame.size.width) inSection:0]];
    [self setupToggleButton];
}

#pragma mark - Lazy load

- (UIBarButtonItem *)toggleButton {
    if(!_toggleButton) {
        _toggleButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(toggleButtonPressed:)];
    }
    
    return _toggleButton;
}

#pragma mark - Private

- (void)toggleButtonPressed:(UIBarButtonItem *)sender {
    ALAsset *asset = [self.model itemAtIndexPath:self.currentIndexPath];

    if(sender.tag == BSToggleButtonActionSelect) {
        [self.selectedPhotos addObject:asset];

        if([[BSImagePickerSettings sharedSetting] toggleBlock]) {
            BSImageToggleBlock block = [[BSImagePickerSettings sharedSetting] toggleBlock];
            block(asset, YES);
        }
    } else {
        [self.selectedPhotos removeObject:asset];

        if([[BSImagePickerSettings sharedSetting] toggleBlock]) {
            BSImageToggleBlock block = [[BSImagePickerSettings sharedSetting] toggleBlock];
            block(asset, NO);
        }
    }

    [self setupToggleButton];
}

- (void)setupToggleButton {
    ALAsset *asset = [self.model itemAtIndexPath:self.currentIndexPath];
    
    if([self.selectedPhotos containsObject:asset]) {
        [self.toggleButton setTitle:NSLocalizedString(@"Deselect", @"Preview button deselect title")];
        [self.toggleButton setTag:BSToggleButtonActionDeselect];
    } else {
        [self.toggleButton setTitle:NSLocalizedString(@"Select", @"Preview button select title")];
        [self.toggleButton setTag:BSToggleButtonActionSelect];
    }
}

@end
