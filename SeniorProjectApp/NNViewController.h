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
@property (assign, nonatomic) double panning;
@property (assign, nonatomic) double centerFrequency;
@property (assign, nonatomic) double bandwidth;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *panningLabel;
@property (weak, nonatomic) IBOutlet UISlider *volumeFader;
@property (weak, nonatomic) IBOutlet UILabel *volumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *centerFrequencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *bandwidthLabel;
@property (weak, nonatomic) IBOutlet UIView *touchPanel;
@property (strong, nonatomic) IBOutlet UIPinchGestureRecognizer *pinchRecognizer;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (strong, nonatomic) NNPlayer *player;

- (IBAction)playSound:(id)sender;
- (IBAction)volumeChanged:(id)sender;
- (IBAction)pinchDetected:(UIPinchGestureRecognizer *)sender;
- (IBAction)panDetected:(UIPanGestureRecognizer *)sender;
- (IBAction)rotationDectected:(UIRotationGestureRecognizer *)sender;
- (IBAction)switchSound:(id)sender;

@end
