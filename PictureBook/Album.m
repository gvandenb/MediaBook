//
//  BHAlbum.m
//  CollectionViewTutorial
//
//  Created by Bryan Hansen on 11/3/12.
//  Copyright (c) 2012 Bryan Hansen. All rights reserved.
//

#import "Album.h"
#import "Photo.h"

@interface Album ()

@property (nonatomic, strong) NSMutableArray *mutablePhotos;

@end

@implementation Album

@synthesize albumType;
@synthesize id;

#pragma mark - Properties

- (NSArray *)photos
{
    return [self.mutablePhotos copy];
}


#pragma mark - Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        self.mutablePhotos = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Photos

- (void)addPhoto:(Photo *)photo
{
    [self.mutablePhotos addObject:photo];
}

- (BOOL)removePhoto:(Photo *)photo
{
    if ([self.mutablePhotos indexOfObject:photo] == NSNotFound) {
        return NO;
    }
    
    [self.mutablePhotos removeObject:photo];
    
    return YES;
}



@end
