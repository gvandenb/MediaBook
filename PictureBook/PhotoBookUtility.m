//
//  PhotoBookUtility.m
//  PictureBook
//
//  Created by greg vandenberg on 3/30/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import "PhotoBookUtility.h"

@implementation PhotoBookUtility

+ (void)formatLabel:(UILabel *)label{
    label.opaque = NO;
    label.font = [UIFont fontWithName:@"Marker Felt" size:48];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    label.layer.borderWidth = 4.0;
    label.layer.cornerRadius = 8;
    label.clipsToBounds = YES;
    [label sizeToFit];
}

+ (AVSpeechUtterance *) getAVSpeechUtterance: (NSString *) speechText {
    AVSpeechUtterance* utterance = [[AVSpeechUtterance alloc] initWithString:speechText];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-UK"];
    utterance.rate = 0.1f;
    utterance.pitchMultiplier = 2.0f;
    return utterance;
}

+ (UIImage *)getYouTubeThumbnailImage: (NSString *)videoURL {
    NSRange start = [videoURL rangeOfString:@"v="];
    NSString *videoId = nil;
    if (start.location != NSNotFound)
    {
        videoId = [videoURL substringFromIndex:start.location + start.length];
    }
    NSString *thumbnailString = [NSString stringWithFormat:@"https://i.ytimg.com/vi/%@/mqdefault.jpg", videoId];
    NSURL *thumbnail = [NSURL URLWithString:thumbnailString];
    NSData *imageData = [NSData dataWithContentsOfURL:thumbnail];
    
    return [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
}

@end
