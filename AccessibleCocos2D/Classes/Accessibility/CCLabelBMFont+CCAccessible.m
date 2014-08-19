//
//  CCLabelBMFont+CCAccessibleNode.m
//
//  Created by Peter Easdown on 23/07/2014.
//

#import "CCLabelBMFont+CCAccessible.h"

@implementation CCLabelBMFont (CCAccessible)

// Should return YES if the node is currently able to accept taps by the user.
//
- (BOOL) isSwitchSelectable {
    return YES;
}

// Should cause the node, be it a button of some sort, or something else, to act as if it has been
// tapped.  This will be called when a switch is used to "select" an item on the screen.
//
- (void) switchSelect {
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
    return self.string;
}

- (NSString*) languageForText {
    return [[NSLocale preferredLanguages] firstObject];
}

- (BOOL) isStatic {
    return YES;
}

@end
