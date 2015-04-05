//
//  ViewController.m
//  PictureBook
//
//  Created by greg vandenberg on 1/3/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import "ColorBookViewController.h"
#import "AudioController.h"
#import <QuartzCore/QuartzCore.h>
#import "MyScene.h"
#import "Album.h"
#import "Photo.h"
#import "GzColors.h"
#import "PhotoBookUtility.h"



@interface ColorBookViewController () <AVSpeechSynthesizerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    BOOL _shouldCancel;
    Album *_currentAlbum;
}
@property (strong, nonatomic) AudioController *audioController;
@property (strong, nonatomic) Album *currentAlbum;
@property (strong, nonatomic) QuadDrawView *smoothView;
@property IBOutlet SKView *skView;
- (void)setShouldCancel:(BOOL)shouldCancel;
- (BOOL)shouldCancel;

@end

NSInteger imageIndex = 0;
NSInteger numPhotos = 0;

@implementation ColorBookViewController

- (void)setShouldCancel:(BOOL)shouldCancel {
    _shouldCancel = shouldCancel;
}

- (BOOL)shouldCancel {
    return _shouldCancel;
}

- (void)setCurrentAlbum:(Album *)album {
    _currentAlbum = album;
}

- (Album *)getCurrentAlbum {
    return _currentAlbum;
}

- (void) setImageIndex:(NSInteger)index {
    imageIndex = index;
}

//- (void)viewWillLayoutSubviews {
    
    //[super viewWillLayoutSubviews];
    
    
    
    /*
    // Configure the SKView
    NSString *myParticlePath = [[NSBundle mainBundle] pathForResource:@"MyParticle" ofType:@"sks"];
    SKEmitterNode *myParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:myParticlePath];
    SKView * skView = _skView;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene * scene = [MyScene sceneWithSize:skView.bounds.size];
    
    CGSize coverageSize = CGSizeMake(2000,2000); //the size of the entire image you want tiled
    CGRect textureSize = CGRectMake(0, 0, 217, 232); //the size of the tile.
    CGImageRef backgroundCGImage = [UIImage imageNamed:@"bknd"].CGImage; //change the string to your image name
    UIGraphicsBeginImageContext(CGSizeMake(coverageSize.width, coverageSize.height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawTiledImage(context, textureSize, backgroundCGImage);
    UIImage *tiledBackground = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    SKTexture *backgroundTexture = [SKTexture textureWithCGImage:tiledBackground.CGImage];
    SKSpriteNode *backgroundTiles = [SKSpriteNode spriteNodeWithTexture:backgroundTexture];
    backgroundTiles.yScale = -1; //upon closer inspection, I noticed my source tile was flipped vertically, so this just flipped it back.
    backgroundTiles.position = CGPointMake(0,0);
    [scene addChild:backgroundTiles];
    
    [scene addChild:myParticle];
    //scene.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"bknd.png"]];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    //SKSpriteNode *sn = [SKSpriteNode spriteNodeWithImageNamed:@"bknd"];
    //[scene addChild:sn];
    
    [skView presentScene:scene];
     */
//}

- (void)loadView {
    [super loadView];

    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    

    photos = [[NSMutableArray alloc] init];
    audioFiles = [[NSMutableArray alloc] init];
    photoTitles = [[NSMutableArray alloc] init];
    mySynthesizer = [[AVSpeechSynthesizer alloc] init];
    numPages = 0;

    self.audioController = [[AudioController alloc] init];
    NSLog(@"Current Album Title: %@", self.currentAlbum.name);
    //NSXMLParser *photoParser = [[NSXMLParser alloc]
    //                             initWithContentsOfURL:
    //    [NSURL URLWithString:@"http://babyphotobook.us/photos.xml"]];
    //[photoParser setDelegate:self];
    //[photoParser parse];
    Photo *photo = [self getCurrentPhoto];
    UIImage *image = photo.image;
    //NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    //UIImage *image = [UIImage imageWithData:imageData];

    [PhotoBookUtility formatLabel:photoTitleLabel];

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[self getCurrentPhotoTitle]];
    [attributedString addAttribute:NSKernAttributeName
                             value:@(4.0)
                             range:NSMakeRange(0, attributedString.length)];
    photoTitleLabel.attributedText = attributedString;
    numPhotos = self.currentAlbum.photos.count;
    
    NSLog(@"Num Photos: %ld", numPhotos);

    //CGFloat x = (super.view.bounds.size.width - imageView.bounds.size.width) / 2;
    //CGFloat y = (super.view.bounds.size.height - imageView.bounds.size.height) / 2;
    //CGFloat width = imageView.bounds.size.width;
    //CGFloat height = imageView.bounds.size.height;
    //_smoothView = [[QuadDrawView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    BOOL SDKIsBelowIOS8 = floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1;
    CGFloat widthBounds = super.view.bounds.size.width;
    CGFloat heightBounds = super.view.bounds.size.height;
    if (SDKIsBelowIOS8) {
        widthBounds = super.view.bounds.size.height;
        heightBounds = super.view.bounds.size.width;
    }

    CGFloat x = (widthBounds - imageView.bounds.size.width) / 2;
    CGFloat y = (heightBounds - imageView.bounds.size.height) / 2;
    CGFloat width = imageView.bounds.size.width;
    CGFloat height = imageView.bounds.size.height;
    transparentView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    _smoothView = [[QuadDrawView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    maskView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,widthBounds,heightBounds)];
    maskView.image = [[UIImage imageNamed: @"mask.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    if ([photo getColor] != nil) {
        NSLog(@"Color: %@", [photo getColor]);
        [maskView setTintColor:[GzColors colorFromHex:[photo getColor]]];
        
    }
    else {
        maskView.image = [UIImage imageNamed: @"mask.png"];
    }
    _smoothView.backgroundColor = [UIColor clearColor];
    [_smoothView setNumPhotos:numPhotos];
    [_smoothView setIncrementalImages];
    [_smoothView setStrokeColor:[UIColor greenColor]];
    
    
    
    //transparentView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    transparentView.layer.cornerRadius = 20;
    transparentView.clipsToBounds = YES;

    imageView.layer.cornerRadius = 20;
    imageView.clipsToBounds = YES;
    imageView.backgroundColor = [UIColor whiteColor];
    imageView.image = image;

    [reloadAudio setBackgroundImage:[UIImage animatedImageNamed:@"reload-md" duration:0.25] forState:UIControlStateHighlighted];
        
    //add the view to the main view
    self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"bknd.png"]];

    colorPicker.layer.cornerRadius = 8;
    colorPicker.clipsToBounds = YES;
    
    [colorPicker addSubview:redColor];
    [colorPicker addSubview:yellowColor];
    [colorPicker addSubview:greenColor];
    [colorPicker addSubview:blueColor];
    [colorPicker addSubview:brownColor];
    [colorPicker addSubview:orangeColor];
    [colorPicker addSubview:purpleColor];
    [colorPicker addSubview:blackColor];
    [colorPicker addSubview:tanColor];
    
    [pencilButton setTag:12];
    [self setDrawingColor:redColor];
    [self buttonDidTap:pencilButton];
    [pencilButton addTarget:self action:@selector(buttonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [paintButton setTag:30];
    [paintButton addTarget:self action:@selector(buttonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [eraser setTag:6];
    [eraser addTarget:self action:@selector(buttonDidTap:) forControlEvents:UIControlEventTouchUpInside];

    [colorTools addSubview:paintButton];
    [colorTools addSubview:pencilButton];
    [colorTools addSubview:eraser];
    [colorTools addSubview:clearButton];
    colorTools.layer.cornerRadius = 8;
    colorTools.clipsToBounds = YES;
    
    
    //colorPicker.bounds = CGRectInset(colorPicker.frame, 10.0f, 10.0f);
    if ([self.currentAlbum.albumType  isEqual: @"Color"]) {
        [self.view addSubview:_smoothView];
        transparentView.image = [self processImage:image];
        transparentView.contentMode = UIViewContentModeScaleAspectFit;
        transparentView.userInteractionEnabled = NO;
        [self.view addSubview:transparentView];
        [self.view addSubview:maskView];
        
        [self.view addSubview:leftButton];
        [self.view addSubview:rightButton];
        colorPicker.hidden = NO;
        colorTools.hidden = NO;
        [self.view addSubview:colorPicker];
        [self.view addSubview:colorTools];
        [self.view bringSubviewToFront:leftButton];
        [self.view bringSubviewToFront:rightButton];
    }
    else {
        [self.view addSubview:maskView];
        colorPicker.hidden = YES;
        leftButton.hidden = YES;
        rightButton.hidden = YES;
    }

    [self.view addSubview:reloadAudio];
    [self.view addSubview:homeButton];
    //[self.view addSubview:choosePhotoBtn];
    [self.view addSubview:photoTitleLabel];
    
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(spellTitle:)];
    UITapGestureRecognizer *tapGestureRecognizerLeft = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pageLeft:)];
    UITapGestureRecognizer *tapGestureRecognizerRight = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pageRight:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:@"refreshView" object:nil];

    // Setting the swipe direction.
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    
    // Adding the swipe gesture on image view
    if (![self.currentAlbum.albumType isEqual: @"Color"]) {
        [imageView addGestureRecognizer:swipeLeft];
        [imageView addGestureRecognizer:swipeRight];
        [leftButton addGestureRecognizer:tapGestureRecognizerLeft];
        [rightButton addGestureRecognizer:tapGestureRecognizerRight];
    }
    [imageView addGestureRecognizer:tapGestureRecognizer];
    [photoTitleLabel addGestureRecognizer:tapGestureRecognizer1];
    photoTitleLabel.userInteractionEnabled = YES;
    [imageView setUserInteractionEnabled:YES];
    
    AVSpeechUtterance* utterance = [PhotoBookUtility getAVSpeechUtterance:[self getCurrentPhotoTitle]];
    utterance.preUtteranceDelay = .5;
    [mySynthesizer speakUtterance:utterance];
    
    [self.audioController configureAudioPlayerRemote:[self getCurrentAudio]];
    [self.audioController tryPlayRemoteMusic];
    
    
}

-(void)buttonDidTap:(UIButton *)sender{
    NSInteger index = sender.tag;
    [pencilButton setBackgroundImage:[UIImage imageNamed:@"pencil.png"] forState:UIControlStateNormal];
    [paintButton setBackgroundImage:[UIImage imageNamed:@"paintbrush.png"] forState:UIControlStateNormal];
    [eraser setBackgroundImage:[UIImage imageNamed:@"eraser.png"] forState:UIControlStateNormal];
    
    if (index == 12) {
        [pencilButton setBackgroundImage:[UIImage imageNamed:@"pencil_blue.png"] forState:UIControlStateNormal];
        selectedButtonTool = pencilButton;
        [self setDrawingColor:selectedButtonColor];
    }
    if (index == 30) {
        [paintButton setBackgroundImage:[UIImage imageNamed:@"paintbrush_blue.png"] forState:UIControlStateNormal];
        selectedButtonTool = paintButton;
        [self setDrawingColor:selectedButtonColor];
    }
    if (index == 6) {
        [eraser setBackgroundImage:[UIImage imageNamed:@"eraser_blue.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)replayAudio:(id)sender {
//    if (!lockPageTap) {
//        lockPageTap = true;
//        AVSpeechUtterance* utterance = [self getAVSpeechUtterance:[self getCurrentPhotoTitle]];
//        utterance.preUtteranceDelay = .5;
//        [mySynthesizer speakUtterance:utterance];
//    }
    [self.audioController configureAudioPlayerRemote:[self getCurrentAudio]];
    [self.audioController tryPlayRemoteMusic];

}

- (IBAction)clearIncrementalImage {
    [_smoothView clearIncrementalImage:[self getImageIndex]];
}

- (UIImage*)processImage:(UIImage*)image
{
    const CGFloat colorMasking[6]={222.0,255.0,222.0,255.0,222.0,255.0};
    CGImageRef imageRef = CGImageCreateWithMaskingColors(image.CGImage, colorMasking);
    UIImage* imageB = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return imageB;
}

- (IBAction)setDrawingColor:(id)sender {
    NSLog(@"setDrawingColor: %@", sender);
    
    UIButton *selectedButton = (UIButton *)sender;
    UIColor *color = selectedButton.backgroundColor;
    NSInteger index = selectedButton.tag;

    // reset selected state to normal
    if (index != 6) {
        [eraser setBackgroundImage:[UIImage imageNamed:@"eraser.png"] forState:UIControlStateNormal];
        NSArray *subviews = [colorPicker subviews];
        for (int i=0; i < [subviews count]; i++) {
            UIButton *button = (UIButton*)[subviews objectAtIndex:i];
            [button setImage:nil forState:UIControlStateNormal];

        }
        [selectedButton setImage:[UIImage imageNamed:@"buttonSelected.png"] forState:UIControlStateNormal];
        selectedButtonColor = selectedButton;
        
        
    }
    NSLog(@"selectedButtonTool tag: %ld",selectedButtonTool.tag);
    if (selectedButtonTool.tag == 12) {
        [pencilButton setBackgroundImage:[UIImage imageNamed:@"pencil_blue.png"] forState:UIControlStateNormal];
        [paintButton setBackgroundImage:[UIImage imageNamed:@"paintbrush.png"] forState:UIControlStateNormal];
    }
    if (selectedButtonTool.tag == 30) {
        [paintButton setBackgroundImage:[UIImage imageNamed:@"paintbrush_blue.png"] forState:UIControlStateNormal];
        [pencilButton setBackgroundImage:[UIImage imageNamed:@"pencil.png"] forState:UIControlStateNormal];
    }
    [_smoothView setStrokeColor:color];
    
}

- (IBAction)setStrokeWidth:(id)sender {
    NSLog(@"setStrokeWidth: %@", sender);
    UIButton *button = (UIButton *)sender;
    NSInteger lineWidth = button.tag;
    [_smoothView setLineWidth:lineWidth];
    
}

- (void)spellTitle: (UITapGestureRecognizer *)recognizer {
    NSLog(@"Spell Title");
    Boolean spellCurrentLabel = [[NSUserDefaults standardUserDefaults] boolForKey:@"spellCurrentLabel"];
    if (spellCurrentLabel) {
        if (lockPageTap == false && lockSpellAction == false) {
            [self spellTextLabel: -1 currentPageTitle:[self getCurrentPhotoTitle]];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark === AVSpeechSynthesizerDelegate ===
#pragma mark -

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance
{
    //NSLog(@"UTTERANCE WILL SPEAK");
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance
{
    lockPageTap = false;
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        if (lockPageTap) return;
        imageIndex++;
        [self pageAction:UIViewAnimationOptionTransitionFlipFromRight direction:1];
    }
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
        if (lockPageTap) return;
        imageIndex--;
        [self pageAction:UIViewAnimationOptionTransitionFlipFromLeft direction:0];
    }
    
}
                                   
- (void) handleTapFrom: (UITapGestureRecognizer *)recognizer
{
    [self pageRight:recognizer];
}

- (void) pageLeft: (UITapGestureRecognizer *)recognizer
{
    //Code to handle the gesture
    if (lockPageTap) return;
    imageIndex--;
    [self pageAction:UIViewAnimationOptionTransitionFlipFromRight direction:0];
}

- (void) pageRight: (UITapGestureRecognizer *)recognizer
{
    //Code to handle the gesture
    if (lockPageTap) return;
    imageIndex++;
    [self pageAction:UIViewAnimationOptionTransitionFlipFromLeft direction:1];
}

-(void)refreshView:(NSNotification *) notification {
    if (![self.currentAlbum.albumType isEqual:@"Color"]) {
        if (lockPageTap) return;
        imageIndex++;
        [self pageAction:UIViewAnimationOptionTransitionFlipFromRight direction:1];
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {
    if ( [elementName isEqualToString:@"photo"]) {
        numPhotos++;
        [photos addObject:[attributeDict objectForKey:@"url"]];
        [audioFiles addObject:[attributeDict objectForKey:@"audio"]];
        [photoTitles addObject:[attributeDict objectForKey:@"title"]];
    }
}

- (void) pageAction: (UIViewAnimationOptions) transition direction:(NSInteger)direction {
    lockPageTap = true;
    UIImage *toImage = [self getCurrentImage];
    UIImage *transparentImage = [self processImage:toImage];
    if ([self.currentAlbum.albumType  isEqual: @"Color"]) {
        transparentView.hidden = YES;
        NSLog(@"Direction: %ld", direction);
        [_smoothView updateIncrementalImage:[self getImageIndex] direction: direction];
        [_smoothView resetIncrementalImage:[self getImageIndex]];
    }
    [UIView transitionWithView:imageView
                      duration:0.5f
                       options:transition
                    animations:^{
                        imageView.image = toImage;
                    } completion:^(BOOL finished) {
                        if ([self.currentAlbum.albumType  isEqual: @"Color"]) {
                            transparentView.image = transparentImage;
                            transparentView.hidden = NO;
                            
                        }
                        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[self getCurrentPhotoTitle]];
                        [attributedString addAttribute:NSKernAttributeName
                                                 value:@(4.0)
                                                 range:NSMakeRange(0, attributedString.length)];
                        
                        photoTitleLabel.attributedText = attributedString;
                        
                        AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
                        synthesizer.delegate = self;
                        AVSpeechUtterance* utterance = [PhotoBookUtility getAVSpeechUtterance:[self getCurrentPhotoTitle]];
                        utterance.preUtteranceDelay = .25;
                        [synthesizer speakUtterance:utterance];
                        
                        //UIImage * toImage = [UIImage imageNamed:@"myname.png"];
                        /*
                        [UIView transitionWithView:imageView
                                          duration:1.0f
                                           options:UIViewAnimationOptionTransitionCrossDissolve
                                        animations:^{
                                            imageView.image = toImage;
                                        } completion:nil];
                        */
                        [self.audioController configureAudioPlayerRemote:[self getCurrentAudio]];
                        [self.audioController tryPlayRemoteMusic];
                    }];

    [self pageBackgroundColor: ++numPages];
}

- (UIImage *)convertImageToGrayScale:(UIImage *)image
{
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create bitmap content with current image size and grayscale colorspace
    // TODO: fix this line with the correct CGBitmapInfo
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGBitmapByteOrder16Big);
    
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    // Create bitmap image info from pixel data in current context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    // Create a new UIImage object
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    
    // Release colorspace, context and bitmap information
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    
    // Return the new grayscale image
    return newImage;
}

-(IBAction) getPhoto:(id) sender {
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    
    // Don't forget to add UIImagePickerControllerDelegate in your .h
    picker.delegate = self;
    
    if((UIButton *) sender == choosePhotoBtn) {
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    } else {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void) pageBackgroundColor: (int) _numPages {
    NSString *imageName = [NSString stringWithFormat:@"bknd%d.png", _numPages];
    self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: imageName]];

    // we have 8 background images in the app
    if (_numPages == 8) {
        numPages = 0;
    }
}

- (void) spellTextLabel: (NSInteger)charCount currentPageTitle: (NSString *)currentPage {
    
    lockSpellAction = true;
    
    NSString *labelText = [self getCurrentPhotoTitle];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[self getCurrentPhotoTitle]];
    charCount++;

    int64_t delayInSeconds = 1;
    //photoTitleLabel.backgroundColor = [UIColor colorWithRed:5.0/255 green:142.0/255 blue:187.0/255 alpha:0.5];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * (NSEC_PER_SEC * .8));
    if (charCount < attributedString.length) {
        
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            if (currentPage == labelText) {
                [attributedString addAttribute:NSForegroundColorAttributeName
                                         value:[UIColor yellowColor]
                                         range:NSMakeRange(0, charCount + 1)];
                [attributedString addAttribute:NSKernAttributeName
                                         value:@(4.0)
                                         range:NSMakeRange(0, attributedString.length)];
                photoTitleLabel.attributedText = attributedString;
                
                NSString * singleChar = [labelText substringWithRange:NSMakeRange(charCount, 1)];
                AVSpeechUtterance* utterance = [PhotoBookUtility getAVSpeechUtterance:singleChar.lowercaseString];
                [mySynthesizer speakUtterance:utterance];
                [self spellTextLabel:charCount currentPageTitle:currentPage];
            }
            else {
                
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
                [attributedString addAttribute:NSForegroundColorAttributeName
                                         value:[UIColor whiteColor]
                                         range:NSMakeRange(0, attributedString.length)];
                [attributedString addAttribute:NSKernAttributeName
                                         value:@(4.0)
                                         range:NSMakeRange(0, attributedString.length)];
                
                static dispatch_queue_t q=nil;
                q=dispatch_get_global_queue(0,0);
                dispatch_suspend(q);
                q=nil;
                
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    photoTitleLabel.attributedText = attributedString;
                    //photoTitleLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
                    lockSpellAction = false;
                });
                
                return;
            }
        });
    }
    else {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[self getCurrentPhotoTitle]];
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:[UIColor whiteColor]
                                 range:NSMakeRange(0, attributedString.length)];
        [attributedString addAttribute:NSKernAttributeName
                                 value:@(4.0)
                                 range:NSMakeRange(0, attributedString.length)];
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            photoTitleLabel.attributedText = attributedString;
            //photoTitleLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];

        });
        AVSpeechUtterance* utterance = [PhotoBookUtility getAVSpeechUtterance:[self getCurrentPhotoTitle]];
        [mySynthesizer speakUtterance:utterance];
        lockSpellAction = false;
    }
    
}

- (NSInteger) getImageIndex {
    if (imageIndex > numPhotos-1) {
        imageIndex = 0;
    }
    if (imageIndex < 0) {
        imageIndex = numPhotos - 1;
    }
    return imageIndex;
}

- (UIImage *) getCurrentImage {
    Photo *photo = self.currentAlbum.photos[[self getImageIndex]];
    return photo.image;
}

- (NSURL *) getCurrentAudio {
    Photo *photo = self.currentAlbum.photos[[self getImageIndex]];
    return photo.audioURL;
}

- (NSString *) getCurrentPhotoTitle {
    Photo *photo = self.currentAlbum.photos[[self getImageIndex]];
    return [photo getTitle];
}

- (Photo *) getCurrentPhoto {
    return self.currentAlbum.photos[[self getImageIndex]];
}


@end
