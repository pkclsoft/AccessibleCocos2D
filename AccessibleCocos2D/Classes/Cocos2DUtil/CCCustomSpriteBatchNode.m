//
//  CCCustomSpriteBatchNode.m
//  AccessibleCocos2D
//
//  Created by Peter Easdown on 29/03/13.
//  Copyright 2014 PKCLsoft. All rights reserved.
//

#import "CCCustomSpriteBatchNode.h"


@implementation CCCustomSpriteBatchNode

- (void) draw {
	CC_PROFILER_START(@"CCSpriteBatchNode - draw");
    
	// Optimization: Fast Dispatch
	if( textureAtlas_.totalQuads == 0 )
		return;
    
	CC_NODE_DRAW_SETUP();
    
	[children_ makeObjectsPerformSelector:@selector(updateTransform)];
    
	ccGLBlendFunc( blendFunc_.src, blendFunc_.dst );
    
	[textureAtlas_ drawQuads];
    
	[children_ makeObjectsPerformSelector:@selector(drawPrimitives)];
    
	CC_PROFILER_STOP(@"CCSpriteBatchNode - draw");
}

@end
