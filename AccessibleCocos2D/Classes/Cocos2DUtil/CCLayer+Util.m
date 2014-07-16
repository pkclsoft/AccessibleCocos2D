//
//  CCLayer+Util.m
//  AccessibleCocos2D
//
//  Created by Peter Easdown on 20/10/13.
//  Copyright (c) 2014 PKCLsoft. All rights reserved.
//

#import "CCLayer+Util.h"
#import "LabelButtonMenuItem.h"

@implementation CCLayer (Util)

- (CCMenuItem*) itemInMenuWithTag:(int)menuTag forTag:(int)tag {
    CCMenu *menu = (CCMenu*)[self getChildByTag:menuTag];
    return (CCMenuItem*)[menu getChildByTag:tag];
}

- (void) enableItem:(CCMenuItemSprite*)item withDuration:(ccTime)duration {
    if ([item isEnabled] == NO) {
        [item setIsEnabled:YES];
        
        if (item.visible == YES) {
            [item runAction:[CCFadeTo actionWithDuration:duration opacity:255]];
        }
    }
}

- (void) enableItemInMenuWithTag:(int)menuTag forTag:(int)tag {
    CCMenuItemSprite *item = (CCMenuItemSprite*)[self itemInMenuWithTag:menuTag forTag:tag];
    [self enableItem:item withDuration:INTER_SCENE_TRANSITION_DURATION];
}

- (void) hideItem:(CCMenuItemSprite*)item withDuration:(ccTime)duration {
    if ([item isEnabled] == YES) {
//        [item setIsEnabled:NO];
        [item stopAllActions];
    }
    
    [item runAction:[CCSequence actions:
                     [CCFadeTo actionWithDuration:duration opacity:0],
                     [CCCallBlock actionWithBlock:
                      ^{
                          item.visible = NO;
                      }]              , nil]];
}

- (void) hideItemInMenuWithTag:(int)menuTag forTag:(int)tag {
    CCMenuItemSprite *item = (CCMenuItemSprite*)[self itemInMenuWithTag:menuTag forTag:tag];
    [self hideItem:item withDuration:INTER_SCENE_TRANSITION_DURATION];
}

- (void) showItem:(CCMenuItemSprite*)item withDuration:(ccTime)duration {
    item.visible = YES;
    item.opacity = 0;
    
    if ([item isEnabled] == YES) {
        [item stopAllActions];
        [item runAction:[CCFadeTo actionWithDuration:duration opacity:255]];
    } else if ([item opacity] == 0) {
        [item runAction:[CCFadeTo actionWithDuration:duration opacity:DISABLED_BUTTON_OPACITY]];
    }
}

- (void) hideNodeWithTag:(int)tag {
    [self hideNode:[self getChildByTag:tag] withDuration:INTER_SCENE_TRANSITION_DURATION];
}

- (void) hideNode:(CCNode*)item withDuration:(ccTime)duration {
    [self hideNode:item withDuration:duration remove:NO withCleanup:NO];
}

- (void) hideNode:(CCNode*)item withDuration:(ccTime)duration remove:(BOOL)removeAlso withCleanup:(BOOL)cleanupAlso {
    [item stopAllActions];
    
    NSMutableArray *actions = [NSMutableArray arrayWithObjects:[CCFadeTo actionWithDuration:duration opacity:0],
                               [CCCallBlock actionWithBlock:
                                ^{
                                    item.visible = NO;
                                }], nil];
    
    if (removeAlso == YES) {
        [actions addObject:[CCCallBlock actionWithBlock:^{
            [item removeFromParentAndCleanup:cleanupAlso];
        }]];
    }
    
    [item runAction:[CCSequence actionWithArray:actions]];
}

- (void) showNodeWithTag:(int)tag {
    [self showNode:[self getChildByTag:tag] withDuration:INTER_SCENE_TRANSITION_DURATION];
}

- (void) showNode:(CCNode<CCRGBAProtocol>*)item withDuration:(ccTime)duration {
    item.visible = YES;
    item.opacity = 0;
    [item stopAllActions];
    [item runAction:[CCFadeTo actionWithDuration:duration opacity:255]];
}

- (void) showItemInMenuWithTag:(int)menuTag forTag:(int)tag {
    CCMenuItemSprite *item = (CCMenuItemSprite*)[self itemInMenuWithTag:menuTag forTag:tag];
    [self showItem:item withDuration:INTER_SCENE_TRANSITION_DURATION];
}

- (void) disableItem:(CCMenuItemSprite*)item withDuration:(ccTime)duration {
    if ([item isEnabled] == YES) {
        [item setIsEnabled:NO];
        if (duration > 0.0) {
            [item runAction:[CCFadeTo actionWithDuration:duration opacity:DISABLED_BUTTON_OPACITY]];
        } else {
            [item setOpacity:DISABLED_BUTTON_OPACITY];
        }
    } else if ([item opacity] == 0) {
        [item runAction:[CCFadeTo actionWithDuration:duration opacity:DISABLED_BUTTON_OPACITY]];
    }
}

- (void) disableItemInMenuWithTag:(int)menuTag forTag:(int)tag {
    CCMenuItemSprite *item = (CCMenuItemSprite*)[self itemInMenuWithTag:menuTag forTag:tag];
    [self disableItem:item withDuration:INTER_SCENE_TRANSITION_DURATION];
}

- (LabelButtonMenuItem*) buttonWithTag:(int)tag atPos:(CGPoint)pos withEnabledState:(BOOL)enabled imageName:(NSString*)imageName label:(NSString*)label andBlock:(void(^)(id sender))andBlock {
    LabelButtonMenuItem *result = [LabelButtonMenuItem buttonWithImage:imageName withLabel:label atPos:pos withTag:tag+1 withBlock:andBlock];
    [result setPosition:pos];
    [result setTag:tag];
    
    if (enabled == NO) {
        [self disableItem:result withDuration:0.0];
    }
    
    return result;
}

- (CCMenuItemToggle*) toggleButtonWithTag:(int)tag atPos:(CGPoint)pos andValue:(BOOL)enabled onImage:(NSString*)onImage offImage:(NSString*)offImage andBlock:(void(^)(id sender))andBlock {
    LabelButtonMenuItem *enabledItem = [LabelButtonMenuItem buttonWithImage:onImage withLabel:nil atPos:pos withTag:tag+1 withBlock:nil];
    LabelButtonMenuItem *disabledItem = [LabelButtonMenuItem buttonWithImage:offImage withLabel:nil atPos:pos withTag:tag+2 withBlock:nil];
    CCMenuItemToggle *result = [CCMenuItemToggle itemWithItems:@[enabledItem, disabledItem] block:andBlock];
    [result setPosition:pos];
    [result setTag:tag];
    
    [result setSelectedIndex:(enabled == YES) ? 0 : 1];
    
    return result;
}

- (CCMenuItemToggle*) toggleButtonWithTag:(int)tag atPos:(CGPoint)pos andValue:(BOOL)enabled onLabel:(NSString*)onLabel offLabel:(NSString*)offLabel andBlock:(void(^)(id sender))andBlock {
    LabelButtonMenuItem *enabledItem = [LabelButtonMenuItem buttonWithImage:@"greenlight.png" withLabel:NSLocalizedString(onLabel, @"on button") atPos:pos withTag:tag+1 withBlock:nil];
    LabelButtonMenuItem *disabledItem = [LabelButtonMenuItem buttonWithImage:@"redlight.png" withLabel:NSLocalizedString(offLabel, @"on button") atPos:pos withTag:tag+2 withBlock:nil];
    CCMenuItemToggle *result = [CCMenuItemToggle itemWithItems:@[enabledItem, disabledItem] block:andBlock];
    [result setPosition:pos];
    [result setTag:tag];
    
    [result setSelectedIndex:(enabled == YES) ? 0 : 1];
    
    return result;
}

- (CCMenuItemToggle*) toggleButtonWithTag:(int)tag atPos:(CGPoint)pos andValue:(BOOL)enabled onLabel:(NSString*)onLabel offLabel:(NSString*)offLabel {
    return [self toggleButtonWithTag:tag atPos:pos andValue:enabled onLabel:onLabel offLabel:offLabel andBlock:nil];
}

- (CCMenuItemToggle*) toggleButtonWithTag:(int)tag atPos:(CGPoint)pos andValue:(BOOL)enabled andBlock:(void(^)(id sender))andBlock {
    return [self toggleButtonWithTag:tag atPos:pos andValue:enabled onLabel:@"ENABLED" offLabel:@"DISABLED" andBlock:andBlock];
}

- (CCMenuItemToggle*) toggleButtonWithTag:(int)tag atPos:(CGPoint)pos andValue:(BOOL)enabled {
    return [self toggleButtonWithTag:tag atPos:pos andValue:enabled onLabel:@"ENABLED" offLabel:@"DISABLED"];
}

- (CCMenuItemToggle*) masteryLightWithTag:(int)tag atPos:(CGPoint)pos andValue:(BOOL)mastered {
    LabelButtonMenuItem *masteredItem = [LabelButtonMenuItem buttonWithImage:@"greenlight.png" withLabel:NSLocalizedString(@"MASTERED", @"mastered light") atPos:pos withTag:tag+1 withBlock:nil];
    [masteredItem setDimmedWhenDisabled:NO];
    [masteredItem setIsEnabled:NO];
    LabelButtonMenuItem *learningItem = [LabelButtonMenuItem buttonWithImage:@"orangelight.png" withLabel:NSLocalizedString(@"LEARNING", @"learning light") atPos:pos withTag:tag+2 withBlock:nil];
    [learningItem setDimmedWhenDisabled:NO];
    [learningItem setIsEnabled:NO];
    
    CCMenuItemToggle *result = [CCMenuItemToggle itemWithItems:@[masteredItem, learningItem]];
    [result setPosition:pos];
    [result setTag:tag];
    [result setIsEnabled:NO];
    
    [result setSelectedIndex:(mastered == YES) ? 0 : 1];
    
    return result;
}

@end
