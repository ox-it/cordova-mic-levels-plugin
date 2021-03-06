//
//  CDVMicrophoneLevels.m
//  phonegap-mic-levels
//
//  Created by Theodore Koterwas work on 13/06/2015.
//  Copyright (c) 2015 University of Oxford. All rights reserved.
//

#import "CDVMicrophoneLevels.h"


static const float defaultLowShelfFilterFrequency = 40;
static const float defaultHighShelfFilterFrequency = 3000;


@interface CDVMicrophoneLevels ()
{
    Float32 _averageDB;
    bool _isSetup;
}

@property (nonatomic, strong) Novocaine *audioManager;
@property (nonatomic, strong) NVHighShelvingFilter *hsf;
@property (nonatomic, strong) NVLowShelvingFilter *lsf;


@end

@implementation CDVMicrophoneLevels

-(void)setLowShelfFilterFrequency:(CDVInvokedUrlCommand*)command
{
    float frequency = defaultLowShelfFilterFrequency;
    if (command) {
        frequency = [(NSNumber *)[command.arguments objectAtIndex:0] floatValue];
    }
    if (self.lsf.centerFrequency != frequency) {
        self.lsf.centerFrequency = frequency;
        self.lsf.Q = 0.5f;
        self.lsf.G = -20.0f;
        if (command) [self filters:command];
    }
    
}

-(void)setHighShelfFilterFrequency:(CDVInvokedUrlCommand*)command
{
    float frequency = defaultHighShelfFilterFrequency;
    if (command) {
        frequency = [(NSNumber *)[command.arguments objectAtIndex:0] floatValue];
    }
    if (self.hsf.centerFrequency != frequency) {
        self.hsf.centerFrequency = frequency;
        self.hsf.Q = 0.5f;
        self.hsf.G = -20.0f;
        if (command) [self filters:command];
    }
}
-(void)filters:(CDVInvokedUrlCommand*)command
{
    NSDictionary *filters =  [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                 [NSNumber numberWithFloat:self.lsf.centerFrequency],
                                                                 [NSNumber numberWithFloat:self.hsf.centerFrequency],
                                                                 nil]
                                                        forKeys:[NSArray arrayWithObjects:
                                                                 @"lsfFrequency",
                                                                 @"hsfFrequency",
                                                                 nil]
                             ];
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:filters];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)setup:(CDVInvokedUrlCommand*)command
{
    if (!_isSetup) {
        
        // init Novocaine audioManager
        self.audioManager = [Novocaine audioManager];
        self.audioManager.forceOutputToSpeaker = YES;
        
        // set up filters
        self.lsf = [[NVLowShelvingFilter alloc] initWithSamplingRate:self.audioManager.samplingRate];
        self.hsf = [[NVHighShelvingFilter alloc] initWithSamplingRate:self.audioManager.samplingRate];
        
        [self setLowShelfFilterFrequency:nil];
        [self setHighShelfFilterFrequency:nil];
        
        __weak CDVMicrophoneLevels *weakSelf = self;
        __block float dbVal = 0.0;
        [self.audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels) {
            [weakSelf.hsf filterData:data numFrames:numFrames numChannels:numChannels];
            [weakSelf.lsf filterData:data numFrames:numFrames numChannels:numChannels];
            vDSP_vsq(data, 1, data, 1, numFrames*numChannels);
            float meanVal = 0.0;
            vDSP_meanv(data, 1, &meanVal, numFrames*numChannels);
            float one = 1.0;
            vDSP_vdbcon(&meanVal, 1, &one, &meanVal, 1, 1, 0);
            if (!isnan(meanVal) && !isinf(meanVal)) {
                dbVal = dbVal + 0.2*(meanVal - dbVal);
            }
            _averageDB = dbVal;
        }];
        _isSetup = YES;
    }
}

-(void)start:(CDVInvokedUrlCommand*)command
{
    [self setup:nil];
    if (self.audioManager) {
        [self.audioManager play];
    }
}

-(void)stop:(CDVInvokedUrlCommand*)command
{
    if (self.audioManager) {
        [self.audioManager pause];
    }
}

-(void)levels:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        NSDictionary *levels =  [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                     [NSNumber numberWithFloat:_averageDB],
                                                                     nil]
                                                            forKeys:[NSArray arrayWithObjects:
                                                                     @"averagePower",
                                                                     nil]
                                 ];
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:levels];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    }];
}

@end