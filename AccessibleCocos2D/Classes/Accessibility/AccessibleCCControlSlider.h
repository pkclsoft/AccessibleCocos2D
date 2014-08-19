//
//  CCControlSlider+Accessibility.h
//
//  Created by Peter Easdown on 21/07/2014.
//
// May be used for applications using CCControlSlider (see: http://yannickloriot.com )
//
#import "CCControlSlider.h"

@interface AccessibleCCControlSlider : CCControlSlider <CCSwitchableNode>

@property (nonatomic, retain) NSString* textForSpeaking;

@end
