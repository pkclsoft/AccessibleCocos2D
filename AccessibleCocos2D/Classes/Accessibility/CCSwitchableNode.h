//
//  CCSwitchableNode.h
//  AccessibleCocos2D
//
//  Created by Peter Easdown on 11/06/2014.
//  Copyright (c) 2014 PKCLsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCSwitchableNode <NSObject>

// Should return the size of the node on screen.
//
- (CGSize) switchableNodeSize;

// Should return the position (center) of the node in screen coordinates.
//
- (CGPoint) switchableNodePosition;

// Should return YES if the node is currently able to accept taps by the user.
//
- (BOOL) isSwitchSelectable;

// Should cause the node, be it a button of some sort, or something else, to act as if it has been
// tapped.  This will be called when a switch is used to "select" an item on the screen.
//
- (void) switchSelect;

// Should return YES if the node would prefer to highlight itself to the user as selectable.  If this
// happens, the SwitchControlLayer will call the setSwitchHighlighted: as appropriate in
// order to turn on or off the highlight.
//
- (BOOL) hasOwnHighlight;

// Should return a NSString containing the text to be spoken when the node is highlighted.  If no text is
// to be spoken, then nil should be returned.
//
- (NSString*) textForSpeaking;

// Should return a NSString containing the language locale to use when speaking the nodes text.
//
- (NSString*) languageForText;

@optional

// This optional method should be implemented in classes that can return YES from the hasOwnHighlight
// method.  The SwitchControlLayer will call this instead of using it's own built-in highlight
// to turn on, or off the highlight.
//
- (void) setSwitchHighlighted:(BOOL)highlighted;

- (BOOL) isAdjustable;

- (BOOL) isStatic;

@end
