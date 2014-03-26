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
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UISlider *volumeFader;
@property (weak, nonatomic) IBOutlet UILabel *cutoffLabel;

@property (strong, nonatomic) NNPlayer *player;

- (IBAction)playSound:(UIButton*)sender;
- (IBAction)volumeChanged:(id)sender;
- (IBAction)filterCutoffChanged:(id)sender;

@end
