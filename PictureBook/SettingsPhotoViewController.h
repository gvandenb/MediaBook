//
//  SettingsViewController.h
//  PictureBook
//
//  Created by greg vandenberg on 1/31/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "WEPopoverController.h"
#import "ColorViewController.h"
#import "PhotoBookFeed.h"
#import "PhotoGroup.h"
#import "PhotoBook.h"

@interface SettingsPhotoViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, WEPopoverControllerDelegate, UIPopoverControllerDelegate, ColorViewControllerDelegate, UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate, NSURLConnectionDataDelegate> {
    IBOutlet UIButton *homeButton;
    NSInteger imageIndex;
    
}

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (strong, nonatomic) NSURLConnection *urlConnection;
@property (strong, nonatomic) IBOutlet UITableView *tableViewObject;
@property (strong, nonatomic) IBOutlet UIImageView* imageView;
@property (strong, nonatomic) IBOutlet UIView* formView;
@property (strong, nonatomic) IBOutlet UIView* bookNameView;
@property (strong, nonatomic) IBOutlet UIView* addPagesView;
@property (strong, nonatomic) IBOutlet UIView* uploadPhotoBookView;
@property (strong, nonatomic) IBOutlet UIView* overlayView;
@property (strong, nonatomic) UIActivityIndicatorView* activityIndicatorView;
@property (strong, nonatomic) IBOutlet UIImageView* maskView;
//@property (strong, nonatomic) NSMutableArray* selectedImages;
//@property (strong, nonatomic) IBOutlet UIScrollView* aScrollView;
@property (strong, nonatomic) IBOutlet UIImagePickerController* picker;
@property (strong, nonatomic) IBOutlet UIButton *btn;
@property (strong, nonatomic) IBOutlet UILabel *previewLabel;
@property (strong, nonatomic) IBOutlet UILabel *uploadPhotoBookLabel;
@property (strong, nonatomic) IBOutlet UILabel *previewBookLabel;
@property (strong, nonatomic) IBOutlet UITextField *textPageName;
@property (strong, nonatomic) IBOutlet UITextField *textBookName;
@property (strong, nonatomic) IBOutlet UIPickerView *soundPicker;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (nonatomic, strong) WEPopoverController *wePopoverController;
@property (nonatomic, strong) PhotoBookFeed *photoBookFeed;

- (IBAction)buttonTapped:(id)sender;
//- (IBAction)didTapButton:(id)sender;
- (IBAction)saveButtonTapped:(id)sender;

@end