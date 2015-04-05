//
//  PhotoBookFeed.h
//  PictureBook
//
//  Created by greg vandenberg on 1/15/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import "JSONModel.h"
#import "Account.h"

@interface PhotoBookFeed : JSONModel

@property (strong, nonatomic) Account* account;

@end
