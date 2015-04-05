//
//  AudioController.m
//  ATBasicSounds
//
//  Created by Audrey M Tam on 22/03/2014.
//  Copyright (c) 2014 Ray Wenderlich. All rights reserved.
//

#import "AudioController.h"
@import AVFoundation;

@interface AudioController () <AVAudioPlayerDelegate>

@property (strong, nonatomic) AVAudioSession *audioSession;
@property (strong, nonatomic) AVAudioPlayer *backgroundMusicPlayer;
@property (strong, nonatomic) AVPlayer *backgroundMusicPlayerRemote;
@property (assign) BOOL backgroundMusicPlaying;
@property (assign) BOOL backgroundMusicInterrupted;
@property (assign) SystemSoundID pewPewSound;

@end

@implementation AudioController

#pragma mark - Public

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configureAudioSession];
        Boolean playBackgroundMusic = [[NSUserDefaults standardUserDefaults] boolForKey:@"PlayBackgroundMusic"];
        if (playBackgroundMusic) {
            [self configureSystemSound];
        }
    }
    return self;
}

- (void)tryPlayMusic {
    // If background music or other music is already playing, nothing more to do here
    //if (self.backgroundMusicPlaying || [self.audioSession isOtherAudioPlaying]) {
    //    return;
    //}
    
    // Play background music if no other music is playing and we aren't playing already
    //Note: prepareToPlay preloads the music file and can help avoid latency. If you don't
    //call it, then it is called anyway implicitly as a result of [self.backgroundMusicPlayer play];
    //It can be worthwhile to call prepareToPlay as soon as possible so as to avoid needless
    //delay when playing a sound later on.
    //[self.backgroundMusicPlayer prepareToPlay];
    [self.backgroundMusicPlayer play];
    //[self.backgroundMusicPlayerRemote play];
    //self.backgroundMusicPlaying = YES;
}

- (void)tryPauseMusic {
    // If background music or other music is already playing, nothing more to do here
    //if (self.backgroundMusicPlaying || [self.audioSession isOtherAudioPlaying]) {
    //    return;
    //}
    
    // Play background music if no other music is playing and we aren't playing already
    //Note: prepareToPlay preloads the music file and can help avoid latency. If you don't
    //call it, then it is called anyway implicitly as a result of [self.backgroundMusicPlayer play];
    //It can be worthwhile to call prepareToPlay as soon as possible so as to avoid needless
    //delay when playing a sound later on.
    //[self.backgroundMusicPlayer prepareToPlay];
    [self.backgroundMusicPlayer pause];
    //[self.backgroundMusicPlayerRemote play];
    //self.backgroundMusicPlaying = YES;
}

- (void)tryPlayRemoteMusic {
    // If background music or other music is already playing, nothing more to do here
    //if (self.backgroundMusicPlaying || [self.audioSession isOtherAudioPlaying]) {
    //    return;
    //}
    
    // Play background music if no other music is playing and we aren't playing already
    //Note: prepareToPlay preloads the music file and can help avoid latency. If you don't
    //call it, then it is called anyway implicitly as a result of [self.backgroundMusicPlayer play];
    //It can be worthwhile to call prepareToPlay as soon as possible so as to avoid needless
    //delay when playing a sound later on.
    //[self.backgroundMusicPlayer prepareToPlay];
    //if (!self.backgroundMusicPlaying)[self.backgroundMusicPlayer play];
    [self.backgroundMusicPlayerRemote play];
    //self.backgroundMusicPlaying = YES;
}

- (void)playSystemSound {
    AudioServicesPlaySystemSound(self.pewPewSound);
}

#pragma mark - Private

- (void) configureAudioSession {
    // Implicit initialization of audio session
    self.audioSession = [AVAudioSession sharedInstance];
    
    // Set category of audio session
    // See handy chart on pg. 46 of the Audio Session Programming Guide for what the categories mean
    // Not absolutely required in this example, but good to get into the habit of doing
    // See pg. 10 of Audio Session Programming Guide for "Why a Default Session Usually Isn't What You Want"
    
    NSError *setCategoryError = nil;
    if ([self.audioSession isOtherAudioPlaying]) { // mix sound effects with music already playing
        [self.audioSession setCategory:AVAudioSessionCategorySoloAmbient error:&setCategoryError];
        self.backgroundMusicPlaying = NO;
    } else {
        [self.audioSession setCategory:AVAudioSessionCategoryAmbient error:&setCategoryError];
    }
    if (setCategoryError) {
        NSLog(@"Error setting category! %ld", (long)[setCategoryError code]);
    }
}

- (void)configureAudioPlayerRemote:(NSURL *)url {
    // Create audio player for sound effect
    NSURL *soundEffectURL = url;
    NSLog(@"soundEffectURL: %@", soundEffectURL);

    self.backgroundMusicPlayerRemote = [[AVPlayer alloc] initWithURL:soundEffectURL];
}

- (void)configureSystemSound {
    // Create audio player with background music
    NSString *backgroundMusicPath = [[NSBundle mainBundle] pathForResource:@"background_loop" ofType:@"mp3"];
    NSLog(@"BKND PATH %@",backgroundMusicPath);
    NSURL *backgroundMusicURL = [NSURL fileURLWithPath:backgroundMusicPath];
    //NSURL *backgroundMusicURL = url;
    self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:nil];
    self.backgroundMusicPlayer.delegate = self;  // We need this so we can restart after interruptions
    self.backgroundMusicPlayer.numberOfLoops = -1;	// Negative number means loop forever
    self.backgroundMusicPlayer.volume = 0.2;
}
#pragma mark - AVAudioPlayerDelegate methods

- (void) audioPlayerBeginInterruption: (AVAudioPlayer *) player {
    //It is often not necessary to implement this method since by the time
    //this method is called, the sound has already stopped. You don't need to
    //stop it yourself.
    //In this case the backgroundMusicPlaying flag could be used in any
    //other portion of the code that needs to know if your music is playing.
    
    self.backgroundMusicInterrupted = YES;
    self.backgroundMusicPlaying = NO;
}

- (void) audioPlayerEndInterruption: (AVAudioPlayer *) player withOptions:(NSUInteger) flags{
    //Since this method is only called if music was previously interrupted
    //you know that the music has stopped playing and can now be resumed.
    [self tryPlayMusic];
    self.backgroundMusicInterrupted = NO;
}

@end
