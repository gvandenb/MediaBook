//
//  SettingsVideoViewController.m
//  PictureBook
//
//  Created by greg vandenberg on 1/31/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "SettingsVideoViewController.h"
#import "NonRotatingUIImagePickerController.h"
#import "PhotoBookFeed.h"
#import "PhotoBook.h"
//#import "VideoPopoverViewController.h"
#import "PhotoCollectionViewCell.h"
#import "PhotoCollectionThumbViewCell.h"
#import "VideoBookTableViewCell.h"
#import "CollectionViewController.h"

@interface SettingsVideoViewController () {
    
}
@property (nonatomic, retain) UIPopoverController *popover;
@end

//NSMutableArray *selectedImages;

@implementation SettingsVideoViewController

@synthesize imageView;
@synthesize formView;
@synthesize maskView;
@synthesize btn;
@synthesize picker;
@synthesize popover;
@synthesize photoBookFeed;
@synthesize tableViewObject;
@synthesize progressView;
@synthesize overlayView;
@synthesize urlConnection;
@synthesize activityIndicatorView;
@synthesize tableViewHeightConstraint;
@synthesize previewLabel;
@synthesize saveButton;
@synthesize textBookName;
@synthesize textPageName;
@synthesize previewBookLabel;
@synthesize bookNameView;
@synthesize addPagesView;
@synthesize uploadPhotoBookView;
@synthesize uploadPhotoBookLabel;
@synthesize popoverController;
@synthesize playerView;
@synthesize textSearchTerm;
@synthesize textSearchTerm1;
@synthesize searchTermLabel;
@synthesize searchResultsLabel;
@synthesize searchRelatedLabel;
@synthesize searchResultsView;
@synthesize searchSplashView;
@synthesize relatedVideosView;
@synthesize addVideoButton;
@synthesize resultsTableView;
@synthesize relatedTableView;
@synthesize resultsImageView;
@synthesize searchRelatedItems;
@synthesize searchResultItems;
@synthesize relatedTableViewCell;
@synthesize resultsTableViewCell;
@synthesize searchButton;
@synthesize searchPage;
@synthesize searchListResponse;
@synthesize joinedString;
@synthesize youTubeService;


- (void)viewDidLoad
{
    [super viewDidLoad];
    photoBookFeed = [[PhotoBookFeed alloc] init];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"gaussian_bknd.png"]];
    
    UIDevice *device = [UIDevice currentDevice];
    NSLog(@"UUID: %@", device.identifierForVendor.UUIDString);
    
    //aScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(200,800,600,250)];
    imageIndex = 0;
    
    maskView = [[UIImageView alloc] initWithFrame:imageView.bounds];
    //maskView.image = [UIImage imageNamed: @"mask.png"];
    //maskView.contentMode = UIControlContentHorizontalAlignmentCenter;
    maskView.image = [[UIImage imageNamed: @"mask.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    UIColor *noColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"nocolor.png"]];
    //[maskView setTintColor:[UIColor redColor]];
    [maskView setTintColor:noColor];
    
    [imageView addSubview:maskView];
    [imageView bringSubviewToFront:maskView];
    
    previewLabel.opaque = NO;
    previewLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    previewLabel.textColor = [UIColor whiteColor];
    previewLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    previewLabel.layer.borderWidth = 2.0;
    previewLabel.layer.cornerRadius = 4;
    [previewLabel sizeToFit];
    previewLabel.clipsToBounds = YES;
    
    formView.layer.cornerRadius = 4;
    formView.clipsToBounds = YES;
    addPagesView.layer.cornerRadius = 4;
    addPagesView.clipsToBounds = YES;
    bookNameView.layer.cornerRadius = 4;
    bookNameView.clipsToBounds = YES;
    uploadPhotoBookView.layer.cornerRadius = 4;
    uploadPhotoBookView.clipsToBounds = YES;
    
    btn.layer.cornerRadius = 4;
    btn.clipsToBounds = YES;
    
    textPageName.tag = 1;
    [textPageName addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    textBookName.tag = 99;
    [textBookName addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    textSearchTerm.tag = 3;
    textSearchTerm1.tag = 4;
    //tableViewObject.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableViewObject.allowsMultipleSelectionDuringEditing = NO;
    progressView.hidden = YES;
    //progressView.frame = CGRectMake(0,0,tableViewObject.bounds.size.width, 15);
    overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width)];
    overlayView.backgroundColor = [UIColor colorWithRed:102/255.0 green:182/255.0 blue:204/255.0 alpha:0.5];
    
    [self.view addSubview:overlayView];
    [self.view bringSubviewToFront:overlayView];
    overlayView.hidden = YES;
    // TODO: add label "Uploading Photo Book"
    
    activityIndicatorView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    activityIndicatorView.center=overlayView.center;
    
    [activityIndicatorView startAnimating];
    
    [overlayView addSubview:activityIndicatorView];
    [overlayView bringSubviewToFront:activityIndicatorView];
    uploadPhotoBookLabel.hidden = NO;
    [overlayView addSubview:uploadPhotoBookLabel];
    [overlayView bringSubviewToFront:uploadPhotoBookLabel];
    
    //activityIndicatorView.hidden = YES;
    [self.view bringSubviewToFront:progressView];
    [self adjustHeightOfTableview];
    
    resultsTableView.tag = 1;
    relatedTableView.tag = 2;
    self.prevPageTokenButton.hidden = YES;
    self.nextPageTokenButton.hidden = YES;
    self.searchResultsLabel.hidden = YES;
    
    searchListResponse = [[GTLYouTubeSearchListResponse alloc] init];
    photoBookFeed = [[PhotoBookFeed alloc] init];
    PhotoGroup *photoGroup = [PhotoGroup alloc];
    if ([photoBookFeed.account.photogroups count] <= 0) {
        photoBookFeed.account.photogroups = (NSMutableArray<PhotoGroup>*)[NSMutableArray array];
        [photoBookFeed.account.photogroups insertObject:photoGroup atIndex:0];
    }
    photoGroup = (PhotoGroup *)[photoBookFeed.account.photogroups objectAtIndex:0];
    if ([photoGroup.photobooks count] <= 0) {
        photoGroup.photobooks = (NSMutableArray<PhotoBook>*)[NSMutableArray array];
    }
    
    self.youTubeService = [[GTLServiceYouTube alloc] init];
}

- (void) setupMovie
{
    NSDictionary *playerVars = @{
                                 @"playsinline" : @0,
                                 @"controls" : @0,
                                 @"rel" : @0,
                                 @"showinfo" : @0,
                                 @"iv_load_policy":@3,
                                 @"modestbranding":@1,
                                 };
    NSLog(@"searchResultItems count: %ld", [self.searchResultItems count]);
    GTLYouTubeVideo *searchItem = (GTLYouTubeVideo *)[self.searchResultItems objectAtIndex:0];
    
    GTLYouTubeVideo *video = (GTLYouTubeVideo *)searchItem.identifier;
    NSLog(@"video: %@", video.JSONString);
    NSString *videoURL = [video.JSON valueForKey:@"videoId"];
    NSLog(@"load player video URL: %@", videoURL);
    [self.playerView loadWithVideoId:videoURL playerVars:playerVars];
    
}

#pragma - markup TableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"numberOfRowsInSection");
    NSLog(@"resultItems count %ld", [searchResultItems count]);
    if (tableView.tag == 1) {
        return [searchResultItems count];
    }
    else if (tableView.tag == 2) {
        return [searchRelatedItems count];
    }
    else {
        if ([photoBookFeed.account.photogroups count] <= 0) {
            return 0;
        }
        PhotoGroup *photoGroup = (PhotoGroup *)[photoBookFeed.account.photogroups objectAtIndex:0];
        return [photoGroup.photobooks count];
    }
}

- (IBAction)searchNextPage:(id)sender {
    self.prevPageTokenButton.hidden = NO;
    self.searchPage++;
    [self performYouTubeSearch:textSearchTerm.text pageToken:self.nextPageTokenValue];
}

- (IBAction)searchPrevPage:(id)sender {
    self.searchPage--;
    if (self.searchPage <= 1) {
        self.prevPageTokenButton.hidden = YES;
    }
    [self performYouTubeSearch:textSearchTerm.text pageToken:self.prevPageTokenValue];
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction) searchButtonTapped:(id)sender
{
    NSLog(@"searchButtonTapped");
    self.searchPage = 1;
    self.nextPageTokenButton.hidden = NO;
    
    [self performYouTubeSearch:textSearchTerm.text pageToken:nil];
    
    [self.view endEditing:YES];
}

- (void)performYouTubeSearch:(NSString *)searchQuery pageToken: (NSString *) pageToken {
    NSLog(@"performYouTubeSearch");
    
    // Create a service object for executing queries
    
    //GTLServiceYouTube *service1 = [[GTLServiceYouTube alloc] init];
    // Services which do not require sign-in may need an API key from the
    // API Console
    self.youTubeService.APIKey = @"AIzaSyBq5yC9oIXQ2p11U4H4ppXKdXOE3yO5eBk";
    //service1.APIKey = @"AIzaSyBq5yC9oIXQ2p11U4H4ppXKdXOE3yO5eBk";
    // Create a query
    // queryForVideosListWithPart to get contentDetails
    GTLQueryYouTube *query = [GTLQueryYouTube queryForSearchListWithPart:@"id, snippet"];
    GTLQueryYouTube *query1 = [GTLQueryYouTube queryForVideosListWithPart:@"id, snippet, contentDetails, statistics, player"];
    NSLog(@"SearchQuery: %@", searchQuery);
    query.q = searchQuery;
    query.maxResults = 20;
    //query.order = kGTLYouTubeOrderViewCount;
    query.videoDefinition = kGTLYouTubeVideoDefinitionHigh;
    query.type = @"video";
    if (pageToken != nil) {
        query.pageToken = pageToken;
    }
    NSLog(@"execute performYouTubeSearch query");
    
    // Execute the query
    [self.youTubeService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLYouTubeSearchListResponse *searchList, NSError *error) {
        
        NSLog(@"searchListResponse");
        //self.searchListResponse = searchList;
        
        NSLog(@"search results: %ld", [searchList.items count]);
        // This callback block is run when the fetch completes
        if (error == nil) {
            NSLog(@"No Error");
            
            NSMutableArray *videoIds = [NSMutableArray array];
            [searchList.items enumerateObjectsUsingBlock:^(GTLYouTubeSearchResult *searchItem, NSUInteger idx, BOOL *stop) {
                
                GTLYouTubeVideo *video = (GTLYouTubeVideo *)searchItem.identifier;
                NSString *videoId = [video.JSON valueForKey:@"videoId"];
                [videoIds addObject:videoId];
            }];
            self.joinedString = [videoIds componentsJoinedByString:@","];
            NSLog(@"joinedString: %@", self.joinedString);
            
            query1.identifier = self.joinedString;
            //query1.videoType = @"video";
            //query1.videoDefinition = kGTLYouTubeVideoDefinitionHigh;
            
            [self.youTubeService executeQuery:query1 completionHandler:^(GTLServiceTicket *ticket, GTLYouTubeVideoListResponse *videoList, NSError *error) {
                NSLog(@"success search query");
                
                if (error == nil) {
                    [videoList.items enumerateObjectsUsingBlock:^(GTLYouTubeVideo *videoItem, NSUInteger idx, BOOL *stop) {
                        GTLYouTubeVideo *searchItem = [searchList.items objectAtIndex:idx];
                        videoItem.snippet = searchItem.snippet;
                        videoItem.identifier = searchItem.identifier;
                        
                    }];
                    NSLog(@"%@", searchList.JSONString);
                    NSLog(@"nextPageToken");
                    
                    videoList.nextPageToken = searchList.nextPageToken;
                    NSLog(@"prevPageToken");
                    videoList.prevPageToken = searchList.prevPageToken;
                    NSLog(@"pageInfo");
                    videoList.pageInfo = searchList.pageInfo;
                    NSLog(@"searchResultItems");
                    self.searchResultItems = videoList.items;
                    NSLog(@"nextPageTokenValue JSON");
                    
                    self.nextPageTokenValue = [searchList.JSON valueForKey:@"nextPageToken"];
                    NSLog(@"prevPageTokenValue JSON");
                    
                    self.prevPageTokenValue = [searchList.JSON valueForKey:@"prevPageToken"];
                    NSLog(@"totalResults JSON");
                    
                    NSString *totalResults = [searchList.JSON valueForKeyPath:@"pageInfo.totalResults"];
                    //NSString *pageResults = [searchList valueForKeyPath:@"pageInfo.resultsPerPage"];
                    NSString *searchNumResult = [NSString stringWithFormat:@"%ld", (self.searchPage == 1) ? 1 : ((self.searchPage-1) * 20) + 1];
                    self.searchResultsLabel.text = [NSString stringWithFormat:@"Search Results: %@ - %ld of %@", searchNumResult, (self.searchPage * 20), totalResults];
                    NSLog(@"setupMovie");
                    [self setupMovie];
                    [self.resultsTableView reloadData];
                    self.searchResultsLabel.hidden = NO;
                    NSIndexPath *defaultIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                    [self tableView:resultsTableView  didSelectRowAtIndexPath:defaultIndexPath];
                }
                else {
                    NSLog(@"Error: %@", error.description);
                }
                
            }];
            
            
        }
        else {
            NSLog(@"Error: %@", error.description);
        }
    }];
    
    
}


- (void)performRelatedYouTubeSearch:(NSString *)videoId {
    // Create a service object for executing queries
    // Services which do not require sign-in may need an API key from the
    // API Console
    self.youTubeService.APIKey = @"AIzaSyBq5yC9oIXQ2p11U4H4ppXKdXOE3yO5eBk";
    // Create a query
    GTLQueryYouTube *query = [GTLQueryYouTube queryForSearchListWithPart:@"id, snippet"];
    GTLQueryYouTube *query1 = [GTLQueryYouTube queryForVideosListWithPart:@"id, contentDetails"];
    
    //query.q = searchQuery;
    query.maxResults = 20;
    //query.order = kGTLYouTubeOrderViewCount;
    query.type = @"video";
    query.relatedToVideoId = videoId;
    
    // Execute the query
    [self.youTubeService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLYouTubeSearchListResponse *searchList, NSError *error) {
        //self.searchListResponse = searchList;
        NSLog(@"searchRelatedListResponse");
        // This callback block is run when the fetch completes
        if (error == nil) {
            NSLog(@"No Error");
            
            NSMutableArray *videoIds = [NSMutableArray array];
            [searchList.items enumerateObjectsUsingBlock:^(GTLYouTubeSearchResult *searchItem, NSUInteger idx, BOOL *stop) {
                
                GTLYouTubeVideo *video = (GTLYouTubeVideo *)searchItem.identifier;
                NSString *videoId = [video.JSON valueForKey:@"videoId"];
                [videoIds addObject:videoId];
            }];
            self.joinedString = [videoIds componentsJoinedByString:@","];
            NSLog(@"joinedString: %@", self.joinedString);
            query1.identifier = self.joinedString;
            
            [self.youTubeService executeQuery:query1 completionHandler:^(GTLServiceTicket *ticket, GTLYouTubeVideoListResponse *videoList, NSError *error) {
                NSLog(@"success related search query");
                
                if (error == nil) {
                    [videoList.items enumerateObjectsUsingBlock:^(GTLYouTubeVideo *videoItem, NSUInteger idx, BOOL *stop) {
                        //NSLog(@"idx: %ld", idx);
                        GTLYouTubeVideo *searchItem = [searchList.items objectAtIndex:idx];
                        videoItem.snippet = searchItem.snippet;
                        videoItem.identifier = searchItem.identifier;
                        
                    }];
                    
                    videoList.nextPageToken = searchList.nextPageToken;
                    videoList.prevPageToken = searchList.prevPageToken;
                    videoList.pageInfo = searchList.pageInfo;
                    self.searchRelatedItems = videoList.items;
                    [self.relatedTableView reloadData];
                }
                else {
                    NSLog(@"Error: %@", error.description);
                }
                
            }];
            
            
        }
        else {
            NSLog(@"Error: %@", error.description);
        }
    }];
    [UIView animateWithDuration: 1.0
                     animations:^{
                         self.searchSplashView.alpha = 0.0;
                     }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)formatDuration:(NSString *)duration {
    NSString * newString = [duration stringByReplacingOccurrencesOfString:@"PT" withString:@""];
    NSString * newString1 = [newString stringByReplacingOccurrencesOfString:@"H" withString:@":"];
    NSString * newString2 = [newString1 stringByReplacingOccurrencesOfString:@"M" withString:@":"];
    NSString * newString3 = [newString2 stringByReplacingOccurrencesOfString:@"S" withString:@""];
    NSMutableArray * segments = (NSMutableArray *)[newString3 componentsSeparatedByString:@":"];
    NSString * pad = @"0";
    NSLog(@"segments count: %ld", [segments count]);
    for (int i=1; i<[segments count]; i++) {
        if ([segments[i] length] < 2) {
            if ([segments[i] length] == 0)
                pad = @"00";
            segments[i] = [pad stringByAppendingString:segments[i]];
        }
    }
    // add leading and trailing space
    NSString * result = @" ";
    if ([segments count] == 1) {
        result = [result stringByAppendingString:@":"];
    }
    result = [result stringByAppendingString:[segments componentsJoinedByString:@":"]];
    result = [result stringByAppendingString:@"  "];
    return result;
}

- (void)adjustHeightOfTableview
{
    CGFloat height = self.tableViewObject.contentSize.height;
    NSLog(@"Table height: %f", height);
    CGFloat maxHeight = 350.0f;
    
    // if the height of the content is greater than the maxHeight of
    // total space on the screen, limit the height to the size of the
    // superview.
    
    if (height > maxHeight)
        height = maxHeight;
    
    // now set the height constraint accordingly
    
    [UIView animateWithDuration:0.25 animations:^{
        self.tableViewHeightConstraint.constant = height;
        [self.view setNeedsUpdateConstraints];
    }];
}

#pragma mark - connection Delegate Methods
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    NSLog(@"didSendBodyData: %ld", (long)bytesWritten);
    progressView.progress = ((float)totalBytesWritten / totalBytesExpectedToWrite);
    if (self.progressView.progress == 1) {
        self.progressView.hidden = YES;
        self.overlayView.hidden = YES;
        
    } else {
        self.progressView.hidden = NO;
        self.overlayView.hidden = NO;
    }
    
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Finished");
    //CollectionViewController *main = [self.storyboard instantiateViewControllerWithIdentifier:@"mainView"];
    //[main setupAlbumData];
    //[main.collectionView.collectionViewLayout invalidateLayout];
    
    //self.imageView.image = [UIImage imageWithData:self.downloadedMutableData];
}

- (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
    if (strEncodeData == nil) return nil;
    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

- (void)textFieldDidChange:(UITextField*)selector {
    PhotoGroup *photoGroup = [PhotoGroup alloc];
    PhotoBook *photoBook = [PhotoBook alloc];
    
    if ([photoBookFeed.account.photogroups count] <= 0) {
        photoBookFeed.account.photogroups = (NSMutableArray<PhotoGroup>*)[NSMutableArray array];
        [photoBookFeed.account.photogroups insertObject:photoGroup atIndex:0];
    }
    else {
        photoGroup = (PhotoGroup *)[photoBookFeed.account.photogroups objectAtIndex:0];
    }
    
    if ([photoBookFeed.account.photogroups count] <= 0) {
        photoBookFeed.account.photogroups = (NSMutableArray<PhotoGroup>*)[NSMutableArray array];
    }
    
    if ([photoGroup.photobooks count] <= 0) {
        photoGroup.photobooks = (NSMutableArray<PhotoBook>*)[NSMutableArray array];
    }
    else {
        NSLog(@"TextField: %ld", (long)imageIndex);
        NSLog(@"Selector Text %@", selector.text);
        NSString *videoURL = nil;
        NSRange start = [selector.text rangeOfString:@"v="];
        if (start.location != NSNotFound)
        {
            videoURL = [selector.text substringFromIndex:start.location + start.length];
            if (videoURL.length == 11) {
                NSString *thumbnailString = [NSString stringWithFormat:@"https://i.ytimg.com/vi/%@/mqdefault.jpg", videoURL];
                NSURL *thumbnail = [NSURL URLWithString:thumbnailString];
                NSData *imageData = [NSData dataWithContentsOfURL:thumbnail];
                UIImage *image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
                photoBook = (PhotoBook *)[photoGroup.photobooks objectAtIndex:imageIndex];
                photoBook.image = [self encodeToBase64String:image];
                imageView.image = image;
                NSLog(@"thumbNail: %@", thumbnailString);
                [self.tableViewObject reloadData];
            }
        }
        
        NSLog(@"Selector Tag %ld", (long)selector.tag);
    }
    if (selector.tag == 99) {
        photoGroup.title = selector.text;
    }
    else {
        photoBook.title = selector.text;
        previewLabel.text = selector.text;
    }
    
    
}

- (IBAction)saveButtonTapped:(id)sender
{
    NSLog(@"saveButtonTapped");  // To verify the jsonString.

    self.progressView.hidden = NO;
    self.overlayView.hidden = NO;
    //activityIndicatorView.hidden = NO;
    PhotoGroup *photoGroup = (PhotoGroup *)[photoBookFeed.account.photogroups objectAtIndex:0];
    photoGroup.type = @"Video";
    for (PhotoBook *photoBook in photoGroup.photobooks) {
        photoBook.image = @"";
        photoBook.audio = @"";
        photoBook.color = @"#929292";
    }
    NSString *jsonString = [photoBookFeed toJSONString];
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@", jsonString);  // To verify the jsonString.
    
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://babyphotobook.us/photos/F13CCEBD-E3F4-487E-9856-30F133429DCB"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240];
    [postRequest setHTTPMethod:@"POST"];
    [postRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [postRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [postRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [postRequest setHTTPBody:jsonData];
    
    //NSURLResponse *response = nil;
    //NSError *requestError = nil;
    
    // do our long running process here
    //NSData *returnData = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:&response error:&requestError];
    
    self.urlConnection = [[NSURLConnection alloc] initWithRequest:postRequest delegate:self];
    
    
    
}

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    //CGPoint touchPoint=[gesture locationInView:aScrollView];
    //NSLog(@"singleTapGestureCaptured: %f, %f", touchPoint.x, touchPoint.y);
    //NSUInteger touchedPage = floorf(touchPoint.y / 130);
    //NSLog(@"touchedPage %ld", touchedPage);
    
    //PhotoGroup *photoGroup = [photoBookFeed.account.photogroups objectAtIndex:0];
    //PhotoBook *photoBook = [photoGroup.photobooks objectAtIndex:touchedPage];
    
    //PhotoBookPage *selectedImage = [selectedImages objectAtIndex:touchedPage];
    
    //imageIndex = touchedPage;
    //imageView.image = [self decodeBase64ToImage:photoBook.image];
    //if (photoBook.title != nil) {
    //    textPageName.text = photoBook.title;
    //    previewLabel.text = photoBook.title;
    //}
    //else {
    //    textPageName.text = @"";
    //}
    //if (photoBook.color != nil) {
    //    [maskView setTintColor:[GzColors colorFromHex:photoBook.color]];
    //}
}

#pragma mark -
#pragma mark WEPopoverControllerDelegate implementation

- (void)popoverControllerDidDismissPopover:(WEPopoverController *)thePopoverController {
    //Safe to release the popover here
    self.wePopoverController = nil;
    //self.popoverController = nil;
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)thePopoverController {
    //The popover is automatically dismissed if you click outside it, unless you return NO here
    return YES;
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (IBAction) addVideoToPhotoBook:(id) sender
{
    PhotoGroup *photoGroup = [PhotoGroup alloc];
    PhotoBook *photoBook = [PhotoBook alloc];
    NSLog(@"button tag: %ld", (long)((UIButton*)sender).tag);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:((UIButton*)sender).tag inSection:0];
    SearchResultsTableViewCell *cell = (SearchResultsTableViewCell*)[self.resultsTableView cellForRowAtIndexPath:indexPath];
    //cell.backgroundColor = [UIColor greenColor];
    
    
    if ([photoBookFeed.account.photogroups count] <= 0) {
        photoBookFeed.account.photogroups = (NSMutableArray<PhotoGroup>*)[NSMutableArray array];
    }
    else {
        photoGroup = (PhotoGroup *)[photoBookFeed.account.photogroups objectAtIndex:0];
    }
    if ([photoGroup.photobooks count] <= 0) {
        photoGroup.photobooks = (NSMutableArray<PhotoBook>*)[NSMutableArray array];
    }
    
    photoBook.image = [self encodeToBase64String:cell.imageView.image];
    photoBook.video = cell.resultsVideoUrlLabel.text;
    photoBook.title = cell.resultsVideoTitleLabel.text;
    [photoGroup.photobooks addObject:photoBook];
    [photoBookFeed.account.photogroups insertObject:photoGroup atIndex:0];
    [self.tableViewObject reloadData];
    if (self.tableViewObject.contentSize.height > self.tableViewObject.frame.size.height) {
        [self.tableViewObject setContentOffset:CGPointMake(0, self.tableViewObject.contentSize.height - self.tableViewObject.frame.size.height)];
    }
    [self adjustHeightOfTableview];
}

- (IBAction) addRelatedVideoToPhotoBook:(id)sender
{

    PhotoGroup *photoGroup = [PhotoGroup alloc];
    PhotoBook *photoBook = [PhotoBook alloc];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:((UIButton*)sender).tag inSection:0];
    SearchRelatedTableViewCell *cell = (SearchRelatedTableViewCell*)[self.relatedTableView cellForRowAtIndexPath:indexPath];
    
    if ([photoBookFeed.account.photogroups count] <= 0) {
        photoBookFeed.account.photogroups = (NSMutableArray<PhotoGroup>*)[NSMutableArray array];
    }
    else {
        photoGroup = (PhotoGroup *)[photoBookFeed.account.photogroups objectAtIndex:0];
    }
    if ([photoGroup.photobooks count] <= 0) {
        photoGroup.photobooks = (NSMutableArray<PhotoBook>*)[NSMutableArray array];
    }
    
    photoBook.image = [self encodeToBase64String:cell.relatedImageView.image];
    photoBook.video = cell.relatedVideoUrlLabel.text;
    photoBook.title = cell.relatedVideoTitleLabel.text;
    [photoGroup.photobooks addObject:photoBook];
    [photoBookFeed.account.photogroups insertObject:photoGroup atIndex:0];
    [self.tableViewObject reloadData];
    if (self.tableViewObject.contentSize.height > self.tableViewObject.frame.size.height) {
        [self.tableViewObject setContentOffset:CGPointMake(0, self.tableViewObject.contentSize.height - self.tableViewObject.frame.size.height)];
    }
    [self adjustHeightOfTableview];
}

- (IBAction)buttonTapped:(id)sender {
    [self tableView:tableViewObject didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:((UIButton*)sender).tag inSection:0]];
    if (!self.wePopoverController) {
        imageIndex = ((UIButton*)sender).tag;
        ColorViewController *contentViewController = [[ColorViewController alloc] init];
        contentViewController.delegate = self;
        self.wePopoverController = [[WEPopoverController alloc] initWithContentViewController:contentViewController];
        self.wePopoverController.delegate = self;
        //self.wePopoverController.passthroughViews = [NSArray arrayWithObject:self.navigationController.navigationBar];
        
        [self.wePopoverController presentPopoverFromRect:self.btn.frame
                                                  inView:self.view
                                permittedArrowDirections:(UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown)
                                                animated:YES];
        
    } else {
        [self.wePopoverController dismissPopoverAnimated:YES];
        self.wePopoverController = nil;
    }
    
}

-(void) colorPopoverControllerDidSelectColor:(NSString *)hexColor{
    //self.view.backgroundColor = [GzColors colorFromHex:hexColor];
    //[self.view setNeedsDisplay];
    //PhotoBookPage *photoBookPage = [selectedImages objectAtIndex:imageIndex];
    PhotoGroup *photoGroup = (PhotoGroup *)[photoBookFeed.account.photogroups objectAtIndex:0];
    NSLog(@"colorPopoverControllerDidSelectColor: %ld", (long)imageIndex);
    PhotoBook *photoBook = (PhotoBook *)[photoGroup.photobooks objectAtIndex:imageIndex];
    
    UIColor *uiColor = [GzColors colorFromHex:hexColor];
    [maskView setTintColor:uiColor];
    photoBook.color = hexColor;
    [self.tableViewObject reloadData];
    [self.wePopoverController dismissPopoverAnimated:YES];
    self.wePopoverController = nil;
}

#pragma - markup TableView Delegate Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    if (tableView.tag == 1) {
        static NSString *simpleTableIdentifier = @"resultCell";
        GTLYouTubeVideo *videoItem = [self.searchResultItems objectAtIndex:indexPath.row];
        
        SearchResultsTableViewCell *cell = (SearchResultsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell != nil) {
            cell.backgroundColor = [UIColor whiteColor];
        }
        GTLYouTubeVideo *video = (GTLYouTubeVideo *)videoItem.identifier;
        GTLYouTubeVideo *snippet = (GTLYouTubeVideo *)videoItem.snippet;
        GTLYouTubeVideo *contentDetails = (GTLYouTubeVideo *)videoItem.contentDetails;
        NSLog(@"Cell VideoId %@",[video.JSON valueForKey:@"videoId"]);
        NSString *thumbnailString = [snippet.JSON valueForKeyPath:@"thumbnails.medium.url"];
        NSURL *thumbnail = [NSURL URLWithString:thumbnailString];
        NSData *imageData = [NSData dataWithContentsOfURL:thumbnail];
        UIImage *image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
        NSString *duration = [contentDetails.JSON valueForKey:@"duration"];
        cell.resultsVideoDurationLabel.text = [self formatDuration:duration];
        cell.resultsVideoTitleLabel.text = [snippet.JSON valueForKey:@"title"];
        cell.resultsVideoDescriptionLabel.text = [snippet.JSON valueForKey:@"description"];
        cell.resultsVideoUrlLabel.text =
        [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@",[video.JSON valueForKey:@"videoId"]];
        NSLog(@"resultsButton.tag: %ld", indexPath.row);
        cell.resultsAddButton.tag = indexPath.row;
        cell.imageView.image = image;
        return cell;
    }
    else if (tableView.tag == 2) {
        static NSString *simpleTableIdentifier = @"relatedCell";
        GTLYouTubeVideo *videoItem = [self.searchRelatedItems objectAtIndex:indexPath.row];
        
        SearchRelatedTableViewCell *cell = (SearchRelatedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell != nil) {
            cell.backgroundColor = [UIColor whiteColor];
        }
        GTLYouTubeVideo *video = (GTLYouTubeVideo *)videoItem.identifier;
        GTLYouTubeVideo *snippet = (GTLYouTubeVideo *)videoItem.snippet;
        GTLYouTubeVideo *contentDetails = (GTLYouTubeVideo *)videoItem.contentDetails;
        NSLog(@"Related Cell VideoId %@",[video.JSON valueForKey:@"videoId"]);
        cell.relatedVideoUrlLabel.text = [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@",[video.JSON valueForKey:@"videoId"]];
        NSString *thumbnailString = [snippet.JSON valueForKeyPath:@"thumbnails.medium.url"];
        NSURL *thumbnail = [NSURL URLWithString:thumbnailString];
        NSData *imageData = [NSData dataWithContentsOfURL:thumbnail];
        UIImage *image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
        NSString *duration = [contentDetails.JSON valueForKey:@"duration"];
        cell.relatedVideoTitleLabel.text = [snippet.JSON valueForKey:@"title"];
        cell.relatedVideoPublisherLabel.text = [snippet.JSON valueForKey:@"channelTitle"];
        cell.relatedImageView.image = image;
        cell.relatedVideoDurationLabel.text = [self formatDuration:duration];
        cell.relatedAddButton.tag = indexPath.row;

        return cell;
    }
    else {
        PhotoGroup *photoGroup = (PhotoGroup *)[photoBookFeed.account.photogroups objectAtIndex:0];
        PhotoBook *photoBook = (PhotoBook *)[photoGroup.photobooks objectAtIndex:indexPath.row];
        
        static NSString *simpleTableIdentifier = @"vbtvCell";
        
        VideoBookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        //UIButton *selectedColor = [[UIButton alloc] initWithFrame:CGRectMake(415, 40, 70, 70)];
        NSLog(@"cell for added video");
        if (cell == nil) {

            //UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(370, 10, 160, 30) ];
            cell = [[VideoBookTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
            cell.resultsImageView.image = [self decodeBase64ToImage:photoBook.image];
            cell.resultsVideoTitleTextField.text = photoBook.title;
            cell.resultsVideoUrlLabel.text = photoBook.video;
            
//            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//            [button setTitle:@"Select Color" forState:UIControlStateNormal];
//            [button addTarget:self
//                       action:@selector(buttonTapped:)
//             forControlEvents:UIControlEventTouchDown];
//            [cell.contentView addSubview:button];
//            cell.resultsVideoTitleTextField.tag = indexPath.row;
//            cell.resultsVideoUrlLabel.tag = indexPath.row;
//            button.tag = indexPath.row;
//            selectedColor.tag = indexPath.row;
//            UIColor *noColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"nocolor.png"]];
//            selectedColor.backgroundColor = noColor;
//            
//            [cell.contentView addSubview:selectedColor];
            
        }
        else {
            NSLog(@"cell is not null.");
            cell.resultsImageView.image = [self decodeBase64ToImage:photoBook.image];
            //cell.contentView. .text = photoBook.video;
            cell.resultsVideoTitleTextField.text = photoBook.title;
            cell.resultsVideoUrlLabel.text = photoBook.video;

        }
//        
//        [selectedColor addTarget:self
//                          action:@selector(buttonTapped:)
//                forControlEvents:UIControlEventTouchDown];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        NSLog(@"photobook.color: %@", photoBook.color);
//        if (photoBook.color != nil) {
//            NSLog(@"Setting background color.");
//            selectedColor.backgroundColor = [GzColors colorFromHex:photoBook.color];
//            [cell.contentView addSubview:selectedColor];
//        }
//        
//        CGSize itemSize = CGSizeMake(100, 100);
//        //UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
//        UIGraphicsBeginImageContext(itemSize);
//        CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
//        [cell.resultsImageView.image drawInRect:imageRect];
//        cell.resultsImageView.contentMode = UIViewContentModeScaleAspectFill;
//        cell.resultsImageView.clipsToBounds = YES;
//        cell.resultsImageView.image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 1) {
        return 100;
    }
    else if (tableView.tag == 2) {
        return 135;
    }
    else {
        return 103;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
    if (tableView.tag == 1) {
        GTLYouTubeVideo *searchItem = [self.searchResultItems objectAtIndex:indexPath.row];
        GTLYouTubeVideo *video = (GTLYouTubeVideo *)searchItem.identifier;
        NSLog(@"Selected video id: %@", [video.JSON valueForKey:@"videoId"]);
        [self.playerView cueVideoById:[video.JSON valueForKey:@"videoId"] startSeconds:0 suggestedQuality:kYTPlaybackQualityHD720];
        [self.playerView playVideo];
        [self performRelatedYouTubeSearch:[video.JSON valueForKey:@"videoId"]];
    }
    else if (tableView.tag == 2) {
        GTLYouTubeVideo *searchItem = [self.searchRelatedItems objectAtIndex:indexPath.row];
        GTLYouTubeVideo *video = (GTLYouTubeVideo *)searchItem.identifier;
        NSLog(@"Selected video id: %@", [video.JSON valueForKey:@"videoId"]);
        [self.playerView cueVideoById:[video.JSON valueForKey:@"videoId"] startSeconds:0 suggestedQuality:kYTPlaybackQualityHD720];
        [self.playerView playVideo];
    }
    else {
        PhotoGroup *photoGroup = (PhotoGroup *)[photoBookFeed.account.photogroups objectAtIndex:0];
        PhotoBook *photoBook = (PhotoBook *)[photoGroup.photobooks objectAtIndex:indexPath.row];
        for (UITableViewCell *cell in tableViewObject.visibleCells) {
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIColor* lightColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0) blue:(220/255.0) alpha:1];
        
        cell.contentView.backgroundColor = lightColor;
        imageIndex = indexPath.row;
        //imageView.image = [self decodeBase64ToImage:photoBook.image];
        if (photoBook.title != nil) {
            textPageName.text = photoBook.title;
            previewLabel.text = photoBook.title;
        }
        else {
            textPageName.text = @"";
        }
        if (photoBook.color != nil) {
            [maskView setTintColor:[GzColors colorFromHex:photoBook.color]];
        }
        else {
            UIColor *noColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"nocolor.png"]];
            [maskView setTintColor:noColor];
        }
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.tag != 3 && textField.tag != 4) {
        [self animateTextField: textField up: YES];
        NSLog(@"textFieldDidBeginEditing");
        textField.placeholder = nil;
        NSLog(@"textField.tag: %ld", (long)textField.tag);
        if ([textField.text isEqual:@""]) {
            previewLabel.text = @"Page Title";
        }
        [self tableView:tableViewObject didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag inSection:0]];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == 3) {
        [self searchButtonTapped:nil];
    }
    else if (textField.tag == 4) {
        textSearchTerm.text = textSearchTerm1.text;
        [self searchButtonTapped:nil];
    }
    else {
        [self animateTextField: textField up: NO];
        NSLog(@"textFieldDidEndEditing");
        if ([textField.text isEqual:@""]) {
            textField.placeholder = @"Enter Page Title";
        }
        else {
            textField.placeholder = nil;
        }
    }
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    // TODO: fix this keyboard adjustment
    int movementDistance = 0; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:textField.tag inSection:0];
    UITableViewCell *cell = [tableViewObject cellForRowAtIndexPath:indexPath];
    
    const float cellFrameOriginY = cell.frame.origin.y;
    const float cellFrameSizeHeight = cell.frame.size.height;
    const float topOfKeyboard = self.view.frame.size.width - 352;
    const float tableViewOriginY = tableViewObject.frame.origin.y;
    const float textFieldLocation = cellFrameOriginY + cellFrameSizeHeight + tableViewOriginY;
    
    if (textFieldLocation > topOfKeyboard) {
        movementDistance = textFieldLocation - topOfKeyboard;
    }
    int movement = (up ? -movementDistance : movementDistance);
    
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, movement, 0);
    [UIView commitAnimations];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        NSLog(@"Delete cell");
        PhotoGroup *photoGroup = (PhotoGroup *)[photoBookFeed.account.photogroups objectAtIndex:0];
        [photoGroup.photobooks removeObjectAtIndex:indexPath.row];
        UITableViewCell *tableViewCell = [tableViewObject cellForRowAtIndexPath:indexPath];
        for (UIView *subView in tableViewCell.contentView.subviews) {
            if ([subView isKindOfClass:[UITextField class]]) {
                UITextField *textField = (UITextField *)subView;
                textField.text = nil;
                textField.placeholder = @"Enter Page Title";
            }
        }
        tableViewCell.contentView.backgroundColor = [UIColor whiteColor];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        for (UITableViewCell *cell in tableViewObject.visibleCells) {
            NSIndexPath *indexPath = [tableViewObject indexPathForCell:cell];
            for (UIView *subView in cell.contentView.subviews) {
                NSLog(@"After delete: %ld", (long)indexPath.row);
                NSLog(@"Subview class: %@", [subView class]);
                subView.tag = indexPath.row;
            }
        }
        [self.tableViewObject reloadData];
        [self adjustHeightOfTableview];

        
    }
}

@end