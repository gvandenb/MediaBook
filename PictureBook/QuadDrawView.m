//
//  LinearInterpView.m
//  PictureBook
//
//  Created by greg vandenberg on 1/17/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "QuadDrawView.h"


@interface QuadDrawView ()

@end

@implementation QuadDrawView
{
    UIBezierPath *path;
    UIImage *incrementalImage;
    NSMutableArray *incrementalImages;
    CGPoint pts[4];
    UIColor *color;
    NSInteger numPhotos;
    uint ctr;
    CGFloat lineWidth;
    
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setMultipleTouchEnabled:NO];
        [self setBackgroundColor:[UIColor whiteColor]];
        path = [UIBezierPath bezierPath];
        lineWidth = 2.0;
        [path setLineWidth:lineWidth];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setMultipleTouchEnabled:NO];
        path = [UIBezierPath bezierPath];
        lineWidth = 12.0;
        [path setLineWidth:lineWidth];
        [path setFlatness:1];
        incrementalImage = [UIImage alloc];
        incrementalImages = [NSMutableArray new];
        
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [incrementalImage drawInRect:rect];
    [color setStroke];
    [path stroke];
}

- (void)setStrokeColor:(UIColor*)_color
{
    color = _color;
}

- (void)setIncrementalImages 
{
    for (int i=0; i<numPhotos; i++) {
        [incrementalImages addObject:[UIImage alloc]];
    }
}

- (void)setNumPhotos:(NSInteger)_numPhotos
{
    numPhotos = _numPhotos;
}

- (void)setLineWidth:(NSInteger) _lineWidth
{
    lineWidth = _lineWidth;
    [path setLineWidth:lineWidth];
}

- (void)clearIncrementalImage:(NSInteger)_imageIndex
{
    UIImage *localImage = [UIImage alloc];
    [incrementalImages replaceObjectAtIndex:_imageIndex withObject:localImage];
    incrementalImage = localImage;
    [self setNeedsDisplay];
}

- (void)resetIncrementalImage:(NSInteger)_imageIndex
{
    incrementalImage = [incrementalImages objectAtIndex:_imageIndex];
    [self setNeedsDisplay];
}

- (void)updateIncrementalImage:(NSInteger)_imageIndex direction:(NSInteger) direction
{

    NSInteger localIndex = _imageIndex - 1;

    // left page direction
    if (direction == 0) {
        localIndex = _imageIndex + 1;
        if (localIndex >= numPhotos - 1) {
            localIndex = 0;
        }
    }
    else {
        if (localIndex == -1) {
            localIndex = 0;
        }
        if (_imageIndex == 0) {
            localIndex = numPhotos - 1;
        }

    }
    UIImage *localImage = [UIImage alloc];
    localImage = incrementalImage;
    [incrementalImages replaceObjectAtIndex:localIndex withObject:localImage];

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    ctr = 0;
    UITouch *touch = [touches anyObject];
    pts[0] = [touch locationInView:self];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"touchesMoved");
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    ctr++;
    pts[ctr] = p;
    if (ctr == 3)
    {
        pts[2] = CGPointMake((pts[1].x + pts[3].x)/2.0, (pts[1].y + pts[3].y)/2.0);
        [path moveToPoint:pts[0]];
        [path addQuadCurveToPoint:pts[2] controlPoint:pts[1]];
        [self setNeedsDisplay];
        pts[0] = pts[2];
        pts[1] = pts[3];
        ctr = 1;
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (ctr == 0) // only one point acquired = user tapped on the screen
    {
        [path addArcWithCenter:pts[0] radius:lineWidth/2 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
        // draw "point"
    }
    else if (ctr == 1)
    {
        [path moveToPoint:pts[0]];
        [path addLineToPoint:pts[1]];
    }
    else if (ctr == 2)
    {
        [path moveToPoint:pts[0]];
        [path addQuadCurveToPoint:pts[2] controlPoint:pts[1]];
    }
    [self drawBitmap];
    [self setNeedsDisplay];
    [path removeAllPoints];
    ctr = 0;
}

- (void) removeAllPoints {
    NSLog(@"Remove All Points.");
    [self setNeedsDisplay];
    [path removeAllPoints];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}
- (void)drawBitmap
{
    NSLog(@"drawBitmap");
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    if (!incrementalImage)
    {
        //UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds];
        //[[UIColor whiteColor] setFill];
        //[rectpath fill];
    }
    [incrementalImage drawAtPoint:CGPointZero];
    [color setStroke];
    [path stroke];
    incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    //incrementalImage
    UIGraphicsEndImageContext();
}
@end