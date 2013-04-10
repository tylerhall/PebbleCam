// Much of this code was taken from: http://www.musicalgeometry.com/?p=1297

#import "CameraViewController.h"

@interface CameraViewController ()
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
@end

@implementation CameraViewController

@synthesize captureManager;
@synthesize scanningLabel;
@synthesize camera;
@synthesize cameraFlipButton = _cameraFlipButton;

- (void)viewDidLoad {

    [self updateCaptureManager];

    _cameraFlipButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_cameraFlipButton addTarget:self action:@selector(switchCamera:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage * switchCameraImage = [UIImage imageNamed:@"switchCamera.png"];
    UIImage * switchCameraImagePressed = [UIImage imageNamed:@"switchCameraPressed.png"];
    
    [_cameraFlipButton setBackgroundImage:switchCameraImage forState:UIControlStateNormal];
    [_cameraFlipButton setBackgroundImage:switchCameraImagePressed forState:UIControlStateHighlighted];
    
    _cameraFlipButton.frame = CGRectMake(246.8, 12.0, 61.2, 32.0);
    [_cameraFlipButton setBackgroundColor:[UIColor clearColor]];
    [[self view] addSubview:_cameraFlipButton];
    
    
    UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 50, 120, 30)];
    [self setScanningLabel:tempLabel];
	[scanningLabel setBackgroundColor:[UIColor clearColor]];
	[scanningLabel setFont:[UIFont fontWithName:@"Courier" size: 18.0]];
	[scanningLabel setTextColor:[UIColor redColor]]; 
	[scanningLabel setText:@"Saving..."];
    [scanningLabel setHidden:YES];
	[[self view] addSubview:scanningLabel];	
  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveImageToPhotoAlbum) name:kImageCapturedSuccessfully object:nil];
  
	[[captureManager captureSession] startRunning];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    NSURL *audioFileLocationURL = [[NSBundle mainBundle] URLForResource:@"5min" withExtension:@"mp3"];
    NSError *error;
    _avplayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileLocationURL error:&error];
    [_avplayer setNumberOfLoops:-1];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    [_avplayer prepareToPlay];
    [_avplayer play];

    NSDictionary *metaData = [NSDictionary dictionaryWithObject:@"Snap Picure" forKey:MPMediaItemPropertyTitle];
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = metaData;
}


- (void)updateCaptureManager
{
    [self setCaptureManager:[[CaptureSessionManager alloc] init]];
    
	[[self captureManager] addVideoInputFrontCamera:camera]; // set to current camera
    [[self captureManager] addStillImageOutput];
	[[self captureManager] addVideoPreviewLayer];
	CGRect layerRect = [[[self view] layer] bounds];
    [[[self captureManager] previewLayer] setBounds:layerRect];
    [[[self captureManager] previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect))];
	[[[self view] layer] addSublayer:[[self captureManager] previewLayer]];
}



- (void)switchCamera:(id)sender
{
    [self setCamera:![self camera]]; //toggle camera between front and back
    [self updateCaptureManager];     //update the captureManager with the new camera view
    [[[self captureManager] captureSession] startRunning];
    [[self view] bringSubviewToFront:_cameraFlipButton];
}


- (void)saveImageToPhotoAlbum
{
  UIImageWriteToSavedPhotosAlbum([[self captureManager] stillImage], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
  if (error != NULL) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Image couldn't be saved" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
  }
  else {
    [[self scanningLabel] setHidden:YES];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}


- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlNextTrack:
            [self switchCamera:self];
            break;
        default:
            [[self captureManager] captureStillImage];
            break;
    }
}

@end

