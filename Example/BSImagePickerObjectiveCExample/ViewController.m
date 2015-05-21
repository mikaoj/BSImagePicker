//
//  ViewController.m
//  BSImagePickerObjectiveCExample
//
//  Created by Joakim Gyllström on 2015-05-21.
//  Copyright (c) 2015 Joakim Gyllström. All rights reserved.
//

#import "ViewController.h"
@import BSImagePicker;
@import Photos;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showImagePicker:(id)sender {
    ImagePickerViewController *imagePicker = [ImagePickerViewController new];
    [self bs_presentImagePickerController:imagePicker
                                 animated:YES
                                   select:^(PHAsset * __nonnull asset) {
                                       NSLog(@"Selected: %@", asset);
                                   } deselect:^(PHAsset * __nonnull asset) {
                                       NSLog(@"Deselected: %@", asset);
                                   } cancel:^(NSArray * __nonnull assets) {
                                       NSLog(@"Cancel with selections: %@", assets);
                                   } finish:^(NSArray * __nonnull assets) {
                                       NSLog(@"Finish with selections: %@", assets);
                                   } completion:^{
                                       NSLog(@"Finished presenting");
                                   }];
}

@end
