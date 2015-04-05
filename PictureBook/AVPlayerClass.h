//
//  AVPlayerClass.h
//  PictureBook
//
//  Created by greg vandenberg on 2/22/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class AVPlayer;

@interface AVPlayerClass : UIView

@property (nonatomic, retain) AVPlayer* player;

- (void)setMovieToPlayer: (AVPlayer *)player;

@end
