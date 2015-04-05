//
//  MyScene.m
//  PictureBook
//
//  Created by greg vandenberg on 1/10/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import "MyScene.h"

@implementation MyScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        //self.backgroundColor = [SKColor clearColor];
        SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        myLabel.text = @"Hello, World!";
        myLabel.fontSize = 30;
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));
        
        [self addChild:myLabel];
    }
    return self;
}

-(void)didMoveToView:(SKView *)view
{
    [super didMoveToView:view];
    
    //SKSpriteNode* background = [SKSpriteNode spriteNodeWithImageNamed:@"bknd"];
    //background.size = super.view.frame.size;
    //background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    //[self addChild:background];
}

//particle explosion - uses MyParticle.sks
- (SKEmitterNode *) newExplosion: (float)posX : (float) posy
{
    SKEmitterNode *emitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"MyParticle" ofType:@"sks"]];
    emitter.position = CGPointMake(posX,posy);
    emitter.name = @"explosion";
    emitter.targetNode = self.scene;
    emitter.numParticlesToEmit = 1000;
    emitter.zPosition=2.0;
    return emitter;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        //add effect at touch location
        [self addChild:[self newExplosion:location.x : location.y]];
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end