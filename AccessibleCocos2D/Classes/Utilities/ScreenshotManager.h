//
//  ScreenshotManager.h
//  Claustrophobic
//
//  Created by Peter Easdown on 7/12/12.
//  Copyright (c) 2012 PKCLsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScreenshotManager : NSObject

+ (void) snapForReason:(NSString*)reason;

+ (void) removeAll;

+ (UIImage*) getSnapForReason:(NSString*)reason;

@end
