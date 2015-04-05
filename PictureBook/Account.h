//
//  Account.h
//  PictureBook
//
//  Created by greg vandenberg on 1/19/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import "JSONModel.h"
#import "Account.h"
#import "PhotoGroup.h"

@interface Account : JSONModel

@property (strong, nonatomic) NSMutableArray<PhotoGroup> *photogroups;

@end
