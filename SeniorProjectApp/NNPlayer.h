//
//  NNPlayer.h
//  SeniorProjectApp
//
//  Created by Nate Norberg on 3/22/14.
//  Copyright (c) 2014 Nate Norberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

typedef struct GraphPlayer {
    AudioStreamBasicDescription inputFormat;
    AudioFileID inputFile;
    AUGraph graph;
    AudioUnit fileAU;
    AudioUnit filterAU;
    AudioUnit mixerAU;
    AudioUnit reverbAU;
    AudioUnit outputAU;
} GraphPlayer;

@interface NNPlayer : NSObject
{
    GraphPlayer player;
    Float64 fileDuration;
    
    AudioUnit outputUnit;
}

@property (assign, nonatomic) Boolean isPlaying;

-(void)playSound;
-(void)stopSound;
-(void)setVolume:(double)volume;
-(void)setPanning:(double)panning;
// Filter settings
-(void)setCenterFrequency:(double)frequency;
-(void)setBandwidth:(double)bandwidth;
@end
