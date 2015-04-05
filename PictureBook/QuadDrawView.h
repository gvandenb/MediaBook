//
//  LinearInterpView.h
//  PictureBook
//
//  Created by greg vandenberg on 1/17/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

@interface QuadDrawView : UIView
- (void)setStrokeColor:(UIColor *) color;
- (void)setNumPhotos:(NSInteger) _numPhotos;
- (void)setIncrementalImages;
- (void)updateIncrementalImage:(NSInteger)image direction:(NSInteger) direction;
- (void) removeAllPoints;
- (void) resetIncrementalImage:(NSInteger)image;
- (void) clearIncrementalImage:(NSInteger)image;
- (void) setLineWidth: (NSInteger) lineWidth;

@end

