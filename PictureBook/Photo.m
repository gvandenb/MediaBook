//
//  BHPhoto.m
//  CollectionViewTutorial
//
//  Created by Bryan Hansen on 11/3/12.
//  Copyright (c) 2012 Bryan Hansen. All rights reserved.
//

#import "Photo.h"

@interface Photo ()

@property (nonatomic, strong, readwrite) NSURL *imageURL;
@property (nonatomic, strong, readwrite) UIImage *image;
@property (nonatomic, strong, readwrite) NSString *title;
@property (nonatomic, strong, readwrite) NSString *hexColor;
@property (nonatomic, strong, readwrite) NSURL *audioURL;
@property (nonatomic, strong, readwrite) NSString *video;
@property (nonatomic, assign, readwrite) NSInteger start;

@end

@implementation Photo


#pragma mark - Properties

- (UIImage *)image
{
    if (!_image && self.imageURL) {
        NSData *imageData = [NSData dataWithContentsOfURL:self.imageURL];
        UIImage *image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
        
        _image = image;
    }
    
    return _image;
}

#pragma mark - Lifecycle

+ (Photo *)photoWithImageURL:(NSURL *)imageURL
{
    return [[self alloc] initWithImageURL:imageURL];
}

- (id)initWithImageURL:(NSURL *)imageURL
{
    self = [super init];
    if (self) {
        self.imageURL = imageURL;
    }
    return self;
}

- (void) setTitle:(NSString *)title {
    _title = title;
}

- (NSString *) getTitle {
    return _title;
}

- (void) setVideo:(NSString *)video {
    _video = video;
}

- (NSString *) getVideo {
    return _video;
}

- (void) setAudioURL:(NSURL *)audioURL {
    _audioURL = audioURL;
}

- (UIImage *) getImage {
    return _image;
}

- (void) setColor:(NSString *)hexColor {
    _hexColor = hexColor;
}

- (NSString *) getColor {
    return _hexColor;
}

- (void) setStart:(NSInteger)start {
    _start = start;
}

- (NSInteger) getStart {
    return _start;
}



@end
