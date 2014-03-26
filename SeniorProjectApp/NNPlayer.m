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
        NSString *path = [NSString stringWithFormat:@"%@/synth_strings.aiff", [[NSBundle mainBundle] resourcePath]];
        NSURL *inputFileURL = [NSURL fileURLWithPath:path];
        
        //    NSURL *inputFileURL = [[NSBundle mainBundle] URLForResource:@"synth_strings" withExtension:@"aiff"];
        
        //    CFURLRef inputFileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, url, kCFURLPOSIXPathStyle, false);
        //    CFURLRef inputFileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, kInputFileLocation, kCFURLPOSIXPathStyle, false);
        
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
    
    // Sleep until the file is finished
    usleep((int)(fileDuration * 1000.0 * 1000.0));
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
    
    // Generate description that matches output device
    AudioComponentDescription outputDescription = {0};
    outputDescription.componentType = kAudioUnitType_Output;
    outputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    outputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Adds a node with the output description to the graph
    AUNode outputNode;
    CheckError(AUGraphAddNode(player->graph, &outputDescription, &outputNode), "AUGraphAddNode[kAudioUnitSubType_DefaultOutput] failed");
    
    // Create a description that matches the audio player
    AudioComponentDescription playerDescription = {0};
    playerDescription.componentType = kAudioUnitType_Generator;
    playerDescription.componentSubType = kAudioUnitSubType_AudioFilePlayer;
    playerDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Add a node with the player description to the graph
    AUNode playerNode;
    CheckError(AUGraphAddNode(player->graph, &playerDescription, &playerNode), "AUGraphAddNode[kAudioUnitSubType_AudioFilePlayer] failed");
    
    // Opening the graph opens all contained audio units but does not allocate any resources yet
    CheckError(AUGraphOpen(player->graph), "AUGraphOpen failed");
    
    // Get the reference to the AudioUnit object for the file player graph node
    CheckError(AUGraphNodeInfo(player->graph, playerNode, NULL, &player->fileAU), "AUGraphNodeInfo failed");
    
    // Connect the nodes
    CheckError(AUGraphConnectNodeInput(player->graph, playerNode, 0, outputNode, 0), "AUGraphConnectNodeInput failed");
    
    // Initialize the AUGraph
    CheckError(AUGraphInitialize(player->graph), "AUGraphInitialize failed");
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
    region.mLoopCount = 1;
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
