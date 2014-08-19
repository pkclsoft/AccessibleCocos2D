//
//  AccessibleCCControlSlider.m
//
//  Created by Peter Easdown on 21/07/2014.
//

#import "AccessibleCCControlSlider.h"

@implementation AccessibleCCControlSlider

- (BOOL) isAdjustable {
    return YES;
}

- (NSString*) accessibilityValue {
    return [NSString stringWithFormat:@"%f", self.value];
}

- (void) accessibilityIncrement {
    [self setValue:self.value + 1.0];
}

- (void) accessibilityDecrement {
    [self setValue:self.value - 1.0];
}

#pragma mark - CCSwitchableNode

- (CGSize) switchableNodeSize {
    return self.contentSize;
}

- (CGPoint) switchableNodePosition {
    return self.position;
}

- (BOOL) isSwitchSelectable {
    return (self.enabled == YES) && (self.visible == YES);
}

- (void) switchSelect {
    
}

- (BOOL) hasOwnHighlight {
    return NO;
}

- (NSString*) languageForText {
    return [[NSLocale preferredLanguages] firstObject];
}

@end
