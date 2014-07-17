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

+ (AccessibleSwitchableNode*) accessibleSwitchableWithNode:(CCNode<CCSwitchableNode>*)node inContainer:(id)container;

@property (nonatomic, retain) CCNode<CCSwitchableNode> *node;

@end
