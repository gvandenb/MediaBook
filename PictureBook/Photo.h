//
//  BHPhoto.h
//  CollectionViewTutorial
//
//  Created by Bryan Hansen on 11/3/12.
//  Copyright (c) 2012 Bryan Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Photo : NSObject

@property (nonatomic, strong, readonly) NSURL *imageURL;
@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSURL *audioURL;
@property (nonatomic, strong, readonly) NSString *video;
@property (nonatomic, strong, readonly) NSString *hexColor;
@property (nonatomic, assign, readonly) NSInteger start;

+ (Photo *)photoWithImageURL:(NSURL *)imageURL;

- (id)initWithImageURL:(NSURL *)imageURL;
- (void) setTitle:(NSString *)title;
- (void) setColor:(NSString *)hexColor;
- (void) setVideo:(NSString *)video;
- (void) setAudioURL:(NSURL *)audioURL;
- (void) setStart:(NSInteger)start;
- (UIImage *) getImage;
- (NSString *) getTitle;
- (NSString *) getColor;
- (NSString *) getVideo;
- (NSInteger) getStart;

@end
