//
//  PhotoBook.h
//  PictureBook
//
//  Created by greg vandenberg on 1/14/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import "JSONModel.h"

@protocol PhotoBook @end

@interface PhotoBook : JSONModel

@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* image;
@property (strong, nonatomic) NSString* audio;
@property (strong, nonatomic) NSString* color;
@property (strong, nonatomic) NSString* video;
@property (assign, nonatomic) NSInteger start;

@end
