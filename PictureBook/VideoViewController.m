//
//  VideoViewController.m
//  PictureBook
//
//  Created by greg vandenberg on 2/22/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "VideoViewController.h"
#import "VideoCollectionViewCell.h"
#import "VideoCardLabel.h"
#import "GTLServiceYouTube.h"
#import "GTLQueryYouTube.h"
#import "GTLYouTubeSearchListResponse.h"
#import "GTLYouTubeSearchResult.h"
#import "GTLYouTubeVideo.h"
#import "PhotoBookUtility.h"

@interface VideoViewController ()

@end

@implementation VideoViewController {
    BOOL isVideoPlaying;
    BOOL isVideoRewinding;
    BOOL isVideoFullScreen;
}

@synthesize playerView;
@synthesize ytPlayerView;
@synthesize guestureView;
@synthesize playButtonView;
@synthesize maskView;
@synthesize videoCollectionView;
@synthesize videoCollectionViewCell;
@synthesize dataArray;
@synthesize currentAlbum;
@synthesize homeButton;
@synthesize selectedItemIndexPath;
@synthesize activityIndicatorView;
@synthesize videoPageLabel;
@synthesize speechSynthesizer;
@synthesize thumbnailView;
@synthesize thumbnailDictionary;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    speechSynthesizer = [[AVSpeechSynthesizer alloc] init];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    self.selectedItemIndexPath = indexPath;
    playButtonView.center = guestureView.center;
    isVideoPlaying = NO;
    isVideoFullScreen = NO;
    isVideoRewinding = NO;
    self.ytPlayerView.delegate = self;
    
    Photo *photoAlbum = self.currentAlbum.photos[0];
    
    BOOL SDKIsBelowIOS8 = floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1;
    CGFloat widthBounds = super.view.bounds.size.width;
    CGFloat heightBounds = super.view.bounds.size.height;
    if (SDKIsBelowIOS8) {
        widthBounds = super.view.bounds.size.height;
        heightBounds = super.view.bounds.size.width;
    }
    
    maskView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,widthBounds,heightBounds)];
    maskView.image = [[UIImage imageNamed: @"mask_video.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.view addSubview:maskView];
    [self setupMovie:photoAlbum];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(200, 170)];
    [flowLayout setSectionInset:UIEdgeInsetsMake(0, 32, 0, 32)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    [videoCollectionView registerClass:[VideoCollectionViewCell class] forCellWithReuseIdentifier:@"cvCell"];
    [videoCollectionView setCollectionViewLayout:flowLayout];
    
    [self.view addSubview:homeButton];
    self.videoPageLabel.text = [NSString stringWithFormat:@" %@   ", photoAlbum.title];
    [PhotoBookUtility formatLabel:self.videoPageLabel];
    [self.view addSubview:videoPageLabel];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(activateFullScreenMode:)];
    longPress.delegate = self;
    [self.guestureView addGestureRecognizer:longPress];
    
    UIPanGestureRecognizer *panGuesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(seekVideo:)];
    longPress.delegate = self;
    [self.guestureView addGestureRecognizer:panGuesture];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deactivateFullScreenMode:)];
    tap.delegate = self;
    self.fullScreenOverlay = [[UIView alloc] initWithFrame:CGRectMake(0,0,1024,768)];
    self.fullScreenOverlay.userInteractionEnabled = YES;
    self.fullScreenOverlay.backgroundColor = [UIColor clearColor];
    [self.fullScreenOverlay addGestureRecognizer:tap];
    activityIndicatorView.hidden = YES;
    if ([self.currentAlbum.albumType isEqualToString:@"RemoteVideo"]) {
        self.ytPlayerView.hidden = YES;
    }
    if ([self.currentAlbum.albumType isEqualToString:@"Video"]) {
        self.playerView.hidden = YES;
    }

}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (IBAction)activateFullScreenMode:(id)sender {
    if (!isVideoFullScreen) {
        self.blackOverlay = [[UIView alloc] initWithFrame:CGRectMake(0,0,1024,768)];
        self.blackOverlay.backgroundColor = [UIColor blackColor];
        self.fullScreenOverlay.hidden = NO;
        if ([self.currentAlbum.albumType isEqualToString:@"Video"]) {
            [UIView beginAnimations:@"move" context:nil];
            [UIView setAnimationDuration:0.25];
            [self.view addSubview:self.blackOverlay];
            self.ytPlayerView.frame = CGRectMake(-85, 50, 1024, 576);
            self.ytPlayerView.webView.frame = CGRectMake(-85, 50, 1024, 576);
            [UIView commitAnimations];
            [self.view bringSubviewToFront:self.ytPlayerView];
        }
        else {
            NSLog(@"begin animation");
            self.playerView.frame = CGRectMake(-85, 50, 1024, 576);
            self.playerView.backgroundColor = [UIColor blackColor];
            [UIView beginAnimations:@"move" context:nil];
            [UIView setAnimationDuration:1.0];
            [self.view addSubview:self.blackOverlay];

            self.playerView.avPlayerLayer.frame = CGRectMake(-85, 50, 1024, 576);
            [UIView commitAnimations];
            [self.view bringSubviewToFront:self.playerView];

        }
        [self.view addSubview:self.fullScreenOverlay];

        NSLog(@"Finished transition");
        isVideoFullScreen = YES;

    }
}

- (IBAction)deactivateFullScreenMode:(UITapGestureRecognizer *)recognizer {
    if (isVideoFullScreen) {
        if ([self.currentAlbum.albumType isEqualToString:@"Video"]) {
            // YouTube video
            self.ytPlayerView.frame = CGRectMake(0,0,853,480);
            self.ytPlayerView.webView.frame = CGRectMake(0,0,853,480);
            self.ytPlayerView.backgroundColor = [UIColor blackColor];
            self.ytPlayerView.webView.backgroundColor = [UIColor blackColor];
            [UIView beginAnimations:@"move" context:nil];
            [UIView setAnimationDuration:1.0];
            self.blackOverlay.hidden = YES;
            [self.view sendSubviewToBack:self.ytPlayerView];
            [UIView commitAnimations];
        }
        else {
            // Hosted video
            self.playerView.frame = CGRectMake(0,0,853,480);
            self.playerView.backgroundColor = [UIColor blackColor];
            self.playerView.avPlayerLayer.backgroundColor = [UIColor blackColor].CGColor;
            [UIView beginAnimations:@"move" context:nil];
            [UIView setAnimationDuration:1.0];
            self.playerView.avPlayerLayer.frame = CGRectMake(0, 0, 853, 480);
            self.blackOverlay.hidden = YES;
            [UIView commitAnimations];
            [self.view sendSubviewToBack:self.playerView];
        }
        
        self.fullScreenOverlay.hidden = YES;
        NSLog(@"Finished deactivate transition");
        isVideoFullScreen = NO;
    }
}

- (void)seekVideo:(UIPanGestureRecognizer *)recognizer
{
    if ([self.currentAlbum.albumType isEqualToString:@"RemoteVideo"]) {
        CGPoint vel = [recognizer velocityInView:self.view];
        if (vel.x > 0)
        {
            // user dragged towards the right
            if (recognizer.state == UIGestureRecognizerStateBegan) {
                [self enableAudioTracks:NO inPlayerItem:self.playerView.player.currentItem];
                self.playerView.player.rate = 10.0;
            }
        }
        else
        {
            if (recognizer.state == UIGestureRecognizerStateBegan) {
                [self enableAudioTracks:NO inPlayerItem:self.playerView.player.currentItem];
            }
            [self enableRewind];
        }
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            // pan guesture has ended check to see if the player is paused
            self.playerView.player.rate = 1.0;
            [self enableAudioTracks:YES inPlayerItem:self.playerView.player.currentItem];
            //[self.playerView.player play];
        }
    }
}

-(void)enableRewind {
    Photo *photoAlbum = self.currentAlbum.photos[self.selectedItemIndexPath.item];
    CMTime currentTime = [self.playerView.player currentTime];
    CMTime timeToSubtract   = CMTimeMakeWithSeconds(1,1);
    CMTime resultTime  = CMTimeSubtract(currentTime,timeToSubtract);
    NSLog(@"photoAlbum start: %ld", (long)[photoAlbum start]);
    NSLog(@"resultTime: %lld", resultTime.value/resultTime.timescale);
    if (resultTime.value/resultTime.timescale <= [photoAlbum start]) {
        resultTime = CMTimeMakeWithSeconds((CGFloat)[photoAlbum start], 1);
    }
    [self.playerView.player seekToTime:resultTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)enableAudioTracks:(BOOL)enable inPlayerItem:(AVPlayerItem*)playerItem
{
    for (AVPlayerItemTrack *track in playerItem.tracks)
    {
        if ([track.assetTrack.mediaType isEqual:AVMediaTypeAudio])
        {
            track.enabled = enable;
        }
    }
}

- (IBAction)playOrPauseVideo:(id)sender {
    if (isVideoPlaying) {
        if ([self.currentAlbum.albumType isEqualToString:@"Video"]) {
            [self.ytPlayerView pauseVideo];
        }
        else {
            [self.playerView.player pause];
        }
        isVideoPlaying = NO;
        playButtonView.alpha = 0.5;
        playButtonView.hidden = NO;
    }
    else {
        if ([self.currentAlbum.albumType isEqualToString:@"Video"]) {
            [self.ytPlayerView playVideo];
        }
        else {
            [self.playerView.player play];
            if (!playButtonView.hidden) playButtonView.hidden = YES;
            self.activityIndicatorView.hidden = YES;
            guestureView.backgroundColor = [UIColor clearColor];
            self.thumbnailView.hidden = YES;
        }
        isVideoPlaying = YES;
        NSLog(@"Starting to play");
    }
}

- (void) updateVideoById: (NSString *)id photo:(Photo *) photo {
    playButtonView.hidden = YES;
    NSRange start = [id rangeOfString:@"v="];
    NSString *videoURL = nil;
    if (start.location != NSNotFound)
    {
        videoURL = [id substringFromIndex:start.location + start.length];
    }
    isVideoPlaying = NO;

    UIColor * toImage = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pbskids.png"]];
    guestureView.contentMode = UIControlContentHorizontalAlignmentFill;

    guestureView.backgroundColor = toImage;
    
    self.activityIndicatorView.hidden = NO;

    [UIView transitionWithView:guestureView
                      duration:1.0f
                       options:UIViewAnimationOptionTransitionFlipFromTop
                    animations:^{
                        guestureView.backgroundColor = toImage;
                    } completion:^(BOOL finished) {
                        float start = [[NSNumber numberWithInteger:photo.start] floatValue];
                        if ([self.currentAlbum.albumType isEqualToString:@"Video"]) {
                            [self.ytPlayerView cueVideoById:videoURL startSeconds:0 suggestedQuality:kYTPlaybackQualityHD720];
                        }
                        else {
                            [self startPlaybackForItemWithURL:[NSURL URLWithString:[photo video]] start:start];
                        }
                        [self playOrPauseVideo:nil];
                        
                        
                    }];
    
}

-(void)startPlaybackForItemWithURL:(NSURL*)url start:(float)start {
    
    [self.playerView.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.playerView.player.currentItem removeObserver:self forKeyPath:@"rate"];

    [self.playerView.player  replaceCurrentItemWithPlayerItem:nil];
    self.playerView.backgroundColor = [UIColor blackColor];
    // First create an AVPlayerItem
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:url];
    
    // Subscribe to the AVPlayerItem's DidPlayToEndTime notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    
    [playerItem addObserver:self forKeyPath:@"status" options:0 context:nil];
    [playerItem addObserver:self forKeyPath:@"rate" options:0 context:nil];

    // Pass the AVPlayerItem to a new player
    [self.playerView.player  replaceCurrentItemWithPlayerItem:playerItem];

    // TODO: get start time from database
    [self.playerView.player seekToTime:CMTimeMake(start, 1)];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass:[AVPlayerItem class]])
    {
        AVPlayerItem *item = (AVPlayerItem *)object;
        //playerItem status value changed?
        if ([keyPath isEqualToString:@"status"])
        {   //yes->check it...
            switch(item.status)
            {
                case AVPlayerItemStatusFailed:
                    NSLog(@"player item status failed");
                    break;
                case AVPlayerItemStatusReadyToPlay:
                    NSLog(@"player item status is ready to play");
                    break;
                case AVPlayerItemStatusUnknown:
                    NSLog(@"player item status is unknown");
                    break;
            }
        }
        if ([keyPath isEqualToString:@"rate"] )
        {
            if (self.playerView.player.rate == 0 && CMTimeGetSeconds(item.duration) != CMTimeGetSeconds(item.currentTime) && isVideoPlaying)
            {
                NSLog(@"Ran out of buffer");
                playButtonView.hidden = NO;
            }
        }
    
    }
}

-(void)itemDidFinishPlaying:(NSNotification *) notification {
    // Will be called when AVPlayer finishes playing playerItem
    NSInteger nextIndex = self.selectedItemIndexPath.item + 1;
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:nextIndex inSection:0];
    if (nextIndex >= [self.currentAlbum.photos count]) {
        nextIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    }
    playButtonView.hidden = NO;
    isVideoPlaying = NO;
    [self collectionView:videoCollectionView didSelectItemAtIndexPath:nextIndexPath];
}

- (void) setupMovie:(Photo *)photo
{    
    NSDictionary *playerVars = @{
        @"playsinline" : @1,
        @"controls" : @0,
        @"rel" : @0,
        @"showinfo" : @0,
        @"iv_load_policy":@3,
        @"modestbranding":@1,
    };
    NSString *videoURL = nil;
    NSRange start = [[photo video] rangeOfString:@"v="];
    if (start.location != NSNotFound)
    {
        videoURL = [[photo video] substringFromIndex:start.location + start.length];
    }
    if ([self.currentAlbum.albumType isEqualToString:@"Video"]) {
        [self.ytPlayerView loadWithVideoId:videoURL playerVars:playerVars];
    }
    else {
        self.playerView.avAsset = [AVAsset assetWithURL:[NSURL URLWithString:[photo video]]];
        self.playerView.avPlayerItem =[[AVPlayerItem alloc]initWithAsset:self.playerView.avAsset];

        self.playerView.player = [[AVPlayer alloc]initWithPlayerItem:self.playerView.avPlayerItem];

        [self.playerView.player.currentItem addObserver:self forKeyPath:@"status" options:0 context:nil];
        [self.playerView.player.currentItem addObserver:self forKeyPath:@"rate" options:0 context:nil];

        if ([photo start] > 0) {
            [self.playerView.player seekToTime:CMTimeMake([photo start], 1)];
        }
        self.playerView.avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:self.playerView.player];
        [self.playerView.avPlayerLayer setFrame:CGRectMake(0, 0, 853, 480)];
        self.thumbnailView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:[self.thumbnailDictionary objectForKey: [photo video]]]];
        self.thumbnailView.frame = CGRectMake(0, 0, 853, 480);
        [self.playerView.layer addSublayer:self.playerView.avPlayerLayer];
        [self.playerView addSubview:self.thumbnailView];

    }
    
}

- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state {
    NSInteger nextIndex = self.selectedItemIndexPath.item + 1;
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:nextIndex inSection:0];
    if (nextIndex >= [self.currentAlbum.photos count]) {
        nextIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    }
    switch (state) {
        case kYTPlayerStatePlaying:
            NSLog(@"Started playback");
            playButtonView.hidden = YES;
            self.activityIndicatorView.hidden = YES;
            guestureView.backgroundColor = [UIColor clearColor];
            break;
        case kYTPlayerStatePaused:
            NSLog(@"Paused playback");
            break;
        case kYTPlayerStateEnded:
            NSLog(@"Ended playback");
            playButtonView.hidden = NO;
            isVideoPlaying = NO;
            [self collectionView:videoCollectionView didSelectItemAtIndexPath:nextIndexPath];
            break;
        case kYTPlayerStateBuffering:
            NSLog(@"Buffering for playback");
            break;
        case kYTPlayerStateQueued:
            NSLog(@"Queued for playback");
            break;
        case kYTPlayerStateUnstarted:
            self.activityIndicatorView.hidden = YES;
            NSLog(@"Unstarted");
            break;
        default:
            break;
    }
}

- (void)playerView:(YTPlayerView *)playerView receivedError:(YTPlayerError)error {
    NSLog(@"An error occured playing the video: %ld", error);
}

- (void)performYouTubeSearch:(NSString *)searchQuery {
    // Create a service object for executing queries
    GTLServiceYouTube *service = [[GTLServiceYouTube alloc] init];
    // Services which do not require sign-in may need an API key from the
    // API Console
    service.APIKey = @"AIzaSyBq5yC9oIXQ2p11U4H4ppXKdXOE3yO5eBk";
    // Create a query
    GTLQueryYouTube *query = [GTLQueryYouTube queryForSearchListWithPart:@"id,snippet"];
    query.q = searchQuery;
    query.maxResults = 20;
    //query.country = @"US";
    // Execute the query
    GTLServiceTicket *ticket = [service executeQuery:query
                                   completionHandler:^(GTLServiceTicket *ticket, GTLYouTubeSearchListResponse *searchList, NSError *error) {
                                       // This callback block is run when the fetch completes
                                       if (error == nil) {
                                           [searchList.items enumerateObjectsUsingBlock:^(GTLYouTubeSearchResult *searchItem, NSUInteger idx, BOOL *stop) {
                                               GTLYouTubeVideo *video = (GTLYouTubeVideo *)searchItem.identifier;
                                               GTLYouTubeVideo *snippet = (GTLYouTubeVideo *)searchItem.snippet;
                                               
                                               NSString *videoId = [video.JSON valueForKey:@"videoId"];
                                               NSLog(@"VideoId: %@", videoId);
                                               NSLog(@"%@", [snippet.JSON valueForKeyPath:@"thumbnails.default.url"]);
                                           }];
                                           
                                       }
                                       else {
                                           NSLog(@"Error: %@", error.description);
                                       }
                                   }
                                ];
    NSLog(@"Status: %ld", (long)ticket.statusCode);
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.currentAlbum.photos.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    Photo *photoAlbum = self.currentAlbum.photos[indexPath.item];

    static NSString *cellIdentifier = @"cvCell";
    VideoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (self.selectedItemIndexPath != nil && [indexPath compare:self.selectedItemIndexPath] == NSOrderedSame) {
        cell.layer.borderColor = [[UIColor redColor] CGColor];
        cell.layer.borderWidth = 4.0;
    } else {
        cell.layer.borderColor = [[UIColor whiteColor] CGColor];
        cell.layer.borderWidth = 3.0;
    }
    if ([self.thumbnailDictionary objectForKey:[photoAlbum video]] != nil) {
        cell.imageView.image = [UIImage imageWithData:[self.thumbnailDictionary objectForKey:[photoAlbum video]]];
    }
    else {
        cell.imageView.image = [PhotoBookUtility getYouTubeThumbnailImage:[photoAlbum video]];
    }
    cell.titleLabel.text = [photoAlbum title];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    Photo *photoAlbum = self.currentAlbum.photos[indexPath.item];
    self.videoPageLabel.text = [NSString stringWithFormat:@" %@   ", photoAlbum.title];
    NSString *videoURL = [photoAlbum video];
    NSLog(@"%@", [photoAlbum video]);
    
        
    // always reload the selected cell, so we will add the border to that cell
    NSMutableArray *indexPaths = [NSMutableArray arrayWithObject:indexPath];
    
    if (self.selectedItemIndexPath)
    {
        // if we had a previously selected cell
        if ([indexPath compare:self.selectedItemIndexPath] != NSOrderedSame)
        {
            // if it's different, then add that old one to our list of cells to reload, and
            // save the currently selected indexPath
            [self updateVideoById:videoURL photo:photoAlbum];
            [indexPaths addObject:self.selectedItemIndexPath];
            self.selectedItemIndexPath = indexPath;
        }
    }
    else
    {
        // else, we didn't have previously selected cell, so we only need to save this indexPath for future reference
        [self updateVideoById:videoURL photo:photoAlbum];
        self.selectedItemIndexPath = indexPath;
    }
    
    [self.videoCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];

    // and now only reload only the cells that need updating
    [collectionView reloadItemsAtIndexPaths:indexPaths];
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.playerView.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.playerView.player.currentItem removeObserver:self forKeyPath:@"rate"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end