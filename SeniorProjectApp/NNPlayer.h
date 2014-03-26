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
} GraphPlayer;

@interface NNPlayer : NSObject
{
    GraphPlayer player;
    Float64 fileDuration;
}
-(void)playSound;

@end
