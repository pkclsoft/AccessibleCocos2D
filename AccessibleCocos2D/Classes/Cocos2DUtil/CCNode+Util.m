//
//  CCNode+Util.m
//  AccessibleCocos2D
//
//  Created by Peter Easdown on 4/11/2013.
//  Copyright (c) 2014 PKCLsoft. All rights reserved.
//

#import "CCNode+Util.h"

@implementation CCNode (Util)

- (CGPoint) centre {
    return CGPointMake(self.contentSize.width/2.0f, self.contentSize.height/2.0f);
}

@end
