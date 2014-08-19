//
//  CCNode+CCAccessible.m
//
//  Created by Peter Easdown on 23/07/2014.
//

#import "CCNode+CCAccessible.h"

@implementation CCNode (CCAccessible)

// Should return the size of the node on screen.
//
- (CGSize) switchableNodeSize {
    CGSize result = self.contentSize;
    result.width *= self.scale;
    result.height *= self.scale;
    
    return result;
}

// Should return the position (center) of the node in screen coordinates.
//
- (CGPoint) switchableNodePosition {
    return self.position;
}

@end
