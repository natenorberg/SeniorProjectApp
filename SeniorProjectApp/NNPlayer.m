//
//  NNPlayer.m
//  SeniorProjectApp
//
//  Created by Nate Norberg on 3/22/14.
//  Copyright (c) 2014 Nate Norberg. All rights reserved.
//

#import "NNPlayer.h"

#define kInputFileLocation CFSTR("/Users/norberg/Documents/XCodeProjects/SeniorProject/Resources/synth_strings.aiff")

@implementation NNPlayer

-(id)init {
    if (self = [super init]) {
        NSString *path = [NSString stringWithFormat:@"%@/breath_e_trimed.aiff", [[NSBundle mainBundle] resourcePath]];
        NSURL *inputFileURL = [NSURL fileURLWithPath:path];
        
        // Open the input audio file
        CheckError(AudioFileOpenURL((__bridge CFURLRef)(inputFileURL), kAudioFileReadPermission, 0, &player.inputFile), "AudioFileOpenURL failed");
        CFRelease((__bridge CFTypeRef)(inputFileURL));
        
        // Get the audio data format from the file
        UInt32 propSize = sizeof(player.inputFormat);
        CheckError(AudioFileGetProperty(player.inputFile, kAudioFilePropertyDataFormat, &propSize, &player.inputFormat), "Couldn't get file's data format");
        
        // Build a basic graph
        CreateAUGraph(&player);
        
        // Configure the file player
        fileDuration = PrepareFileAU(&player);
        
        return self;
    }
    else {
        return nil;
    }
    
}

-(void)playSound {
    // Start playing
    CheckError(AUGraphStart(player.graph), "AUGraphStart failed");
    _isPlaying = true;
}

-(void)stopSound {
    // Stop playing
    NSLog(@"Stopped");
    CheckError(AUGraphStop(player.graph), "AUGraphStop failed");
    _isPlaying = false;
}


-(void)setVolume:(double)volume {
    CheckError(AudioUnitSetParameter(player.mixerAU, kMultiChannelMixerParam_Volume, kAudioUnitScope_Output, 0, volume, 0),
               "Set volume failed");
}

-(void)setPanning:(double)panning {
    CheckError(AudioUnitSetParameter(player.mixerAU, kMultiChannelMixerParam_Pan, kAudioUnitScope_Output, 0, panning, 0),
               "Set panning failed");
}

-(void)setCenterFrequency:(double)frequency {
    CheckError(AudioUnitSetParameter(player.filterAU, kBandpassParam_CenterFrequency, kAudioUnitScope_Global, 0, frequency, 0),
               "Set cutoff frequency failed");
}

-(void)setBandwidth:(double)bandwidth {
    CheckError(AudioUnitSetParameter(player.filterAU, kBandpassParam_Bandwidth, kAudioUnitScope_Global, 0, bandwidth, 0),
               "Set bandwidth failed");
}

// Error handling function
static void CheckError(OSStatus error, const char *operation) {
    if (error == noErr) return;
    
    char errorString[20];
    // See if it appears to be a 4-char code
    *(UInt32 *)(errorString+1) = CFSwapInt16HostToBig(error);
    if (isprint(errorString[1]) && isprint(errorString[2]) && isprint(errorString[3]) &&isprint(errorString[4])) {
        errorString[0] = errorString[5] = '\'';
        errorString[6] = '\0';
    }
    else {
        // It's an integer
        sprintf(errorString, "%d", (int)error);
    }
    
    fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
    
    exit(1);
}

void CreateAUGraph(GraphPlayer *player) {
    //Create a new AUGraph
    CheckError(NewAUGraph(&player->graph), "NewAUGraph failed");
    
    AUNode outputNode = CreateNode(kAudioUnitType_Output, kAudioUnitSubType_RemoteIO, player->graph);
    AUNode mixerNode  = CreateNode(kAudioUnitType_Mixer, kAudioUnitSubType_MultiChannelMixer, player->graph);
    AUNode reverbNode = CreateNode(kAudioUnitType_Effect, kAudioUnitSubType_Reverb2, player->graph);
    AUNode filterNode = CreateNode(kAudioUnitType_Effect, kAudioUnitSubType_BandPassFilter, player->graph);
    AUNode playerNode = CreateNode(kAudioUnitType_Generator, kAudioUnitSubType_AudioFilePlayer, player->graph);
    
    // Opening the graph opens all contained audio units but does not allocate any resources yet
    CheckError(AUGraphOpen(player->graph), "AUGraphOpen failed");
    
    // Get the reference to the AudioUnit object for the file player graph node
    CheckError(AUGraphNodeInfo(player->graph, playerNode, NULL, &player->fileAU), "AUGraphNodeInfo failed");
    
    // Get the reference to the AudioUnit object for the filter graph node
    CheckError(AUGraphNodeInfo(player->graph, filterNode, NULL, &player->filterAU), "AUGraphNodeInfo failed");
    
    // Get the reference to the AudioUnit object for the reverb graph node
    CheckError(AUGraphNodeInfo(player->graph, reverbNode, NULL, &player->reverbAU), "Get reverb AudioUnit failed");
    
    // Get the reference to the AudioUnit object for the mixer graph node
    CheckError(AUGraphNodeInfo(player->graph, mixerNode, NULL, &player->mixerAU), "Get mixer AudioUnit failed");
    
    // Get the reference to the AudioUnit object for the output node
    CheckError(AUGraphNodeInfo(player->graph, outputNode, NULL, &player->outputAU), "Get output AudioUnit failed");
    
    // Connect the nodes
    CheckError(AUGraphConnectNodeInput(player->graph, playerNode, 0, filterNode, 0), "Player -> Filter failed");
    CheckError(AUGraphConnectNodeInput(player->graph, filterNode, 0, reverbNode, 0), "Filter -> Reverb failed");
    CheckError(AUGraphConnectNodeInput(player->graph, reverbNode, 0, mixerNode,  0), "Reverb -> Mixer failed");
    CheckError(AUGraphConnectNodeInput(player->graph, mixerNode,  0, outputNode, 0), "Mixer -> Output failed");
    
    // Initialize the AUGraph
    CheckError(AUGraphInitialize(player->graph), "AUGraphInitialize failed");
}

// Creates an AUNode and adds it to the graph
AUNode CreateNode(OSType componentType, OSType componentSubType, AUGraph graph) {
    AudioComponentDescription description = {0};
    description.componentType = componentType;
    description.componentSubType = componentSubType;
    description.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    AUNode node;
    CheckError(AUGraphAddNode(graph, &description, &node), "AUGraphAddNodeFailed");
    
    return node;
}

Float64 PrepareFileAU(GraphPlayer *player) {
    
    // Tell the file player unit to load the file we want to play
    CheckError(AudioUnitSetProperty(player->fileAU, kAudioUnitProperty_ScheduledFileIDs, kAudioUnitScope_Global, 0,
                                    &player->inputFile, sizeof(player->inputFile)), "AudioUnitSetProperty[kAudioUnitProperty_ScheduledFileIDs] failed");
    
    UInt64 numPackets;
    UInt32 propSize = sizeof(numPackets);
    CheckError(AudioFileGetProperty(player->inputFile, kAudioFilePropertyAudioDataPacketCount, &propSize, &numPackets),
               "AudioFileGetProperty[kAudioFilePropertyAudioDataPacketCount failed");
    
    // Tell the file player AU to play the entire file
    ScheduledAudioFileRegion region;
    memset(&region.mTimeStamp, 0, sizeof(region.mTimeStamp));
    region.mTimeStamp.mFlags = kAudioTimeStampSampleTimeValid;
    region.mTimeStamp.mSampleTime = 0;
    region.mCompletionProc = NULL;
    region.mCompletionProcUserData = NULL;
    region.mAudioFile = player->inputFile;
    region.mLoopCount = -1;
    region.mStartFrame = 0;
    region.mFramesToPlay = numPackets * player->inputFormat.mFramesPerPacket;
    CheckError(AudioUnitSetProperty(player->fileAU, kAudioUnitProperty_ScheduledFileRegion, kAudioUnitScope_Global, 0, &region, sizeof(region)),
               "AudioUnitSetProperty[kAudioUnitProperty_ScheduledFileRegion] failed");
    
    // Tell the file AU when to start playing (-1 sample time means next render cycle)
    AudioTimeStamp startTime;
    memset(&startTime, 0, sizeof(startTime));
    startTime.mFlags = kAudioTimeStampSampleTimeValid;
    startTime.mSampleTime = -1;
    CheckError(AudioUnitSetProperty(player->fileAU, kAudioUnitProperty_ScheduleStartTimeStamp, kAudioUnitScope_Global, 0, &startTime, sizeof(startTime)),
               "AudioUnitSetProperty[kAudioUnitProperty_ScheduleStartTimeStamp] failed");
    
    // Find file duration in seconds and return it
    return (numPackets * player->inputFormat.mFramesPerPacket) / player->inputFormat.mSampleRate;
}

@end
