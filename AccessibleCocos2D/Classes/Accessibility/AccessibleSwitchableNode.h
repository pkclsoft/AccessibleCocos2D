//
//  AccessibleSwitchableNode.h
//  AccessibleCocos2D
//
//  Created by Peter Easdown on 11/07/2014.
//  Copyright (c) 2014 PKCLsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCSwitchableNode.h"
#import <UIKit/UIAccessibility.h>

@interface AccessibleSwitchableNode : UIAccessibilityElement <UIAccessibilityIdentification>

- (id) initWithNode:(CCNode<CCSwitchableNode>*)node inContainer:(id)container;

// Creates a UIAccessibilityElement that wraps a CCNode that implements the CCSwitchableNode protocol.
// This is what iOS will interact with in order to get information about the node.
//
+ (AccessibleSwitchableNode*) accessibleSwitchableWithNode:(CCNode<CCSwitchableNode>*)node inContainer:(id)container;

// The CCNode being wrapped.
//
@property (nonatomic, retain) CCNode<CCSwitchableNode> *node;

@end
