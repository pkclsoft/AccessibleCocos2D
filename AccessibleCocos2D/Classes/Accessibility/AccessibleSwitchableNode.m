//
//  AccessibleSwitchableNode.m
//  AccessibleCocos2D
//
//  Created by Peter Easdown on 11/07/2014.
//  Copyright (c) 2014 PKCLsoft. All rights reserved.
//

#import "AccessibleSwitchableNode.h"
#import <UIKit/UIAccessibility.h>
#import <UIKit/UIAccessibilityElement.h>

@implementation AccessibleSwitchableNode {
    
    BOOL isFocused_Local;
    
}

- (id) initWithNode:(id<CCSwitchableNode>)node inContainer:(id)container {
    self = [super initWithAccessibilityContainer:container];
    
    if (self != nil) {
        isFocused_Local = NO;
        
        self.node = node;
    }
    
    return self;
}

+ (AccessibleSwitchableNode*) accessibleSwitchableWithNode:(id<CCSwitchableNode>)node inContainer:(id)container {
    return [[[AccessibleSwitchableNode alloc] initWithNode:node inContainer:container] autorelease];
}

- (void) dealloc {
    self.node = nil;
    
    [super dealloc];
}

- (NSString*) accessibilityLabel {
    return [self.node textForSpeaking];
}

- (UIAccessibilityTraits) accessibilityTraits {
    return UIAccessibilityTraitButton;
}

- (CGPoint) correctedActivationPoint {
    // This code is a quick hack to translate the position from Cocos2d in one specific orientation
    // to UIKit.  To be finessed.
    //
    CGPoint uiPoint = [[CCDirector sharedDirector] convertToUI:[self.node switchableNodePosition]];
    uiPoint.x = [CocosUtil screenWidth] - uiPoint.x;
    
    return uiPoint;
}

- (CGPoint) accessibilityActivationPoint {
    CGPoint uiPoint = [self correctedActivationPoint];
    
    return CGPointMake(uiPoint.y, uiPoint.x);
}

- (CGRect) accessibilityFrame {
    CGPoint uiPoint = [self correctedActivationPoint];
    
    return CGRectMake(uiPoint.y-([self.node switchableNodeSize].height/2.0f),
               uiPoint.x-([self.node switchableNodeSize].width/2.0f),
               [self.node switchableNodeSize].height,
               [self.node switchableNodeSize].width);

}

// Called when the object is first added, but has no effect on pronunciation.
//
- (NSString*) accessibilityLanguage {
    NSLog(@"accessibilityLanguage: %@", [self.node languageForText]);
    return [self.node languageForText];
}

// Never called unless on the simulator with the inspector active.
//
- (void) accessibilityElementDidBecomeFocused {
    NSLog(@"accessibilityElementDidBecomeFocused: %@", self.accessibilityLabel);
    isFocused_Local = YES;
}

// Never called unless on the simulator with the inspector active.
//
- (void) accessibilityElementDidLoseFocus {
    NSLog(@"accessibilityElementDidLoseFocus: %@", self.accessibilityLabel);
    isFocused_Local = NO;
}

// Never called unless on the simulator with the inspector active.
//
- (BOOL) accessibilityElementIsFocused {
    NSLog(@"accessibilityElementIsFocused: %@", self.accessibilityLabel);
    return isFocused_Local;
}

// Never called unless on the simulator with the inspector active.
//
- (BOOL) accessibilityActivate {
    if ([self.node isSwitchSelectable] == YES) {
        [self.node switchSelect];
    
        return YES;
    } else {
        return NO;
    }
}

- (BOOL) isAccessibilityElement {
    return [self.node isSwitchSelectable];
}

@end
