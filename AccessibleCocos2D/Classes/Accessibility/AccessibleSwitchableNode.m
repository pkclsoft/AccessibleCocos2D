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
#import "AppDelegate.h"

@implementation AccessibleSwitchableNode {
    
    BOOL isFocused_Local;
    
}

- (id) initWithNode:(CCNode<CCSwitchableNode>*)node inContainer:(id)container {
    self = [super initWithAccessibilityContainer:container];
    
    if (self != nil) {
        isFocused_Local = NO;
        
        self.node = node;
    }
    
    return self;
}

+ (AccessibleSwitchableNode*) accessibleSwitchableWithNode:(CCNode<CCSwitchableNode>*)node inContainer:(id)container {
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
    if (([self.node respondsToSelector:@selector(isAdjustable)] == YES) && ([self.node isAdjustable] == YES)) {
        return UIAccessibilityTraitAdjustable;
    } else if (([self.node respondsToSelector:@selector(isStatic)] == YES) && ([self.node isStatic] == YES)) {
        return UIAccessibilityTraitStaticText;
    } else {
        return UIAccessibilityTraitButton;
    }
}

- (CGAffineTransform) transformForCurrentOrientation {
    return CGAffineTransformMakeRotation([self currentOrientationAngle]);
}

- (float) currentOrientationAngle {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    switch (orientation) {
            
        case UIInterfaceOrientationLandscapeLeft:
            return CC_DEGREES_TO_RADIANS(90);
            
        case UIInterfaceOrientationLandscapeRight:
            return CC_DEGREES_TO_RADIANS(-90);
            
        case UIInterfaceOrientationPortraitUpsideDown:
            return CC_DEGREES_TO_RADIANS(180);
            
        case UIInterfaceOrientationPortrait:
        default:
            return CC_DEGREES_TO_RADIANS(0);
    }
    
}

- (CGPoint) correctedActivationPoint {
    // This code is a hack to translate the position from Cocos2d to UIKit such that the activation
    // point is at the center of the node in UIKit's view.  I'm sure there's a better way, but
    // all of the transforms I've tried only work with one device orientation or another.  This code
    // appears to work correctly for a landscape app capable of rotating to either landscape
    // orientation.
    //
    CGPoint pos = [self.node switchableNodePosition];
    pos = [self.node.parent convertToWorldSpace:pos];
    
    if ([[UIApplication sharedApplication] statusBarOrientation] != UIDeviceOrientationLandscapeLeft) {
        pos = [[CCDirector sharedDirector] convertToUI:pos];
        pos.x = [CocosUtil screenWidth] - pos.x;
    }
    
    pos = CGPointApplyAffineTransform(pos, [self transformForCurrentOrientation]);
    
    // Now this is really ugly, and shows that I still don't understand something.  The resulting position
    // from the transform gives me the correct coordinate but off the side of the screen in one dimension.
    // These two lines move the coordinate back onto the screen at the correct location.
    //
    pos.x = abs(pos.x);
    pos.y = abs(pos.y);
    
    return pos;
}

- (CGPoint) accessibilityActivationPoint {
    return [self correctedActivationPoint];
}

- (CGRect) accessibilityFrame {
    CGPoint pos = [self correctedActivationPoint];
    
    CGRect rect;
    
    // Now if the device is in landscape orientation, then swap the height and width as appropriate.  I'm sure
    // there's a better way though.
    //
    if (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) == YES) {
        rect = CGRectMake(pos.x-([self.node switchableNodeSize].height/2.0f),
                          pos.y-([self.node switchableNodeSize].width/2.0f),
                          [self.node switchableNodeSize].height,
                          [self.node switchableNodeSize].width);
    } else {
        rect = CGRectMake(pos.x-([self.node switchableNodeSize].width/2.0f),
                             pos.y-([self.node switchableNodeSize].height/2.0f),
                             [self.node switchableNodeSize].width,
                             [self.node switchableNodeSize].height);
    }
    
    return rect;
}

CGPathRef createPathRotatedAroundBoundingBoxCenter(CGPathRef path, CGFloat radians) {
    CGRect bounds = CGPathGetBoundingBox(path); // might want to use CGPathGetPathBoundingBox
    CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, center.x, center.y);
    transform = CGAffineTransformRotate(transform, radians);
    transform = CGAffineTransformTranslate(transform, -center.x, -center.y);
    return CGPathCreateCopyByTransformingPath(path, &transform);
}

#define PATH_ADDITIONAL_SCALE (0.075)
#define PATH_SCALE (1.0 + PATH_ADDITIONAL_SCALE)

- (UIBezierPath*) accessibilityPath {
    if ([self.node isKindOfClass:[CCNode class]]) {
        CCNode *ccNode = (CCNode*)self.node;
        
        if (ccNode.rotation == 0.0f) {
            return nil;
        } else {
            CGRect rect = [self accessibilityFrame];
            rect.size = CGSizeApplyAffineTransform(rect.size, CGAffineTransformMakeScale(PATH_SCALE, PATH_SCALE));
            rect.origin.x = rect.origin.x - (rect.size.width * PATH_ADDITIONAL_SCALE * 0.5);
            rect.origin.y = rect.origin.y - (rect.size.height * PATH_ADDITIONAL_SCALE * 0.5);
            UIBezierPath *result = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(5.0, 5.0)];
            
            CGPathRef path = createPathRotatedAroundBoundingBoxCenter(result.CGPath, CC_DEGREES_TO_RADIANS(ccNode.rotation));
            result = [UIBezierPath bezierPathWithCGPath:path];
            CGPathRelease(path);
            
            return result;
        }
    } else {
        return nil;
    }
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

- (void) accessibilityIncrement {
    if (([self.node respondsToSelector:@selector(isAdjustable)] == YES) && ([self.node isAdjustable] == YES)) {
        [self.node accessibilityIncrement];
    }
}

- (void) accessibilityDecrement {
    if (([self.node respondsToSelector:@selector(isAdjustable)] == YES) && ([self.node isAdjustable] == YES)) {
        [self.node accessibilityDecrement];
    }
}

@end
