//
//  PhotoBookUtility.h
//  PictureBook
//
//  Created by greg vandenberg on 3/30/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface PhotoBookUtility : NSObject

+ (void)formatLabel:(UILabel *)label;
+ (AVSpeechUtterance *) getAVSpeechUtterance: (NSString *) speechText;
+ (UIImage *)getYouTubeThumbnailImage: (NSString *)videoURL;

@end
