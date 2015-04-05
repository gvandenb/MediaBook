//
//  AVPlayerClass.m
//  PictureBook
//
//  Created by greg vandenberg on 2/22/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import "AVPlayerClass.h"

@implementation AVPlayerClass

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer *)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setMovieToPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];

}

@end
