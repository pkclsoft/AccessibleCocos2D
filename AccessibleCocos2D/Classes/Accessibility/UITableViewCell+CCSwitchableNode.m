//
//  UITableViewCell+CCSwitchableNode.m
//  AccessibleCocos2D
//
//  Created by Peter Easdown on 13/06/2014.
//  Copyright (c) 2014 PKCLsoft. All rights reserved.
//

#import "UITableViewCell+CCSwitchableNode.h"
#import "AppDelegate.h"

@implementation UITableViewCell (CCSwitchableNode)

// Should return the size of the node on screen.
//
- (CGSize) switchableNodeSize {
    return self.frame.size;
}

// Should return the position (center) of the node in screen coordinates.
//
- (CGPoint) switchableNodePosition {
    CGRect r = self.frame;
    
    CGRect result = [self convertRect:r toView:[[AppDelegate sharedInstance] window]];
    
    return [CocosUtil centerOfRect:result];
}

// Should return YES if the node is currently able to accept taps by the user.
//
- (BOOL) isSwitchSelectable {
    BOOL result = (self.isUserInteractionEnabled == YES) && (self.hidden == NO);
    
    return result;
}

// Should cause the node, be it a button of some sort, or something else, to act as if it has been
// tapped.  This will be called when a switch is used to "select" an item on the screen.
//
- (void) switchSelect {
    UITableView *tableView = [self parentTableView];
    
    if ((tableView != nil) && (tableView.delegate != nil)) {
        if ([tableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)] == YES) {
            [tableView.delegate tableView:tableView didSelectRowAtIndexPath:[tableView indexPathForCell:self]];
        } else if ([tableView.delegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)] == YES) {
            [tableView.delegate tableView:tableView accessoryButtonTappedForRowWithIndexPath:[tableView indexPathForCell:self]];
        }
    }
}

// Should return YES if the node would prefer to highlight itself to the user as selectable.  If this
// happens, the SwitchControlLayer will call the setSwitchHighlighted: as appropriate in
// order to turn on or off the highlight.
//
- (BOOL) hasOwnHighlight {
    return YES;
}

- (void) setSwitchHighlighted:(BOOL)highlighted {
    if (highlighted == YES) {
        self.backgroundColor = [UIColor redColor];
        
        UITableView *tableView = [self parentTableView];
        
        if (tableView != nil) {
            [tableView scrollToRowAtIndexPath:[tableView indexPathForCell:self] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
    } else {
        [self setBackgroundColor:[UIColor clearColor]];
    }
}

- (UITableView*) parentTableView {
    id result = [self superview];
    
    while ((result != nil) && ([result isKindOfClass:[UITableView class]] == NO)) {
        if ([result respondsToSelector:@selector(superview)] == YES) {
            result = [result superview];
        } else {
            result = nil;
        }
    }
    
    return result;
}

// Should return a NSString containing the text to be spoken when the node is highlighted.  If no text is
// to be spoken, then nil should be returned.
//
- (NSString*) textForSpeaking {
    return nil;
}

- (NSString*) languageForText {
    return [[NSLocale preferredLanguages] firstObject];
}

@end
