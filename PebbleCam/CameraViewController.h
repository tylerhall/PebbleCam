#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CaptureSessionManager.h"

@interface CameraViewController : UIViewController {
    AVAudioPlayer *_avplayer;
}

@property (strong) CaptureSessionManager *captureManager;
@property (nonatomic, strong) UILabel *scanningLabel;

@end
