//
//  BHAlbum.h
//
//  Created by Bryan Hansen on 11/3/12.
//  Copyright (c) 2012 Bryan Hansen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Photo;

@interface Album : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic) NSInteger id;
@property (nonatomic, strong) NSString *albumType;
@property (nonatomic, strong, readonly) NSArray *photos;

- (void)addPhoto:(Photo *)photo;
- (BOOL)removePhoto:(Photo *)photo;

@end
