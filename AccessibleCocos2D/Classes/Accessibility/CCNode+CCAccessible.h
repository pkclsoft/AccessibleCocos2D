//
//  CCNode+CCAccessible.h
//  DollarUp
//
//  Created by Peter Easdown on 23/07/2014.
//  Copyright (c) 2014 PKCLsoft. All rights reserved.
//

#import "CCNode.h"

// This category provides a partial implementation of the CCSwitchableNode protocol.
//
@interface CCNode (CCAccessible)

// Should return the size of the node on screen.
//
- (CGSize) switchableNodeSize;

// Should return the position (center) of the node in screen coordinates.
//
- (CGPoint) switchableNodePosition;

@end
