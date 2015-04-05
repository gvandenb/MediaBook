//
//  SettingsMainViewController.m
//  PictureBook
//
//  Created by greg vandenberg on 2/28/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import "SettingsMainViewController.h"
#import "SettingsPhotoViewController.h"
#import "SettingsVideoViewController.h"

@interface SettingsMainViewController ()

@end

@implementation SettingsMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"ios7background-blurred.png"]];
    //self.photoSettingsView.clipsToBounds = YES;
    self.photoSettingsButton.backgroundColor = [UIColor clearColor];
    self.photoSettingsView.clipsToBounds = YES;
    self.photoSettingsView.layer.cornerRadius = 20;
    self.photoSettingsView.layer.borderWidth = 4;
    self.photoSettingsView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.videoSettingsButton.backgroundColor = [UIColor clearColor];
    self.videoSettingsView.clipsToBounds = YES;
    self.videoSettingsView.layer.cornerRadius = 20;
    self.videoSettingsView.layer.borderWidth = 4;
    self.videoSettingsView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.contentSettingsButton.backgroundColor = [UIColor clearColor];
    self.contentSettingsView.clipsToBounds = YES;
    self.contentSettingsView.layer.cornerRadius = 20;
    self.contentSettingsView.layer.borderWidth = 4;
    self.contentSettingsView.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (IBAction)unwindToHome:(UIStoryboardSegue *)segue {

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)gotoContentSettings:(id)sender {
    
}

- (void)gotoPhotoSettings:(id)sender {
    SettingsPhotoViewController *second = [self.storyboard instantiateViewControllerWithIdentifier:@"settingsView"];
    second.modalTransitionStyle = UIModalPresentationCustom;
    second.transitioningDelegate = self;
    [self presentViewController:second animated:YES completion:nil];
}

- (void)gotoVideoSettings:(id)sender {
    SettingsVideoViewController *second = [self.storyboard instantiateViewControllerWithIdentifier:@"settingsVideoView"];
    second.modalTransitionStyle = UIModalPresentationCustom;
    second.transitioningDelegate = self;
    [self presentViewController:second animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
