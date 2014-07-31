//
//  AccessibleLabel.h
//  AccessibleCocos2D
//
//  Created by Peter Easdown on 15/07/2014.
//  Copyright (c) 2014 PKCLsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AccessibleLabel <NSObject>

@property (nonatomic, retain) NSString *languageForText;

@property (nonatomic, retain) NSString *textForSpeaking;

- (BOOL) isStatic;

@end
