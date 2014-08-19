//
//  AccessibleGLView.h
//
//  Created by Peter Easdown on 11/07/2014.
//

#import "CCGLView.h"
#import "CCSwitchableNode.h"

@interface AccessibleGLView : CCGLView

// Adds a single node to the layer for inclusion in the current set of nodes under control.
//
- (void) addNode:(id<CCSwitchableNode>)node;
- (void) addNode:(id<CCSwitchableNode>)node partOfBatch:(BOOL)batching;

// Adds the specified array of nodes to the layer for inclusion in the current set of nodes under control.
//
- (void) addNodes:(NSArray*)switchableNodes;

// Removes the specified node from the current set of nodes under control.
//
- (void) removeNode:(id<CCSwitchableNode>)node;
- (void) removeNode:(id<CCSwitchableNode>)node partOfBatch:(BOOL)batching;

// Removes the specified nodes from the current set of nodes under control.
//
- (void) removeNodes:(NSArray*)switchableNodes;

// Requests that accessibility move it's cursor to the selected node.
//
- (void) highlightNode:(id<CCSwitchableNode>)node;

- (void) addElement:(UIAccessibilityElement*)element;
- (void) addElement:(UIAccessibilityElement*)element partOfBatch:(BOOL)batching;

- (void) removeElement:(UIAccessibilityElement*)element;
- (void) removeElement:(UIAccessibilityElement*)element partOfBatch:(BOOL)batching;

// Requests that accessibility move it's cursor to the selected element.
//
- (void) highlightElement:(UIAccessibilityElement*)element;

// Triggers the accessibility API to reload the elements it has been given.
//
- (void) refreshAccessibilityElements;

// Returns the singleton instance of this class created at startup and assigned to the CCDirector.
//
+ (AccessibleGLView*) accessibilityView;

// Returns YES if iOS has at some point prior to this method being called, requested information about
// the accessiblity container this class represents.  This may be used to indicate that accessibility
// is currently active (whether for voiceover or for switch control).
//
+ (BOOL) accessibilityActive;

@end
