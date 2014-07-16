//
//  CCLayer+Util.h
//  AccessibleCocos2D
//
//  Created by Peter Easdown on 20/10/13.
//  Copyright (c) 2014 PKCLsoft. All rights reserved.
//

#import "CCLayer.h"
#import "LabelButtonMenuItem.h"

@interface CCLayer (Util)

#define INTER_SCENE_TRANSITION_DURATION 0.25f

#define DISABLED_BUTTON_OPACITY 128

- (CCMenuItem*) itemInMenuWithTag:(int)menuTag forTag:(int)tag;

- (void) enableItem:(CCMenuItemSprite*)item withDuration:(ccTime)duration;
- (void) enableItemInMenuWithTag:(int)menuTag forTag:(int)tag;

- (void) hideItem:(CCMenuItemSprite*)item withDuration:(ccTime)duration;
- (void) hideItemInMenuWithTag:(int)menuTag forTag:(int)tag;

- (void) showItem:(CCMenuItemSprite*)item withDuration:(ccTime)duration;
- (void) showItemInMenuWithTag:(int)menuTag forTag:(int)tag;

- (void) disableItem:(CCMenuItemSprite*)item withDuration:(ccTime)duration;
- (void) disableItemInMenuWithTag:(int)menuTag forTag:(int)tag;

- (void) hideNodeWithTag:(int)tag;
- (void) hideNode:(CCNode*)item withDuration:(ccTime)duration;
- (void) hideNode:(CCNode*)item withDuration:(ccTime)duration remove:(BOOL)removeAlso withCleanup:(BOOL)cleanupAlso;

- (void) showNodeWithTag:(int)tag;
- (void) showNode:(CCNode*)item withDuration:(ccTime)duration;


- (LabelButtonMenuItem*) buttonWithTag:(int)tag atPos:(CGPoint)pos withEnabledState:(BOOL)enabled imageName:(NSString*)imageName label:(NSString*)label andBlock:(void(^)(id sender))andBlock;

- (CCMenuItemToggle*) toggleButtonWithTag:(int)tag atPos:(CGPoint)pos andValue:(BOOL)enabled onImage:(NSString*)onImage offImage:(NSString*)offImage andBlock:(void(^)(id sender))andBlock;

- (CCMenuItemToggle*) toggleButtonWithTag:(int)tag atPos:(CGPoint)pos andValue:(BOOL)enabled onLabel:(NSString*)onLabel offLabel:(NSString*)offLabel andBlock:(void(^)(id sender))andBlock;

- (CCMenuItemToggle*) toggleButtonWithTag:(int)tag atPos:(CGPoint)pos andValue:(BOOL)enabled onLabel:(NSString*)onLabel offLabel:(NSString*)offLabel;

- (CCMenuItemToggle*) toggleButtonWithTag:(int)tag atPos:(CGPoint)pos andValue:(BOOL)enabled andBlock:(void(^)(id sender))andBlock;

- (CCMenuItemToggle*) toggleButtonWithTag:(int)tag atPos:(CGPoint)pos andValue:(BOOL)enabled;

- (CCMenuItemToggle*) masteryLightWithTag:(int)tag atPos:(CGPoint)pos andValue:(BOOL)mastered;


@end
