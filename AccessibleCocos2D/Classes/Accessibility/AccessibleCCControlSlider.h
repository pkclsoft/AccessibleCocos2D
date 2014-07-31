//
//  CCControlSlider+Accessibility.h
//  DollarUp
//
//  Created by Peter Easdown on 21/07/2014.
//  Copyright (c) 2014 PKCLsoft. All rights reserved.
//

#import "CCControlSlider.h"

@interface AccessibleCCControlSlider : CCControlSlider <CCSwitchableNode>

@property (nonatomic, retain) NSString* textForSpeaking;

@end
