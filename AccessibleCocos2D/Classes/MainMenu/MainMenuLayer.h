//
//  MainMenuLayer.h
//
//  Created by Peter Easdown on 8/10/13.
//
//  This is a very simple screen with a label and two text buttons that are accessible.

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface MainMenuLayer : CCLayer <AVSpeechSynthesizerDelegate>

+ (MainMenuLayer*) sharedInstance;

typedef void (^EffectCompletionBlock)(void);

@end
