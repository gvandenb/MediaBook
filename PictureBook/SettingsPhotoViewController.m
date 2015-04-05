//
//  SettingsViewController.m
//  PictureBook
//
//  Created by greg vandenberg on 1/31/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "SettingsPhotoViewController.h"
#import "NonRotatingUIImagePickerController.h"
#import "PhotoBookFeed.h"
#import "PhotoBook.h"
#import "PhotoGroup.h"

@interface SettingsPhotoViewController () {
    
}
@property (nonatomic, retain) UIPopoverController *popover;
@end

//NSMutableArray *selectedImages;

@implementation SettingsPhotoViewController

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


- (void)viewDidLoad
{
    [super viewDidLoad];
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

    tableViewObject.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    
    //UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    //[aScrollView addGestureRecognizer:singleTap];
}

- (void)adjustHeightOfTableview
{
    CGFloat height = self.tableViewObject.contentSize.height;
    CGFloat maxHeight = 450.0f;
    
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
    //self.imageView.image = [UIImage imageWithData:self.downloadedMutableData];
}

#pragma mark -
#pragma mark IBActions

- (IBAction) didTapButton:(id)sender
{
    
    //UIButton *button = (UIButton *)sender;
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    [picker.view setFrame:CGRectMake(0,0,500, 700)];
    //picker.view.frame = CGRectMake(0,0,700, 700);
    [picker setPreferredContentSize:CGSizeMake(500, 700)];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    NSLog(@"image picker popover");
    popover = [[UIPopoverController alloc] initWithContentViewController:picker];
    //popover.popoverContentSize = CGSizeMake(320.0, 1280.0);
    [popover setPopoverContentSize:CGSizeMake(500, 700) animated:YES];

    [popover presentPopoverFromRect:CGRectMake(0, 20, 500, 700) inView:self.view permittedArrowDirections:0 animated:YES];
    //[popover presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:0 animated:YES];
    
}

- (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
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
    photoGroup = (PhotoGroup *)[photoBookFeed.account.photogroups objectAtIndex:0];
    if (selector.tag == 99) {
        photoGroup.title = selector.text;
        photoGroup.type = @"Default";
    }
    else {
        photoBook = (PhotoBook *)[photoGroup.photobooks objectAtIndex:imageIndex];
        photoBook.title = selector.text;
        photoBook.audio = @"";
        photoBook.video = @"";
        previewLabel.text = selector.text;
    }

    //[self.tableViewObject reloadData];
}

- (IBAction)saveButtonTapped:(id)sender
{
    self.progressView.hidden = NO;
    self.overlayView.hidden = NO;
    //activityIndicatorView.hidden = NO;
    
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
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)thePopoverController {
    //The popover is automatically dismissed if you click outside it, unless you return NO here
    return YES;
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (void) imagePickerController:(UIImagePickerController *)picker
         didFinishPickingImage:(UIImage *)image
                   editingInfo:(NSDictionary *)editingInfo
{
    //PhotoBookPage *photoBookPage = [PhotoBookPage alloc];
    //photoBookPage.image = image;
    PhotoGroup *photoGroup = [PhotoGroup alloc];
    PhotoBook *photoBook = [PhotoBook alloc];
    photoBook.image = [self encodeToBase64String:image];
    
    if ([photoBookFeed.account.photogroups count] <= 0) {
        photoBookFeed.account.photogroups = (NSMutableArray<PhotoGroup>*)[NSMutableArray array];
    }
    else {
        photoGroup = (PhotoGroup *)[photoBookFeed.account.photogroups objectAtIndex:0];
    }
    if ([photoGroup.photobooks count] <= 0) {
        photoGroup.photobooks = (NSMutableArray<PhotoBook>*)[NSMutableArray array];
    }
    
    [photoGroup.photobooks addObject:photoBook];
    [photoBookFeed.account.photogroups insertObject:photoGroup atIndex:0];
    //[selectedImages addObject:photoBookPage];
    imageIndex = [photoGroup.photobooks count]-1;
    textPageName.text = @"";
    previewLabel.text = @"Page Title";
    NSLog(@"selectedImages length: %lu", (unsigned long)[photoGroup.photobooks count]);
    NSLog(@"visible cells: %lu", (unsigned long)[tableViewObject visibleCells].count);
    NSLog(@"%@", photoGroup.photobooks);
    imageView.image = image;
    
    [self.tableViewObject reloadData];
    if (self.tableViewObject.contentSize.height > self.tableViewObject.frame.size.height) {
        [self.tableViewObject setContentOffset:CGPointMake(0, self.tableViewObject.contentSize.height - self.tableViewObject.frame.size.height)];
    }
    [self adjustHeightOfTableview];
    [popover dismissPopoverAnimated:YES];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
    NSLog(@"numberOfRowsInSection");
    if ([photoBookFeed.account.photogroups count] <= 0) {
        return 0;
    }
    PhotoGroup *photoGroup = (PhotoGroup *)[photoBookFeed.account.photogroups objectAtIndex:0];
    return [photoGroup.photobooks count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    PhotoGroup *photoGroup = (PhotoGroup *)[photoBookFeed.account.photogroups objectAtIndex:0];
    PhotoBook *photoBook = (PhotoBook *)[photoGroup.photobooks objectAtIndex:indexPath.row];
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    UIButton *selectedColor = [[UIButton alloc] initWithFrame:CGRectMake(415, 40, 70, 70)];
    
    if (cell == nil) {
        UITextField *pageTextField = [[UITextField alloc] initWithFrame:CGRectMake(130, 10, 250, 30)];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(370, 10, 160, 30) ];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        
        pageTextField.borderStyle = UITextBorderStyleRoundedRect;
        [pageTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        pageTextField.backgroundColor = [UIColor whiteColor];
        pageTextField.placeholder = @"Enter Page Title";
        pageTextField.keyboardType = UIKeyboardTypeDefault;
        pageTextField.returnKeyType = UIReturnKeyDone;
        [pageTextField setEnabled: YES];
        pageTextField.delegate = self;
        [cell.contentView addSubview:pageTextField];
        NSLog(@"Adding pageTextField: %@", pageTextField.text);
        
        
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:@"Select Color" forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(buttonTapped:)
         forControlEvents:UIControlEventTouchDown];
        [cell.contentView addSubview:button];
        pageTextField.tag = indexPath.row;
        button.tag = indexPath.row;
        selectedColor.tag = indexPath.row;
        UIColor *noColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"nocolor.png"]];
        selectedColor.backgroundColor = noColor;
        
        
        [cell.contentView addSubview:selectedColor];
        
    }
    else {
        NSLog(@"cell is not null.");
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSLog(@"photobook.color: %@", photoBook.color);
    if (photoBook.color != nil) {
        NSLog(@"Setting background color.");
        selectedColor.backgroundColor = [GzColors colorFromHex:photoBook.color];
        [cell.contentView addSubview:selectedColor];
    }
    [selectedColor addTarget:self
                      action:@selector(buttonTapped:)
            forControlEvents:UIControlEventTouchDown];
    cell.imageView.image = [self decodeBase64ToImage:photoBook.image];
    CGSize itemSize = CGSizeMake(100, 100);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
    PhotoGroup *photoGroup = (PhotoGroup *)[photoBookFeed.account.photogroups objectAtIndex:0];
    PhotoBook *photoBook = (PhotoBook *)[photoGroup.photobooks objectAtIndex:indexPath.row];
    for (UITableViewCell *cell in tableViewObject.visibleCells) {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIColor* lightColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0) blue:(220/255.0) alpha:1];

    cell.contentView.backgroundColor = lightColor;
    imageIndex = indexPath.row;
    imageView.image = [self decodeBase64ToImage:photoBook.image];
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

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self animateTextField: textField up: YES];
    NSLog(@"textFieldDidBeginEditing");
    textField.placeholder = nil;
    NSLog(@"textField.tag: %ld", (long)textField.tag);
    if ([textField.text isEqual:@""]) {
        previewLabel.text = @"Page Title";
    }
    [self tableView:tableViewObject didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag inSection:0]];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self animateTextField: textField up: NO];
    NSLog(@"textFieldDidEndEditing");
    if ([textField.text isEqual:@""]) {
        textField.placeholder = @"Enter Page Title";
    }
    else {
        textField.placeholder = nil;
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
        
    }
}

@end