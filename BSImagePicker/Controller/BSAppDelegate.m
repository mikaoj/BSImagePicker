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

#import "BSAppDelegate.h"
#import "BSImagePickerController.h"

@interface BSAppDelegate () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) BSImagePickerController *imagePicker;
@property (nonatomic, strong) BSImagePickerController *darkImagePicker;
@property (nonatomic, strong) UIImagePickerController *oldImagePicker;
@property (nonatomic, strong) UIPopoverController *popover;

@end

@implementation BSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    UIViewController *viewController = [[UIViewController alloc] init];
    
    UIButton *pressMe2 = [[UIButton alloc] initWithFrame:CGRectMake(50, 100, 200, 35)];
    [pressMe2 setTitle:@"UIImagePicker" forState:UIControlStateNormal];
    [pressMe2 setTitleColor:viewController.view.tintColor forState:UIControlStateNormal];
    [pressMe2 addTarget:self action:@selector(doUIImagePicker:) forControlEvents:UIControlEventTouchUpInside];
    [viewController.view addSubview:pressMe2];
    
    UIButton *pressMe = [[UIButton alloc] initWithFrame:CGRectMake(50, 200, 200, 35)];
    [pressMe setTitle:@"BSImagePicker" forState:UIControlStateNormal];
    [pressMe setTitleColor:viewController.view.tintColor forState:UIControlStateNormal];
    [pressMe addTarget:self action:@selector(doBSImagePicker:) forControlEvents:UIControlEventTouchUpInside];
    [pressMe setTag:1];
    [viewController.view addSubview:pressMe];
    
    UIButton *pressMe3 = [[UIButton alloc] initWithFrame:CGRectMake(50, 300, 200, 35)];
    [pressMe3 setTitle:@"BSImagePicker Dark" forState:UIControlStateNormal];
    [pressMe3 setTitleColor:viewController.view.tintColor forState:UIControlStateNormal];
    [pressMe3 addTarget:self action:@selector(doBSImagePicker:) forControlEvents:UIControlEventTouchUpInside];
    [pressMe3 setTag:2];
    [viewController.view addSubview:pressMe3];
    
    UIButton *pressMe4 = [[UIButton alloc] initWithFrame:CGRectMake(50, 400, 200, 35)];
    [pressMe4 setTitle:@"BSImagePicker popover" forState:UIControlStateNormal];
    [pressMe4 setTitleColor:viewController.view.tintColor forState:UIControlStateNormal];
    [pressMe4 addTarget:self action:@selector(doBSImagePickerWithPopover:) forControlEvents:UIControlEventTouchUpInside];
    [pressMe4 setTag:1];
    [viewController.view addSubview:pressMe4];
    
    [self setImagePicker:[[BSImagePickerController alloc] init]];
    [self.imagePicker setKeepSelection:YES];
    
    [self setDarkImagePicker:[[BSImagePickerController alloc] init]];
    [self.darkImagePicker.view setTintColor:[UIColor redColor]];
    [self.darkImagePicker.navigationBar setBarTintColor:[UIColor blackColor]];
    [self.darkImagePicker.view setBackgroundColor:[UIColor blackColor]];
    [self.darkImagePicker.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    [self setOldImagePicker:[[UIImagePickerController alloc] init]];
    [self.window setRootViewController:viewController];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)doUIImagePicker:(id)sender
{
    [self.oldImagePicker setDelegate:self];
    
    [self.window.rootViewController presentViewController:self.oldImagePicker animated:YES completion:nil];
}

- (void)doBSImagePicker:(id)sender
{
    BSImagePickerController *imagePicker = nil;
    
    if([sender tag] == 1) {
        imagePicker = self.imagePicker;
    } else {
        imagePicker = self.darkImagePicker;
    }
    
    [self.window.rootViewController presentImagePickerController:imagePicker
                                                        animated:YES
                                                      completion:nil
                                                          toggle:^(ALAsset *asset, BOOL select) {
                                                              if(select) {
                                                                  NSLog(@"Image selected");
                                                              } else {
                                                                  NSLog(@"Image deselected");
                                                              }
                                                          }
                                                          cancel:^(NSArray *assets) {
                                                              NSLog(@"User canceled...!");
                                                              [imagePicker dismissViewControllerAnimated:YES completion:nil];
                                                          }
                                                          finish:^(NSArray *assets) {
                                                              NSLog(@"User finished :)!");
                                                              [imagePicker dismissViewControllerAnimated:YES completion:nil];
                                                          }];
}

- (void)doBSImagePickerWithPopover:(id)sender {
    UIButton *button = (UIButton *)sender;
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:self.imagePicker];
    [self.imagePicker setToggleBlock:^(ALAsset *asset, BOOL select) {
        if(select) {
            NSLog(@"Image selected");
        } else {
            NSLog(@"Image deselected");
        }
    }];
    [self.imagePicker setCancelBlock:^(NSArray *assets) {
        NSLog(@"User canceled...!");
        [popover dismissPopoverAnimated:YES];
    }];
    [self.imagePicker setFinishBlock:^(NSArray *assets) {
        NSLog(@"User finished :)!");
        [popover dismissPopoverAnimated:YES];
    }];
    
    [popover presentPopoverFromRect:button.frame
                             inView:self.window.rootViewController.view
           permittedArrowDirections:UIPopoverArrowDirectionLeft
                           animated:YES];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
