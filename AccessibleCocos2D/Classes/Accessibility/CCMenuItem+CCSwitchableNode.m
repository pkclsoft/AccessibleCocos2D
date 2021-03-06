//
//  CCMenuItem+CCSwitchableNode.m
//
//  Created by Peter Easdown on 11/06/2014.
//

#import "CCMenuItem+CCSwitchableNode.h"

@implementation CCMenuItem (CCSwitchableNode)

// Should return YES if the node is currently able to accept taps by the user.
//
- (BOOL) isSwitchSelectable {
    BOOL result = (self.isEnabled == YES) && (self.visible == YES);
    
    return result;
}

// Should cause the node, be it a button of some sort, or something else, to act as if it has been
// tapped.  This will be called when a switch is used to "select" an item on the screen.
//
- (void) switchSelect {
    [self selected];
    [self unselected];
    [self activate];
}

// Should return YES if the node would prefer to highlight itself to the user as selectable.  If this
// happens, the SwitchControlLayer will call the setSwitchHighlighted: as appropriate in
// order to turn on or off the highlight.
//
- (BOOL) hasOwnHighlight {
    return NO;
}

// Should return a NSString containing the text to be spoken when the node is highlighted.  If no text is
// to be spoken, then nil should be returned.
//
- (NSString*) textForSpeaking {
    if ([self respondsToSelector:@selector(label)] == YES) {
        id<CCLabelProtocol> label = (id<CCLabelProtocol>)[(id)self label];
        
        return label.string;
    } else {
        return nil;
    }
}

- (NSString*) languageForText {
    if ([self respondsToSelector:@selector(label)] == YES) {
        id label = (id<CCLabelProtocol>)[(id)self label];

        if (([label conformsToProtocol:@protocol(CCLabelProtocol)] == YES) &&
            ([label conformsToProtocol:@protocol(AccessibleLabel)] == YES)) {
            id<CCLabelProtocol, AccessibleLabel> speechEnabledLabel = (id<CCLabelProtocol, AccessibleLabel>)label;
            
            return [speechEnabledLabel languageForText];
        } else {
            return [[NSLocale preferredLanguages] firstObject];
        }
    } else {
        return [[NSLocale preferredLanguages] firstObject];
    }
}

@end
