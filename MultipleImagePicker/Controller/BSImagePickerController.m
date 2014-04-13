//
//  BSImagePickerController.m
//  MultipleImagePicker
//
//  Created by Joakim Gyllström on 2014-04-13.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSImagePickerController.h"
#import "BSImageSelectionController.h"

@interface BSImagePickerController ()

@end

@implementation BSImagePickerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        BSImageSelectionController *imagePicker = [[BSImageSelectionController alloc] init];
        
        [self pushViewController:imagePicker animated:NO];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
