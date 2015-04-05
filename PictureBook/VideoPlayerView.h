//
//  VideoPlayerView.h
//  PictureBook
//
//  Created by greg vandenberg on 3/13/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoPlayerView : UIView
@property (nonatomic, retain) AVPlayer *player;
@property (nonatomic, retain) AVAsset *avAsset;
@property (nonatomic, retain) AVPlayerItem *avPlayerItem;
@property (nonatomic, retain) AVPlayerLayer *avPlayerLayer;
@end
