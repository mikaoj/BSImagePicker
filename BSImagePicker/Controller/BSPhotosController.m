//
//  BSNewPhotosController.m
//  BSImagePicker
//
//  Created by Joakim Gyllström on 2014-05-24.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSPhotosController.h"
#import "BSAssetModel.h"
#import "BSAssetsGroupModel.h"
#import "BSSpeechBubbleView.h"
#import "BSPreviewController.h"
#import "BSImagePickerController.h"
#import "BSZoomOutAnimator.h"
#import "BSZoomInAnimator.h"
#import "BSTableViewCellFactory.h"
#import "BSPhotoCollectionViewCellFactory.h"
#import "BSAlbumTableViewCellFactory.h"
#import "BSImagePickerSettings.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface BSPhotosController () <UINavigationControllerDelegate, BSItemsModelDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) id<BSTableViewCellFactory> albumCellFactory;

@property (nonatomic, strong) BSAssetModel *assetsModel;
@property (nonatomic, strong) BSAssetsGroupModel *assetsGroupModel;

@property (nonatomic, strong) UITableView *albumTableView;
@property (nonatomic, strong) BSSpeechBubbleView *speechBubbleView;
@property (nonatomic, strong) BSPreviewController *imagePreviewController;
@property (nonatomic, strong) UIView *coverView;

@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UIButton *albumButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;

@property (nonatomic, strong) BSZoomInAnimator *zoomInAnimator;
@property (nonatomic, strong) BSZoomOutAnimator *zoomOutAnimator;

- (void)finishButtonPressed:(id)sender;
- (void)albumButtonPressed:(id)sender;

- (void)itemLongPressed:(UIGestureRecognizer *)recognizer;

- (void)showAlbumView;
- (void)hideAlbumView;

- (NSArray *)selectedPhotos;

@end

@implementation BSPhotosController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self.collectionView setBackgroundColor:[UIColor clearColor]];
        [self.collectionView setAllowsMultipleSelection:YES];
        [self.collectionView setScrollEnabled:YES];
        [self.collectionView setAlwaysBounceVertical:YES];
        
        [self setCellFactory:[[BSPhotoCollectionViewCellFactory alloc] init]];
        [self setAlbumCellFactory:[[BSAlbumTableViewCellFactory alloc] init]];
        [self setModel:self.assetsModel];
        
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(itemLongPressed:)];
        [recognizer setMinimumPressDuration:1.0];
        [self.collectionView addGestureRecognizer:recognizer];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    //Release these if they aren't visible
    if(![self.speechBubbleView isDescendantOfView:self.navigationController.view]) {
        [self setSpeechBubbleView:nil];
        [self setAlbumTableView:nil];
        [self setCoverView:nil];
    }
    
    //Release preview controller if we aren't previewing
    if(![self.navigationController.viewControllers containsObject:self.imagePreviewController]) {
        [self setImagePreviewController:nil];
    }
    
    //These can be released at any time
    [self setZoomInAnimator:nil];
    [self setZoomOutAnimator:nil];
}

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Navigation bar buttons
    [self.navigationItem setLeftBarButtonItem:self.cancelButton];
    [self.navigationItem setRightBarButtonItem:self.doneButton];
    [self.navigationItem setTitleView:self.albumButton];
    
    //Set navigation controller delegate (needed for the custom animation when going to preview)
    [self.navigationController setDelegate:self];
    
    //Enable/disable done button
    if([self.collectionView.indexPathsForSelectedItems count] > 0) {
        [self.doneButton setEnabled:YES];
    } else {
        [self.doneButton setEnabled:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - BSItemsModelDelegate

- (void)didUpdateModel:(id<BSItemsModel>)aModel {
    if(aModel == self.assetsGroupModel) {
        NSLog(@"Reload table view");
        [self.albumTableView reloadData];
        
        ALAssetsGroup *assetsGroup = [self.assetsGroupModel itemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        
        [self.albumButton setTitle:[assetsGroup valueForProperty:ALAssetsGroupPropertyName] forState:UIControlStateNormal];
        
        //If no selected album, select the first one
        if(!self.albumTableView.indexPathForSelectedRow) {
            [self.assetsModel setAssetGroup:assetsGroup];
            [self.albumTableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    } else {
        NSLog(@"Reload collection view");
        [self.collectionView  reloadSections:[NSIndexSet indexSetWithIndex:0]];
    }
}

#pragma mark - UINavigationControllerDelegate

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC {
    id <UIViewControllerAnimatedTransitioning> animator = nil;
    
    if(operation == UINavigationControllerOperationPop) {
        animator = self.zoomOutAnimator;
    } else if(operation == UINavigationControllerOperationPush) {
        animator = self.zoomInAnimator;
    }
    
    return animator;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.assetsGroupModel numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.assetsGroupModel numberOfItemsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.albumCellFactory cellAtIndexPath:indexPath forTableView:tableView withModel:self.assetsGroupModel];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[self.albumCellFactory class] heightAtIndexPath:indexPath forModel:self.assetsGroupModel];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ALAssetsGroup *assetsGroup = [self.assetsGroupModel itemAtIndexPath:indexPath];

    //Only set if we have choosen a new group
    if(![self.assetsModel.assetGroup isEqual:assetsGroup]) {
        [self.assetsModel setAssetGroup:assetsGroup];
    }
    
    [self hideAlbumView];
}

#pragma mark - Button actions

- (void)finishButtonPressed:(id)sender {
    //Cancel or finish? Call correct block!
    if(sender == self.cancelButton) {
        if([[BSImagePickerSettings sharedSetting] cancelBlock]) {
            [BSImagePickerSettings sharedSetting].cancelBlock([self selectedPhotos]);
        }
    } else {
        if([[BSImagePickerSettings sharedSetting] finishBlock]) {
            [BSImagePickerSettings sharedSetting].finishBlock([self selectedPhotos]);
        }
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)albumButtonPressed:(id)sender {
    if([self.speechBubbleView isDescendantOfView:self.navigationController.view]) {
        [self hideAlbumView];
    } else {
        [self showAlbumView];
    }
}

#pragma mark - Show and hide album view

- (void)showAlbumView {
    [self.navigationController.view addSubview:self.coverView];
    [self.navigationController.view addSubview:self.speechBubbleView];
    
    CGFloat tableViewHeight = MIN(self.albumTableView.contentSize.height, 240);
    CGRect frame = CGRectMake(0, 0, self.speechBubbleView.frame.size.width, tableViewHeight+7);
    
    //Remember old values
    CGFloat height = frame.size.height;
    CGFloat width = frame.size.width;
    
    //Set new frame
    frame.size.height = 0.0;
    frame.size.width = 0.0;
    frame.origin.y = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height/2.0;
    frame.origin.x = (self.view.frame.size.width - frame.size.width)/2.0;
    [self.speechBubbleView setFrame:frame];
    
    [UIView animateWithDuration:0.7
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0
                        options:0
                     animations:^{
                         CGRect frame = self.speechBubbleView.frame;
                         frame.size.height = height;
                         frame.size.width = width;
                         frame.origin.y = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height;
                         frame.origin.x = (self.view.frame.size.width - frame.size.width)/2.0;
                         [self.speechBubbleView setFrame:frame];
                         
                         [self.coverView setBackgroundColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5]];
                     } completion:nil];
}

- (void)hideAlbumView {
    __block CGAffineTransform origTransForm = self.speechBubbleView.transform;
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         [self.speechBubbleView setTransform:CGAffineTransformConcat(CGAffineTransformMakeScale(0.1, 0.1), CGAffineTransformMakeTranslation(0, -(self.speechBubbleView.frame.size.height/2.0)))];
                         [self.coverView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
                     } completion:^(BOOL finished) {
                         [self.speechBubbleView removeFromSuperview];
                         [self.speechBubbleView setTransform:origTransForm];
                         [self.coverView removeFromSuperview];
                     }];
}

#pragma mark - Get selected photos

- (NSArray *)selectedPhotos {
    NSMutableArray *selectedPhotos = [[NSMutableArray alloc] initWithCapacity:[self.collectionView.indexPathsForSelectedItems count]];
    
    for(NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems) {
        [selectedPhotos addObject:[self.assetsModel itemAtIndexPath:indexPath]];
    }
    
    return [selectedPhotos copy];
}

#pragma mark - Factory setter

- (void)setAlbumCellFactory:(id<BSTableViewCellFactory>)albumCellFactory {
    _albumCellFactory = albumCellFactory;
    
    [[_albumCellFactory class] registerCellIdentifiersForTableView:self.albumTableView];
}

#pragma mark - GestureRecognizer

- (void)itemLongPressed:(UIGestureRecognizer *)recognizer {
    if(recognizer.state == UIGestureRecognizerStateBegan && ![[BSImagePickerSettings sharedSetting] previewDisabled]) {
        [recognizer setEnabled:NO];
        
        CGPoint location = [recognizer locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
        
        [self.imagePreviewController setModel:self.model];
        [self.imagePreviewController setScrollToPath:indexPath];
        [self.navigationController pushViewController:self.imagePreviewController animated:YES];
        
        [recognizer setEnabled:YES];
    }
}

#pragma mark - Lazy load

- (BSAssetModel *)assetsModel {
    if(!_assetsModel) {
        _assetsModel = [[BSAssetModel alloc] init];
        [_assetsModel setDelegate:self];
    }
    
    return _assetsModel;
}

- (BSAssetsGroupModel *)assetsGroupModel {
    if(!_assetsGroupModel) {
        _assetsGroupModel = [[BSAssetsGroupModel alloc] init];
        [_assetsGroupModel setDelegate:self];
        [_assetsGroupModel setAssetsLibrary:[[ALAssetsLibrary alloc] init]];
    }
    
    return _assetsGroupModel;
}

- (UIBarButtonItem *)cancelButton {
    if(!_cancelButton) {
        _cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                      target:self
                                                                      action:@selector(finishButtonPressed:)];
    }
    
    return _cancelButton;
}

- (UIBarButtonItem *)doneButton {
    if(!_doneButton) {
        _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                    target:self
                                                                    action:@selector(finishButtonPressed:)];
    }
    
    return _doneButton;
}

- (UIButton *)albumButton {
    if(!_albumButton) {
        _albumButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_albumButton setFrame:CGRectMake(0, 0, 200, 35)];
        [_albumButton setTitleColor:self.navigationController.view.tintColor forState:UIControlStateNormal];
        [_albumButton addTarget:self action:@selector(albumButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _albumButton;
}

- (BSSpeechBubbleView *)speechBubbleView {
    if(!_speechBubbleView) {
        _speechBubbleView = [[BSSpeechBubbleView alloc] initWithFrame:CGRectMake(0, 0, 300, 320)];
        [_speechBubbleView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        [_speechBubbleView.contentView addSubview:self.albumTableView];
    }
    
    //Set speechbubble color to match tab bar color
    if(![[BSImagePickerSettings sharedSetting] albumTintColor]) {
        [_speechBubbleView setBackgroundColor:self.navigationController.navigationBar.barTintColor];
    }
    
    return _speechBubbleView;
}

- (UITableView *)albumTableView {
    if(!_albumTableView) {
        _albumTableView = [[UITableView alloc] init];
        [_albumTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [_albumTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [_albumTableView setBackgroundColor:[UIColor clearColor]];;
        [_albumTableView setAllowsSelection:YES];
        [_albumTableView setAllowsMultipleSelection:NO];
        [_albumTableView setDelegate:self];
        [_albumTableView setDataSource:self];
        
        [_albumTableView reloadData];
    }
    
    return _albumTableView;
}

- (UIView *)coverView {
    if(!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
        [_coverView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideAlbumView)];
        [recognizer setNumberOfTapsRequired:1];
        [_coverView addGestureRecognizer:recognizer];
    }
    
    return _coverView;
}

- (BSPreviewController *)imagePreviewController {
    if(!_imagePreviewController) {
        _imagePreviewController = [[BSPreviewController alloc] init];
    }
    
    return _imagePreviewController;
}

- (BSZoomInAnimator *)zoomInAnimator {
    if(!_zoomInAnimator) {
        _zoomInAnimator = [[BSZoomInAnimator alloc] init];
    }
    
    return _zoomInAnimator;
}

- (BSZoomOutAnimator *)zoomOutAnimator {
    if(!_zoomOutAnimator) {
        _zoomOutAnimator = [[BSZoomOutAnimator alloc] init];
    }
    
    return _zoomOutAnimator;
}

@end
