//
//  CDVMicrophoneLevels.h
//  phonegap-mic-levels
//
//  Created by Theodore Koterwas work on 13/06/2015.
//  Copyright (c) 2015 University of Oxford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cordova/CDVPlugin.h"
#import "NVDSP.h"
#import "NVHighShelvingFilter.h"
#import "NVLowShelvingFilter.h"
#import "Novocaine.h"

@interface CDVMicrophoneLevels : CDVPlugin
{
    bool isInitialised;
}

-(void)setup:(CDVInvokedUrlCommand*)command;
-(void)start:(CDVInvokedUrlCommand*)command;
-(void)stop:(CDVInvokedUrlCommand*)command;
-(void)setLowShelfFilterFrequency:(CDVInvokedUrlCommand*)command;
-(void)setHighShelfFilterFrequency:(CDVInvokedUrlCommand*)command;
-(void)levels:(CDVInvokedUrlCommand*)command;

@end
