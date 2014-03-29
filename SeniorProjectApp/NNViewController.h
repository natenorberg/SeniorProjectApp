//
//  NNViewController.h
//  SeniorProjectApp
//
//  Created by Nate Norberg on 3/19/14.
//  Copyright (c) 2014 Nate Norberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>
#include "NNPlayer.h"

@interface NNViewController : UIViewController
{
    AVAudioPlayer *audioPlayer;
    double graphSampleRate;
}
@property (assign, nonatomic) double volume;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UISlider *volumeFader;
@property (weak, nonatomic) IBOutlet UILabel *cutoffLabel;
@property (weak, nonatomic) IBOutlet UILabel *volumeLabel;
@property (strong, nonatomic) IBOutlet UIPinchGestureRecognizer *pinchRecognizer;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (strong, nonatomic) NNPlayer *player;

- (IBAction)playSound:(id)sender;
- (IBAction)volumeChanged:(id)sender;
- (IBAction)filterCutoffChanged:(id)sender;
- (IBAction)pinchDetected:(UIPinchGestureRecognizer *)sender;
- (IBAction)panDetected:(UIPanGestureRecognizer *)sender;

@end
