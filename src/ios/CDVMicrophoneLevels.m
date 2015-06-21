//
//  CDVMicrophoneLevels.m
//  phonegap-mic-levels
//
//  Created by Theodore Koterwas work on 13/06/2015.
//  Copyright (c) 2015 University of Oxford. All rights reserved.
//

#import "CDVMicrophoneLevels.h"

@implementation CDVMicrophoneLevels
@synthesize recorder = _recorder;

-(void)setup:(CDVInvokedUrlCommand*)command
{
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
    
    if (error) {
        NSLog(@"Error setting category: %@", [error description]);
    }

    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                              nil];
    
    NSError *error;
    
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
    if (!self.recorder) {
        NSLog(@"error:%@", [error description]);
    }

}

-(void)start:(CDVInvokedUrlCommand*)command
{
    [self setup:nil];
    if (self.recorder) {
        [self.recorder prepareToRecord];
        self.recorder.meteringEnabled = YES;
        [self.recorder record];
    }
}

-(void)stop:(CDVInvokedUrlCommand*)command
{
    [self.recorder stop];
    self.recorder.meteringEnabled = NO;
}

-(void)levels:(CDVInvokedUrlCommand*)command
{
    [self.recorder updateMeters];
    NSDictionary *levels =  [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                        [NSNumber numberWithFloat:[self.recorder averagePowerForChannel:0]],
                                        [NSNumber numberWithFloat:[self.recorder peakPowerForChannel:0]],
                                        nil]
                                forKeys:[NSArray arrayWithObjects:
                                         @"averagePower",
                                         @"peakPower",
                                         nil]
     ];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:levels];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

@end
