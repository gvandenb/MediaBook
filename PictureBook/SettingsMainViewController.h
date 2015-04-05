//
//  SettingsMainViewController.h
//  PictureBook
//
//  Created by greg vandenberg on 2/28/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsMainViewController : UIViewController<UIViewControllerTransitioningDelegate>

@property (nonatomic, retain) IBOutlet UIButton *photoSettingsButton;
@property (nonatomic, retain) IBOutlet UIButton *videoSettingsButton;
@property (nonatomic, retain) IBOutlet UIButton *contentSettingsButton;
@property (nonatomic, retain) IBOutlet UIView *photoSettingsView;
@property (nonatomic, retain) IBOutlet UIView *videoSettingsView;
@property (nonatomic, retain) IBOutlet UIView *contentSettingsView;
@property (nonatomic, retain) IBOutlet UILabel *photoSettingsLabel;
@property (nonatomic, retain) IBOutlet UILabel *videoSettingsLabel;
@property (nonatomic, retain) IBOutlet UILabel *contentSettingsLabel;
@property (nonatomic, retain) IBOutlet UIButton *homeButton;

- (IBAction)gotoPhotoSettings:(id)sender;
- (IBAction)gotoVideoSettings:(id)sender;
- (IBAction)gotoContentSettings:(id)sender;
- (IBAction)unwindToHome:(UIStoryboardSegue *)segue;

@end
