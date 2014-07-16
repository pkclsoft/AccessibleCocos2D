//
//  SwitchableIndexPath.m
//  AccessibleCocos2D
//
//  Created by Peter Easdown on 13/06/2014.
//  Copyright (c) 2014 PKCLsoft. All rights reserved.
//

#import "SwitchableIndexPath.h"
#import "UITableViewCell+CCSwitchableNode.h"
#import  "AppDelegate.h"

@implementation SwitchableIndexPath {
    
    UITableView *parentTableView;
    BOOL highlighted_;
}

- (id) initWithIndexPath:(NSIndexPath*)path forTableView:(UITableView*)tableView {
    self = [super init];
    
    if (self != nil) {
        self.indexPath = path;
        
        NSAssert((tableView != nil), @"Attempt to create SwitchableIndexPath with nil tableView");
        parentTableView = tableView;
        highlighted_ = NO;
    }
    
    return self;
}

+ (SwitchableIndexPath*) switchableIndexPath:(NSIndexPath*)path forTableView:(UITableView*)tableView {
    return [[[SwitchableIndexPath alloc] initWithIndexPath:path forTableView:tableView] autorelease];
}

- (void) dealloc {
    self.indexPath = nil;
    parentTableView = nil;
    
    [super dealloc];
}

// Should return the size of the node on screen.
//
- (CGSize) switchableNodeSize {
    UITableViewCell *cell = [parentTableView cellForRowAtIndexPath:self.indexPath];
    return cell.frame.size;
}

// Should return the position (center) of the node in screen coordinates.
//
- (CGPoint) switchableNodePosition {
    UITableViewCell *cell = [parentTableView cellForRowAtIndexPath:self.indexPath];
    CGRect r = cell.frame;
    NSLog(@"cell frame: %@", NSStringFromCGRect(r));
    
    CGRect result = [parentTableView convertRect:r toView:[[AppDelegate sharedInstance] window]];
    r.origin.x = result.origin.y;
    r.origin.y = [CocosUtil screenHeight] - result.origin.x;
    
    return [CocosUtil centerOfRect:r];
}

// Should return YES if the node is currently able to accept taps by the user.
//
- (BOOL) isSwitchSelectable {
    BOOL result = (parentTableView.isUserInteractionEnabled == YES) && (parentTableView.hidden == NO);
    
    return result;
}

// Should cause the node, be it a button of some sort, or something else, to act as if it has been
// tapped.  This will be called when a switch is used to "select" an item on the screen.
//
- (void) switchSelect {
    if ((parentTableView != nil) && (parentTableView.delegate != nil)) {
        if ([parentTableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)] == YES) {
            [parentTableView.delegate tableView:parentTableView didSelectRowAtIndexPath:self.indexPath];
        } else if ([parentTableView.delegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)] == YES) {
            [parentTableView.delegate tableView:parentTableView accessoryButtonTappedForRowWithIndexPath:self.indexPath];
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
    highlighted_ = highlighted;
    
    UITableViewCell *cell = [parentTableView cellForRowAtIndexPath:self.indexPath];
    
    if (highlighted == YES) {
        if ([cell.contentView viewWithTag:0xa5a5] == nil) {
            [UIView animateWithDuration:0.1 animations:^{
                [parentTableView scrollToRowAtIndexPath:self.indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
            } completion:^(BOOL finished) {
                UITableViewCell *cell = [parentTableView cellForRowAtIndexPath:self.indexPath];
                
                UIView *lineView = [[[UIView alloc] initWithFrame:CGRectMake(2, 2, cell.contentView.bounds.size.width-4, cell.contentView.bounds.size.height-4)] autorelease];
                lineView.backgroundColor = [UIColor clearColor];
                lineView.autoresizingMask = 0x3f;
                lineView.layer.cornerRadius = 15.0;
                lineView.layer.borderColor = [[UIColor redColor] CGColor];
                lineView.layer.borderWidth = 2.5;
                lineView.tag = 0xa5a5;
                
                [UIView animateWithDuration:0.0 animations:^{
                    if (highlighted_ == YES) {
                        [cell.contentView addSubview:lineView];
                    }
                }];
            }];
        }
    } else if ([cell.contentView viewWithTag:0xa5a5] != nil) {
        [UIView animateWithDuration:0.0 animations:^{
            if (highlighted_ == NO) {
                [[cell.contentView viewWithTag:0xa5a5] removeFromSuperview];
            }
        }];
    }
}

// Should return a NSString containing the text to be spoken when the node is highlighted.  If no text is
// to be spoken, then nil should be returned.
//
- (NSString*) textForSpeaking {
    UITableViewCell *cell = [parentTableView cellForRowAtIndexPath:self.indexPath];
    
    if ([cell respondsToSelector:@selector(textForSpeaking)] == YES) {
        return [cell textForSpeaking];
    } else {
        return nil;
    }
}

- (NSString*) languageForText {
    return [[NSLocale preferredLanguages] firstObject];
}

@end
