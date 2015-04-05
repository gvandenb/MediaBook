//
//  SettingsVideoViewController.h
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
#import "YTPlayerView.h"
#import "GTLServiceYouTube.h"
#import "GTLQueryYouTube.h"
#import "GTLYouTubeSearchListResponse.h"
#import "GTLYouTubeVideoListResponse.h"
#import "GTLYouTubeSearchResult.h"
#import "GTLYouTubeVideo.h"
#import "SearchResultsTableViewCell.h"
#import "SearchRelatedTableViewCell.h"
#import "GTLYouTubeConstants.h"
#import "PhotoGroup.h"
#import "PhotoBook.h"

@interface SettingsVideoViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, WEPopoverControllerDelegate, UIPopoverControllerDelegate, ColorViewControllerDelegate, UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate, NSURLConnectionDataDelegate, UIPopoverControllerDelegate,YTPlayerViewDelegate> {
    IBOutlet UIButton *homeButton;
    NSInteger imageIndex;
    
}

@property (nonatomic,retain) UIPopoverController *popoverController;
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
@property (nonatomic, retain) IBOutlet YTPlayerView *playerView;
@property (strong, nonatomic) IBOutlet UITextField *textSearchTerm;
@property (strong, nonatomic) IBOutlet UITextField *textSearchTerm1;
@property (strong, nonatomic) IBOutlet UILabel *searchTermLabel;
@property (strong, nonatomic) IBOutlet UILabel *searchResultsLabel;
@property (strong, nonatomic) IBOutlet UILabel *searchRelatedLabel;
@property (strong, nonatomic) IBOutlet UIView* searchResultsView;
@property (strong, nonatomic) IBOutlet UIView* searchSplashView;
@property (strong, nonatomic) IBOutlet UIView* relatedVideosView;
@property (strong, nonatomic) IBOutlet UIButton *addVideoButton;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;
@property (strong, nonatomic) IBOutlet UIButton *prevPageTokenButton;
@property (strong, nonatomic) IBOutlet UIButton *nextPageTokenButton;
@property (strong, nonatomic) IBOutlet NSString *prevPageTokenValue;
@property (strong, nonatomic) IBOutlet NSString *nextPageTokenValue;
@property (strong, nonatomic) IBOutlet UITableView* resultsTableView;
@property (strong, nonatomic) IBOutlet UITableView* relatedTableView;
@property (strong, nonatomic) IBOutlet SearchResultsTableViewCell * resultsTableViewCell;
@property (strong, nonatomic) IBOutlet SearchRelatedTableViewCell* relatedTableViewCell;
@property (strong, nonatomic) IBOutlet UIImageView* resultsImageView;
@property (strong, nonatomic) IBOutlet NSArray* searchResultItems;
@property (strong, nonatomic) IBOutlet NSArray* searchRelatedItems;
@property (nonatomic) NSInteger searchPage;
@property (nonatomic, strong) NSString *joinedString;
@property (nonatomic, strong) GTLYouTubeSearchListResponse *searchListResponse;
@property (nonatomic, retain) GTLServiceYouTube *youTubeService;

- (IBAction)searchButtonTapped:(id)sender;
- (IBAction)searchNextPage:(id)sender;
- (IBAction)searchPrevPage:(id)sender;
- (void) performYouTubeSearch: (NSString *)searchQuery pageToken:(NSString *)pageToken;
- (IBAction)buttonTapped:(id)sender;
//- (IBAction)didTapButton:(id)sender;
- (IBAction)saveButtonTapped:(id)sender;

@end