//
//  BHViewController.m
//  PictureBook
//
//  Created by greg vandenberg on 1/11/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import "CollectionViewController.h"
#import "PhotoAlbumLayout.h"
#import "AlbumPhotoCell.h"
#import "Album.h"
#import "PhotoGroup.h"
#import "PhotoBook.h"
#import "Photo.h"
#import "AlbumTitleReusableView.h"
#import "ColorBookViewController.h"
#import "PhotoBookViewController.h"
#import "SettingsPhotoViewController.h"
#import "SettingsMainViewController.h"
#import "JSONModelLib.h"
#import "PhotoBookFeed.h"
#import "AudioController.h"
#import "RDPresentationAnimator.h"
#import "VideoViewController.h"

static NSString * const PhotoCellIdentifier = @"PhotoCell";
static NSString * const AlbumTitleIdentifier = @"AlbumTitle";

@protocol BHViewControllerDelegate <NSObject>

@end

@interface CollectionViewController () {
    PhotoBookFeed* _feed;
    
}
@property (strong,nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic, readwrite) AudioController *audioController;
@property (nonatomic, strong) NSMutableArray *albums;
@property (nonatomic, strong) Album *selectedAlbum;
@property (nonatomic, strong) IBOutlet PhotoAlbumLayout *photoAlbumLayout;
@property (nonatomic, strong) NSOperationQueue *thumbnailQueue;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSMutableDictionary *thumbnailDict;

-(void) setAudioController:(AudioController *)audioController;

@end

@implementation CollectionViewController {
    BOOL isDeletionModeActive;
}

- (IBAction)unwindToHome:(UIStoryboardSegue *)segue {
    NSString *controllerName = NSStringFromClass([segue.sourceViewController class]);
    NSLog(@"ControllerName: %@", controllerName);
    if ([controllerName isEqualToString:@"SectionViewController"]) {
        [segue.sourceViewController setImageIndex:0];
    }
    if ([controllerName isEqualToString:@"VideoViewController"]) {
        [self muteAudio:nil];
    }
    if ([controllerName isEqualToString:@"SettingsMainViewController"]) {
        NSLog(@"Fetch album data.");
        [self setupAlbumData];
        [self.collectionView reloadData];
    }
}

-(id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    RDPresentationAnimator *animator = [RDPresentationAnimator new];
    animator.isPresenting = YES;
    animator.senderFrame = self.button.frame;
    return animator;
}


-(id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    NSLog(@"dismissed delegate called");
    RDPresentationAnimator *animator = [RDPresentationAnimator new];
    animator.isPresenting = NO;
    animator.senderFrame = self.button.frame;
    return animator;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isMuted = NO;
    self.audioController = [[AudioController alloc] init];
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"ios7background-blurred.png"]];
    self.thumbnailDict = [NSMutableDictionary dictionaryWithCapacity:1];
    self.albums = [NSMutableArray array];
    
    settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.height-90,20, 70, 70)];
    settingsButton.layer.shadowColor = [UIColor whiteColor].CGColor;
    settingsButton.layer.shadowRadius = 3.0f;
    settingsButton.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);


    [settingsButton setBackgroundImage:[UIImage imageNamed:@"settings_icon1.png"] forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(navigateSettings:) forControlEvents:UIControlEventTouchUpInside];
    muteButton = [[UIButton alloc] initWithFrame:CGRectMake(20,20, 70, 70)];
    [muteButton setBackgroundImage:[UIImage imageNamed:@"audio.png"] forState:UIControlStateNormal];
    [muteButton addTarget:self action:@selector(muteAudio:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:muteButton];
    [self.view addSubview:settingsButton];
    
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;

    [self.collectionView registerClass:[AlbumPhotoCell class]
            forCellWithReuseIdentifier:PhotoCellIdentifier];
    
    [self.collectionView registerClass:[AlbumTitleReusableView class]
            forSupplementaryViewOfKind:BHPhotoAlbumLayoutAlbumTitleKind
                   withReuseIdentifier:AlbumTitleIdentifier];
    
    [self setupAlbumData];

    [self.audioController tryPlayMusic];
    
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 748, self.view.bounds.size.width, 20)];
    [self.pageControl setNumberOfPages:[self getTotalPageCount]];
    [self.pageControl setBackgroundColor:[UIColor colorWithRed:5.0/255 green:142.0/255 blue:187.0/255 alpha:0.6]];
    self.pageControl.pageIndicatorTintColor = [UIColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1.0];
    
    if ([self getTotalPageCount] > 1) {
        [self.view addSubview:self.pageControl];
    }
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(activateDeletionMode:)];
    longPress.delegate = self;
    [self.collectionView addGestureRecognizer:longPress];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endDeletionMode:)];
    tap.delegate = self;
    [self.collectionView addGestureRecognizer:tap];
    
    self.thumbnailQueue = [[NSOperationQueue alloc] init];
    self.thumbnailQueue.maxConcurrentOperationCount = 3;
    
}

- (NSInteger) getTotalPageCount {
    NSInteger columnCount = [self.collectionView numberOfSections] / 3;
    if ([self.collectionView numberOfSections] % 3) columnCount++;
    NSInteger pages = columnCount / 4;
    if (columnCount % 4) pages++;
    return pages;
}

- (void) deleteAlbumData {
    NSString *baseURLStr = @"http://babyphotobook.us/photos/F13CCEBD-E3F4-487E-9856-30F133429DCB";
    //NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:baseURLStr]];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:baseURLStr]];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"DELETE"];
    //NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
    NSString *body = @"bodyParam1=BodyValue1&bodyParam2=BodyValue2";
    [urlRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection
     sendAsynchronousRequest:urlRequest
     queue:queue
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error) {
         
         if ([data length] >0  &&
             error == nil){
             NSString *html = [[NSString alloc] initWithData:data
                                                    encoding:NSUTF8StringEncoding];
             NSLog(@"HTML = %@", html);
         }
     }];
}

- (void) setupAlbumData {
    self.albums = [NSMutableArray array];
    UIDevice *device = [UIDevice currentDevice];
    NSLog(@"UUID: %@", device.identifierForVendor.UUIDString);
    
    //get JSON data from server
    NSString *baseURLStr = @"http://babyphotobook.us/photos/F13CCEBD-E3F4-487E-9856-30F133429DCB";
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:baseURLStr]];
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:nil error:nil];
    
    _feed = [[PhotoBookFeed alloc] initWithData:data error:nil];
    NSURL *urlPrefix = [NSURL URLWithString:@"http://babyphotobook.us/"];
    for (NSInteger a = 0; a < _feed.account.photogroups.count; a++) {
        Album *album = [[Album alloc] init];
        PhotoGroup *photoGroup = ((PhotoGroup *)[_feed.account.photogroups objectAtIndex:a]);
        album.name = [NSString stringWithFormat:@"%@", photoGroup.title];
        album.albumType = photoGroup.type;
        album.id = photoGroup.id;
        
        for (NSInteger p = 0; p < photoGroup.photobooks.count; p++) {
            PhotoBook *photoBook = (PhotoBook *)[photoGroup.photobooks objectAtIndex:p];
            NSString *photoFilename = [NSString stringWithFormat:@"%@",photoBook.image];
            NSURL *photoURL = [urlPrefix URLByAppendingPathComponent:photoFilename];
            NSString *audioFilename = [NSString stringWithFormat:@"audio/%@",photoBook.audio];
            NSURL *audioURL = [urlPrefix URLByAppendingPathComponent:audioFilename];
            Photo *photo = [Photo photoWithImageURL:photoURL];
            [photo setAudioURL:audioURL];
            [photo setTitle:photoBook.title];
            [photo setColor:photoBook.color];
            [photo setVideo:photoBook.video];
            [photo setStart:photoBook.start];
            [album addPhoto:photo];
            
        }
        [self.albums addObject:album];
    }
    //[self.view setNeedsDisplay];
}

- (IBAction)muteAudio:(id)sender {
    if (isMuted) {
        [self.audioController tryPlayMusic];
        [muteButton setBackgroundImage:[UIImage imageNamed:@"audio.png"] forState:UIControlStateNormal];
        isMuted = NO;
    }
    else {
        [self.audioController tryPauseMusic];
        [muteButton setBackgroundImage:[UIImage imageNamed:@"audio_mute.png"] forState:UIControlStateNormal];
        isMuted = YES;
    }
}

-(UIImage *)generateThumbImage : (Photo *)photo
{
    
    AVAsset *asset = [AVAsset assetWithURL:[NSURL URLWithString:[photo video]]];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    CMTime time = [asset duration];
    time.value = [photo start] * 1000;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    
    return thumbnail;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSLog(@"Number of photogroups: %ld", self.albums.count);
    return self.albums.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    Album *album = self.albums[section];
    return album.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AlbumPhotoCell *photoCell =
    [collectionView dequeueReusableCellWithReuseIdentifier:PhotoCellIdentifier
                                              forIndexPath:indexPath];

    Album *album = self.albums[indexPath.section];
    Photo *photo = album.photos[indexPath.item];
    
    [photoCell.deleteButton addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
    
    // load photo images in the background
    __weak CollectionViewController *weakSelf = self;
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        UIImage *image = [photo image];
        if ([album.albumType isEqualToString:@"Video"]) {
            NSString *videoURL = nil;
            NSRange start = [[photo video] rangeOfString:@"v="];
            if (start.location != NSNotFound)
            {
                videoURL = [[photo video] substringFromIndex:start.location + start.length];
            }
            NSString *thumbnailString = [NSString stringWithFormat:@"https://i.ytimg.com/vi/%@/mqdefault.jpg", videoURL];
            NSURL *thumbnail = [NSURL URLWithString:thumbnailString];
            NSData *imageData = [NSData dataWithContentsOfURL:thumbnail];
            
            image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{

            // then set them via the main queue if the cell is still visible.
            if ([weakSelf.collectionView.indexPathsForVisibleItems containsObject:indexPath]) {
                AlbumPhotoCell *cell =
                (AlbumPhotoCell *)[weakSelf.collectionView cellForItemAtIndexPath:indexPath];
                
                if ([album.albumType isEqualToString:@"RemoteVideo"]) {
                    cell.imageView.image = image;//[self generateThumbImage:photo];
                    if ([photo video]) {
                        NSData *imgData = UIImageJPEGRepresentation(cell.imageView.image, 1.0f);
                        // TODO: handle no thumbnail scenario
                        if (imgData != nil) {
                            if ([self.thumbnailDict objectForKey:[photo video]] == nil) {
                                [self.thumbnailDict setObject:imgData forKey:[photo video]];
                            }
                        }
                    }
                }
                else {
                    cell.imageView.image = image;
                }
                
            }
        });
    }];
    
    if (indexPath.item == 0) {
        operation.queuePriority = NSOperationQueuePriorityVeryHigh;
    }
    else {
        if ([album.albumType isEqualToString:@"RemoteVideo"]) {
            operation.queuePriority = NSOperationQueuePriorityLow;
        }
        else {
            operation.queuePriority = NSOperationQueuePriorityNormal;
        }
    }
    
    [self.thumbnailQueue addOperation:operation];
    
    CGRect finalCellFrame = photoCell.frame;
    //check the scrolling direction to verify from which side of the screen the cell should come.
    CGPoint translation = [collectionView.panGestureRecognizer translationInView:collectionView.superview];
    if (translation.x > 0) {
        photoCell.frame = CGRectMake(finalCellFrame.origin.x - 1000, - 500.0f, 0, 0);
    } else {
        photoCell.frame = CGRectMake(finalCellFrame.origin.x + 1000, - 500.0f, 0, 0);
    }
    
    [UIView animateWithDuration:0.5f animations:^(void){
        photoCell.frame = finalCellFrame;
    }];
    
    return photoCell;
}


#pragma mark - delete for button

- (void)delete:(UIButton *)sender
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:(AlbumPhotoCell *)sender.superview.superview];
    // TODO: remove the photogroup from the server as well
    [self.albums removeObjectAtIndex:indexPath.section];
    [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
    [self.pageControl setNumberOfPages:[self getTotalPageCount]];
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    /**
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        self.photoAlbumLayout.numberOfColumns = 4;
        NSLog(@"screen width: %f", [UIScreen mainScreen].preferredMode.size.width);
        // handle insets for iPhone 4 or 5
        CGFloat sideInset = [UIScreen mainScreen].preferredMode.size.width == 1136.0f ?
        45.0f : 25.0f;
        sideInset = 75.0f;
        self.photoAlbumLayout.itemInsets = UIEdgeInsetsMake(22.0f, sideInset, 13.0f, sideInset);
        
    } else {
        self.photoAlbumLayout.numberOfColumns = 4;
        self.photoAlbumLayout.itemInsets = UIEdgeInsetsMake(22.0f, 22.0f, 13.0f, 22.0f);
    }
     */
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath;
{
    AlbumTitleReusableView *titleView =
    [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                       withReuseIdentifier:AlbumTitleIdentifier
                                              forIndexPath:indexPath];
    
    Album *album = self.albums[indexPath.section];
    titleView.titleLabel.text = album.name;
    return titleView;
}

- (IBAction)navigateSettings:(id)sender {

    self.button = (UIButton *)sender;
    SettingsMainViewController *second = [self.storyboard instantiateViewControllerWithIdentifier:@"settingsMainView"];
    second.modalTransitionStyle = UIModalPresentationCustom;
    second.transitioningDelegate = self;
    [self presentViewController:second animated:YES completion:nil];

}

- (NSInteger)horizontalPageNumber:(UIScrollView *)scrollView {
    CGPoint contentOffset = scrollView.contentOffset;
    CGSize viewSize = scrollView.bounds.size;
    
    NSInteger horizontalPage = MAX(0.0, contentOffset.x / viewSize.width);
    
    // Here's how vertical would work...
    //NSInteger verticalPage = MAX(0.0, contentOffset.y / viewSize.height);
    
    return horizontalPage;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.pageControl.currentPage = [self horizontalPageNumber:scrollView];
    NSLog(@"Current Page %ld",(long)self.pageControl.currentPage);
    NSLog(@"Scrollview %f",scrollView.contentOffset.x);
    NSInteger currentPage = self.pageControl.currentPage;
    if (scrollView.contentOffset.x >= ((currentPage+1) * (1024/2))) {
        [self.collectionView setContentOffset:CGPointMake(1024, 0) animated:YES];
        self.pageControl.currentPage++;
    }
    else {
        [self.collectionView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) self.pageControl.currentPage = [self horizontalPageNumber:scrollView];
    NSInteger currentPage = self.pageControl.currentPage;
    NSLog(@"End Drag Scrollview %f",scrollView.contentOffset.x);
    if (scrollView.contentOffset.x > ((currentPage+1) * (1024/2))) {
        [self.collectionView setContentOffset:CGPointMake(1024, 0) animated:YES];
        self.pageControl.currentPage++;
    }
    else {
        [self.collectionView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedAlbum = self.albums[indexPath.section];
    AlbumPhotoCell *cell = (AlbumPhotoCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    CGPoint point = cell.center;
    if ([self.pageControl currentPage] > 0) {
        point.x = (NSInteger)point.x % (NSInteger)self.view.bounds.size.width;
    }

    CGRect rect = CGRectMake(point.x, point.y, 1, 1);
    UIButton *temp = [[UIButton alloc] initWithFrame:rect];
    self.button = temp;
    if ([self.selectedAlbum.albumType isEqualToString:@"Video"] ||
         [self.selectedAlbum.albumType isEqualToString:@"RemoteVideo"]) {
        VideoViewController *second = [self.storyboard
            instantiateViewControllerWithIdentifier:@"videoView"];
        [second setCurrentAlbum:self.selectedAlbum];
        [second setThumbnailDictionary:self.thumbnailDict];
        second.modalTransitionStyle = UIModalPresentationCustom;
        second.transitioningDelegate = self;
        if (isMuted == NO) {
            [self muteAudio:nil];
        }
        [self presentViewController:second animated:YES completion:nil];
    }
    else if ([self.selectedAlbum.albumType isEqualToString:@"Color"]) {
            ColorBookViewController *second = [self.storyboard instantiateViewControllerWithIdentifier:@"categoryView"];
            [second setCurrentAlbum:self.selectedAlbum];
            second.modalTransitionStyle = UIModalPresentationCustom;
            second.transitioningDelegate = self;
            [self presentViewController:second animated:YES completion:nil];
    }
    else {
        PhotoBookViewController *second = [self.storyboard instantiateViewControllerWithIdentifier:@"photoBookView"];
        [second setCurrentAlbum:self.selectedAlbum];
        second.modalTransitionStyle = UIModalPresentationCustom;
        second.transitioningDelegate = self;
        [self presentViewController:second animated:YES completion:nil];
    }
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (isDeletionModeActive) return NO;
    else return YES;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"NextPage"]) {
        [segue.destinationViewController setCurrentAlbum:self.selectedAlbum];
    }
}

#pragma mark - spring board layout delegate

- (BOOL) isDeletionModeActiveForCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
{
    return isDeletionModeActive;
}

#pragma mark - gesture-recognition action methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint touchPoint = [touch locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:touchPoint];
    if (indexPath && [gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
    {
        return NO;
    }
    return YES;
}

- (void)activateDeletionMode:(UILongPressGestureRecognizer *)gr
{
    if (gr.state == UIGestureRecognizerStateBegan)
    {
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[gr locationInView:self.collectionView]];
        NSLog(@"Delete Index Path: %ld", (long)indexPath.section);
        if (indexPath)
        {
            isDeletionModeActive = YES;
            PhotoAlbumLayout *layout = (PhotoAlbumLayout *)self.collectionView.collectionViewLayout;
            [layout invalidateLayout];
        }
    }
}

- (void)endDeletionMode:(UITapGestureRecognizer *)gr
{
    if (isDeletionModeActive)
    {
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[gr locationInView:self.collectionView]];
        if (!indexPath)
        {
            isDeletionModeActive = NO;
            PhotoAlbumLayout *layout = (PhotoAlbumLayout *)self.collectionView.collectionViewLayout;
            [layout invalidateLayout];
        }
    }
}


@end
