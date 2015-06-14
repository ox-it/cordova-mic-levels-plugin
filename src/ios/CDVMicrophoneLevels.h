//
//  CDVMicrophoneLevels.h
//  phonegap-mic-levels
//
//  Created by Theodore Koterwas work on 13/06/2015.
//  Copyright (c) 2015 University of Oxford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "Cordova/CDVPlugin.h"

@interface CDVMicrophoneLevels : CDVPlugin
{
    bool isInitialised;
}

-(void)setup:(CDVInvokedUrlCommand*)command;
-(void)start:(CDVInvokedUrlCommand*)command;
-(void)stop:(CDVInvokedUrlCommand*)command;
-(void)levels:(CDVInvokedUrlCommand*)command;

@property(nonatomic) AVAudioRecorder *recorder;

@end
