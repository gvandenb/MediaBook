//
//  ViewController.h
//  PictureBook
//
//  Created by greg vandenberg on 1/3/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "OSLabel.h"
#import <SpriteKit/SpriteKit.h>
#import "AudioController.h"
#import "Album.h"
#import "QuadDrawView.h"

@interface ColorBookViewController : UIViewController<NSXMLParserDelegate,UIImagePickerControllerDelegate> {
    IBOutlet UIImageView *imageView;
    IBOutlet UIImageView *transparentView;
    IBOutlet UIImageView *maskView;
    IBOutlet UIButton *reloadAudio;
    IBOutlet UIButton *choosePhotoBtn;
    IBOutlet UIButton *redColor;
    IBOutlet UIButton *yellowColor;
    IBOutlet UIButton *orangeColor;
    IBOutlet UIButton *purpleColor;
    IBOutlet UIButton *brownColor;
    IBOutlet UIButton *greenColor;
    IBOutlet UIButton *blueColor;
    IBOutlet UIButton *blackColor;
    IBOutlet UIButton *tanColor;
    IBOutlet UIButton *paintButton;
    IBOutlet UIButton *pencilButton;
    IBOutlet UIButton *eraser;
    IBOutlet UIButton *leftButton;
    IBOutlet UIButton *rightButton;
    IBOutlet UIButton *homeButton;
    IBOutlet UIButton *clearButton;
    
    IBOutlet UIView *colorPicker;
    IBOutlet UIView *colorTools;
    
    UIButton *selectedButtonColor;
    UIButton *selectedButtonTool;
    
    NSMutableArray *photos;
    NSMutableArray *audioFiles;
    NSMutableArray *photoTitles;

    int numPages;
    IBOutlet OSLabel *photoTitleLabel;
    AVSpeechSynthesizer* mySynthesizer;
    Boolean lockSpellAction;
    Boolean lockPageTap;
    
}
- (IBAction) getPhoto:(id) sender;
- (IBAction)replayAudio:(id)sender;
- (IBAction)pageLeft:(id)sender;
- (IBAction)pageRight:(id)sender;
- (IBAction)setDrawingColor:(id)sender;
- (IBAction)clearIncrementalImage;
- (BOOL)shouldCancel;
- (void) setCurrentAlbum:(Album*)album;
- (void) setImageIndex:(NSInteger)index;
- (UIImage*)processImage:(UIImage*)image;
@end

