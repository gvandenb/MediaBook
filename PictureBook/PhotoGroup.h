//
//  PhotoGroup.h
//  PictureBook
//
//  Created by greg vandenberg on 1/14/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import "JSONModel.h"
#import "PhotoBook.h"

@protocol PhotoGroup @end

@interface PhotoGroup : JSONModel

@property (nonatomic) NSInteger id;
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* type;
@property (strong, nonatomic) NSMutableArray<PhotoBook>* photobooks;

@end