//
//  AccessibleGLView.h
//  AccessibleCocos2D
//
//  Created by Peter Easdown on 11/07/2014.
//  Copyright (c) 2014 PKCLsoft. All rights reserved.
//

#import "CCGLView.h"
#import "CCSwitchableNode.h"

@interface AccessibleGLView : CCGLView

// Adds a single node to the layer for inclusion in the current set of nodes under control.
//
- (void) addNode:(id<CCSwitchableNode>)node;

// Adds the specified array of nodes to the layer for inclusion in the current set of nodes under control.
//
- (void) addNodes:(NSArray*)switchableNodes;

// Removes the specified node from the current set of nodes under control.
//
- (void) removeNode:(id<CCSwitchableNode>)node;

// Removes the specified nodes from the current set of nodes under control.
//
- (void) removeNodes:(NSArray*)switchableNodes;

- (void) addElement:(UIAccessibilityElement*)element;
- (void) addElement:(UIAccessibilityElement*)element partOfBatch:(BOOL)batching;

- (void) removeElement:(UIAccessibilityElement*)element;
- (void) removeElement:(UIAccessibilityElement*)element partOfBatch:(BOOL)batching;

@end
