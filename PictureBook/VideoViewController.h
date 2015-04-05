//
//  VideoViewController.h
//  PictureBook
//
//  Created by greg vandenberg on 2/22/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AVPlayerClass.h"
#import "YTPlayerView.h"
#import "Album.h"
#import "Photo.h"
#import "VideoPlayerView.h"

@class AVPlayer;
@class AVPlayerClass;

@interface VideoViewController: UIViewController<YTPlayerViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate, UIGestureRecognizerDelegate>
    

@property (nonatomic, retain) IBOutlet VideoPlayerView *playerView;
@property (nonatomic, retain) IBOutlet YTPlayerView *ytPlayerView;
@property (nonatomic, retain) IBOutlet UICollectionView *videoCollectionView;
@property (nonatomic, retain) IBOutlet UICollectionViewCell *videoCollectionViewCell;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView* activityIndicatorView;
@property (nonatomic, retain) IBOutlet UIButton *guestureView;
@property (nonatomic, retain) IBOutlet UIButton *homeButton;
@property (nonatomic, retain) IBOutlet UIImageView *playButtonView;
@property (nonatomic, retain) IBOutlet UILabel *videoPageLabel;
@property (nonatomic, retain) IBOutlet UIView *blackOverlay;
@property (nonatomic, retain) IBOutlet UIView *fullScreenOverlay;
@property (nonatomic, retain) IBOutlet UIImageView *maskView;
@property (nonatomic, retain) IBOutlet UIImageView *thumbnailView;
@property (nonatomic, retain) IBOutlet UIButton *playVideoButton;
@property (nonatomic, retain) IBOutlet NSMutableDictionary *thumbnailDictionary;
@property (nonatomic, strong) NSArray *dataArray;
@property (strong, nonatomic) Album *currentAlbum;
@property (nonatomic, retain) NSIndexPath *selectedItemIndexPath;
@property (nonatomic, retain) AVSpeechSynthesizer *speechSynthesizer;

- (IBAction)playOrPauseVideo:(id)sender;
- (void) performYouTubeSearch: (NSString *)searchQuery;

@end
