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
    AVAudioEngine *_audioEngine;
    AVAudioUnitEQ *_eq;
    __block Float32 _currentAmplitude;
    Float32 _peakDB;
    Float32 _averageDB;
    float _lowShelfFilterFrequency;
    float _highShelfFilterFrequency;
    
}

@property (nonatomic, strong) Novocaine *audioManager;
@property (nonatomic, strong) NVHighShelvingFilter *hsf;
@property (nonatomic, strong) NVLowShelvingFilter *lsf;


@end

@implementation CDVMicrophoneLevels

-(void)setLowShelfFilterFrequency:(CDVInvokedUrlCommand*)command;
{
    float frequency = defaultLowShelfFilterFrequency;
    if (command) {
        frequency = [(NSNumber *)[command.arguments objectAtIndex:0] floatValue];
    }
    if (_lowShelfFilterFrequency != frequency) {
        _lowShelfFilterFrequency = frequency;
        self.lsf.centerFrequency = _lowShelfFilterFrequency;
        self.lsf.Q = 0.5f;
    }
}

-(void)setHighShelfFilterFrequency:(CDVInvokedUrlCommand*)command;
{
    float frequency = defaultHighShelfFilterFrequency;
    if (command) {
        frequency = [(NSNumber *)[command.arguments objectAtIndex:0] floatValue];
    }
    if (_highShelfFilterFrequency != frequency) {
        _highShelfFilterFrequency = frequency;
        self.hsf.centerFrequency = _highShelfFilterFrequency;
        self.hsf.Q = 0.5f;
    }
}

-(void)setup:(CDVInvokedUrlCommand*)command
{
    // init Novocaine audioManager
    self.audioManager = [Novocaine audioManager];
    self.audioManager.forceOutputToSpeaker = YES;
    
    // setup Highpass filter
    self.lsf = [[NVLowShelvingFilter alloc] initWithSamplingRate:self.audioManager.samplingRate];
    self.hsf = [[NVHighShelvingFilter alloc] initWithSamplingRate:self.audioManager.samplingRate];
    if (!_lowShelfFilterFrequency) [self setLowShelfFilterFrequency:nil];
    if (!_highShelfFilterFrequency) [self setHighShelfFilterFrequency:nil];
    
    //__weak CDVMicrophoneLevels *weakSelf = self;
    __block float dbVal = 0.0;
    [self.audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels) {
        //[weakSelf.hsf filterData:data numFrames:numFrames numChannels:numChannels];
        //[weakSelf.lsf filterData:data numFrames:numFrames numChannels:numChannels];
        vDSP_vsq(data, 1, data, 1, numFrames*numChannels);
        float meanVal = 0.0;
        vDSP_meanv(data, 1, &meanVal, numFrames*numChannels);
        float one = 1.0;
        vDSP_vdbcon(&meanVal, 1, &one, &meanVal, 1, 1, 0);
        dbVal = dbVal + 0.2*(meanVal - dbVal);
        
        _peakDB = dbVal;
    }];
    [self.audioManager play];
}

-(void)start:(CDVInvokedUrlCommand*)command
{
    [self setup:nil];
    if (_audioEngine) {
        NSError *error;
        //[_audioEngine startAndReturnError:&error];
        // TODO: handle error
    }
}

-(void)stop:(CDVInvokedUrlCommand*)command
{
    if (_audioEngine) {
        [_audioEngine stop];
    }
}

-(void)levels:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        NSDictionary *levels =  [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                     [NSNumber numberWithFloat:(isnan(_averageDB) || isinf(_averageDB))?-100:_averageDB],
                                                                     [NSNumber numberWithFloat:(isnan(_peakDB) || isinf(_peakDB))?-100:_peakDB],
                                                                     nil]
                                                            forKeys:[NSArray arrayWithObjects:
                                                                     @"averagePower",
                                                                     @"peakPower",
                                                                     nil]
                                 ];
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:levels];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    }];
}

@end