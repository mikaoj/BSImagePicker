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

#import "BSPreviewController.h"
#import "BSPreviewCollectionViewCellFactory.h"
#import "BSNumberedSelectionView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import "BSVideoCell.h"

@interface BSPreviewController ()

@property (nonatomic, strong) UIBarButtonItem *playButton;
@property (nonatomic, strong) UIBarButtonItem *stopButton;
@property (nonatomic, strong) UIBarButtonItem *flexibleItem;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayerController;
@property (nonatomic, strong) BSNumberedSelectionView *checkmarkView;

- (void)togglePlayButtonForIndexPath:(NSIndexPath *)anIndexPath;
- (void)prepareMoviePlayerForIndexPath:(NSIndexPath *)anIndexPath;

- (void)playAction:(id)sender;
- (void)stopAction:(id)sender;
- (void)videoFinishedPlaying:(NSNotification *)notification;

@end

@implementation BSPreviewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
        
        //Setup layout
        [self.collectionViewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];

        //Setup collection view
        [self.collectionView setShowsHorizontalScrollIndicator:NO];
        [self.collectionView setShowsVerticalScrollIndicator:NO];
        [self.collectionView setAllowsMultipleSelection:YES];
        [self.collectionView setPagingEnabled:YES];
        [self.collectionView setAlwaysBounceHorizontal:YES];

        //Setup factory
        [self setCollectionCellFactory:[[BSPreviewCollectionViewCellFactory alloc] init]];

        //Register identifiers
        [[self.collectionCellFactory class] registerCellIdentifiersForCollectionView:self.collectionView];
    }

    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationItem setTitleView:self.toolbar];
    [self.navigationItem setRightBarButtonItem:self.emptyItem];
    
    [self.collectionView scrollToItemAtIndexPath:self.currentIndexPath
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:NO];
    
    [self toggleCheckMarkForIndexPath:self.currentIndexPath];
    [self togglePlayButtonForIndexPath:self.currentIndexPath];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self prepareMoviePlayerForIndexPath:self.currentIndexPath];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

    [self.collectionView performBatchUpdates:^{
        [self.collectionView.collectionViewLayout invalidateLayout];
    } completion:nil];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if([self isViewLoaded] && self.view.window) {
        [self setCurrentIndexPath:[NSIndexPath indexPathForItem:round(scrollView.contentOffset.x / scrollView.frame.size.width) inSection:0]];
        [self toggleCheckMarkForIndexPath:self.currentIndexPath];
        [self togglePlayButtonForIndexPath:self.currentIndexPath];
        [self.moviePlayerController stop];
        [self prepareMoviePlayerForIndexPath:self.currentIndexPath];
    }
}

#pragma mark - Lazy load

- (UIBarButtonItem *)checkMarkButton {
    if(!_checkMarkButton) {
        _checkMarkButton = [[UIBarButtonItem alloc] initWithCustomView:self.checkmarkView];
    }

    return _checkMarkButton;
}

- (BSNumberedSelectionView *)checkmarkView {
    if(!_checkmarkView) {
        _checkmarkView = [[BSNumberedSelectionView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [_checkmarkView setBackgroundColor:[UIColor clearColor]];
    }
    
    return _checkmarkView;
}

- (UIBarButtonItem *)emptyItem {
    if(!_emptyItem) {
        _emptyItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 25.0, 25.0)]];
    }
    
    return _emptyItem;
}

- (UIBarButtonItem *)playButton {
    if(!_playButton) {
        _playButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playAction:)];
    }
    
    return _playButton;
}

- (UIBarButtonItem *)stopButton {
    if(!_stopButton) {
        _stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopAction:)];
    }
    
    return _stopButton;
}

- (UIBarButtonItem *)flexibleItem {
    if(!_flexibleItem) {
        _flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    }
    
    return _flexibleItem;
}

- (UIToolbar *)toolbar {
    if(!_toolbar) {
        _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 44.0, 44.0)];
        [_toolbar setItems:@[self.flexibleItem, self.playButton, self.flexibleItem]];
        [_toolbar sizeThatFits:CGSizeMake(44.0, 44.0)];
        [_toolbar setClipsToBounds:YES];
        [_toolbar setContentMode:UIViewContentModeCenter];
        [_toolbar setBackgroundColor:[UIColor clearColor]];
        [_toolbar setTranslucent:YES];
        [self.toolbar setBackgroundImage:[UIImage new]
                      forToolbarPosition:UIToolbarPositionAny
                              barMetrics:UIBarMetricsDefault];
    }
    
    return _toolbar;
}

- (MPMoviePlayerController *)moviePlayerController {
    if(!_moviePlayerController) {
        _moviePlayerController = [[MPMoviePlayerController alloc] init];
        [_moviePlayerController setControlStyle:MPMovieControlStyleNone];
        [_moviePlayerController setScalingMode:MPMovieScalingModeAspectFit];
        [_moviePlayerController setAllowsAirPlay:NO];
    }
    
    return _moviePlayerController;
}

#pragma mark - Give me a name

- (void)toggleCheckMarkForIndexPath:(NSIndexPath *)anIndexPath {
    BOOL isSelected = [self.collectionModel isItemAtIndexPathSelected:anIndexPath];
    BOOL isCheckmarkVisible = self.navigationItem.rightBarButtonItem == self.checkMarkButton;
    
    if(isSelected) {
        id selectedItem = [self.collectionModel itemAtIndexPath:anIndexPath];
        NSInteger pictureNumber = [self.collectionModel.selectedItems indexOfObject:selectedItem]+1;
        [self.checkmarkView setPictureNumber:pictureNumber];
    } else {
        [self.checkmarkView setPictureNumber:0];
    }

    if(isSelected != isCheckmarkVisible) {
        if(isSelected) {
            [self.navigationItem setRightBarButtonItem:self.checkMarkButton animated:YES];
        } else {
            [self.navigationItem setRightBarButtonItem:self.emptyItem animated:YES];
        }
    }
}

- (void)togglePlayButtonForIndexPath:(NSIndexPath *)anIndexPath {
    ALAsset *asset = [self.collectionModel itemAtIndexPath:anIndexPath];
    if([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
        [self.toolbar setHidden:NO];
    } else {
        [self.toolbar setHidden:YES];
    }
}

- (void)prepareMoviePlayerForIndexPath:(NSIndexPath *)anIndexPath {
    ALAsset *asset = [self.collectionModel itemAtIndexPath:anIndexPath];
    
    if([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
        BSVideoCell *cell = (BSVideoCell *)[self.collectionView cellForItemAtIndexPath:anIndexPath];
        [self.moviePlayerController setContentURL:asset.defaultRepresentation.url];
        [self.moviePlayerController.view setFrame:cell.imageView.bounds];
        [self.moviePlayerController prepareToPlay];
    }
}

#pragma mark - Action

- (void)playAction:(id)sender {
    //Get Cell to play it in
    BSVideoCell *cell = (BSVideoCell *)[self.collectionView cellForItemAtIndexPath:self.currentIndexPath];
    
    //Listen for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoFinishedPlaying:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.moviePlayerController];
    
    //Add subview and play
    [self.moviePlayerController.backgroundView setBackgroundColor:[self.navigationController.view backgroundColor]];
    [cell.imageView addSubview:self.moviePlayerController.view];
    [self.moviePlayerController play];
    
    //Update toolbar
    [self.toolbar setItems:@[self.flexibleItem, self.stopButton, self.flexibleItem]];
}

- (void)stopAction:(id)sender {
    [self.moviePlayerController stop];
}

- (void)videoFinishedPlaying:(NSNotification *)notification {
    //Remove notification listener
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:self.moviePlayerController];
    
    //Stop playback and remove view
    [self.moviePlayerController stop];
    [self.moviePlayerController.view removeFromSuperview];
    
    //Update toolbar
    [self.toolbar setItems:@[self.flexibleItem, self.playButton, self.flexibleItem]];
    
    //To prevent glitch if played a second time
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.moviePlayerController prepareToPlay];
    });
}

@end