//
//  BSImagePickerController.m
//  MultipleImagePicker
//
//  Created by Joakim Gyllström on 2014-04-05.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSImagePickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface BSImagePickerController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIToolbarDelegate>

@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UITableView *albumTableView;

@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UIBarButtonItem *albumButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;

- (void)cancelButtonPressed:(id)sender;
- (void)doneButtonPressed:(id)sender;
- (void)albumButtonPressed:(id)sender;

@end

@implementation BSImagePickerController

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //Default to shitloads of images
        _maximumNumberOfImages = NSUIntegerMax;
        
        //Add subviews
        [self.view addSubview:self.toolbar];
        [self.view addSubview:self.collectionView];
        
        //Setup constraints
        NSDictionary *views = @{@"_collectionView": self.collectionView, @"_toolbar": self.toolbar};
        NSDictionary *metrics = @{@"statusbarHeight": [NSNumber numberWithFloat:[UIApplication sharedApplication].statusBarFrame.size.height]};
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_toolbar]|"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_collectionView]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-statusbarHeight-[_toolbar][_collectionView]|"
                                                                          options:0
                                                                          metrics:metrics
                                                                            views:views]];
    }
    return self;
}

#pragma mark - UIViewController

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeZero;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

#pragma mark - UIToolbarDelegate

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

#pragma mark - Lazy load views

- (UICollectionView *)collectionView
{
    if(!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        [_collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_collectionView setDelegate:self];
        [_collectionView setDataSource:self];
    }
    
    return _collectionView;
}

- (UIToolbar *)toolbar
{
    if(!_toolbar) {
        _toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
        [_toolbar setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_toolbar setDelegate:self];
        
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                               target:nil
                                                                               action:nil];
        
        [_toolbar setItems:@[self.cancelButton, space, self.albumButton, space, self.doneButton]];
    }
    
    return _toolbar;
}

- (UIBarButtonItem *)cancelButton
{
    if(!_cancelButton) {
        _cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                      target:self
                                                                      action:@selector(cancelButtonPressed:)];
    }
    
    return _cancelButton;
}

- (UIBarButtonItem *)doneButton
{
    if(!_doneButton) {
        _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                    target:self
                                                                    action:@selector(doneButtonPressed:)];
    }
    
    return _doneButton;
}

- (UIBarButtonItem *)albumButton
{
    if(!_albumButton) {
        _albumButton = [[UIBarButtonItem alloc] initWithTitle:@"hejsan"
                                                        style:UIBarButtonItemStylePlain
                                                       target:self
                                                       action:@selector(albumButtonPressed:)];
    }
    
    return _albumButton;
}

#pragma mark - Button actions

- (void)cancelButtonPressed:(id)sender
{
    if(self.cancelBlock) {
        self.cancelBlock();
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneButtonPressed:(id)sender
{
    if(self.doneBlock) {
        self.doneBlock();
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)albumButtonPressed:(id)sender
{
    
}

@end
