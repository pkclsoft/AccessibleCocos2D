//
//  LabelButtonMenuItem.h
//  AccessibleCocos2D
//
//  Created by Peter Easdown on 29/01/13.
//  Copyright (c) 2014 PKCLsoft. All rights reserved.
//
#import "AccessibleLabel.h"

typedef enum {
    tLabelButtonMenuItemBadge1 = 454,
    tLabelButtonMenuItemBadge2 = 455,
    tLabelButtonMenuItemOverlay = 456,
    tLabelButtonMenuItemLabel = 457
} LabelButtonTags;


@interface LabelButtonMenuItem : CCMenuItemSprite <AccessibleLabel>

- (id) initWithImage:(NSString*)imageFrameName withLabel:(NSString*)labelStr atPos:(CGPoint)pos withTag:(int)tag withBlock:(void(^)(id sender))choiceBlock;

- (id) initWithImage:(NSString*)imageFrameName withLabel:(NSString*)labelStr labelShownBelow:(BOOL)labelBelow atPos:(CGPoint)pos withTag:(int)tag withBlock:(void(^)(id sender))choiceBlock;

+ (LabelButtonMenuItem*) buttonWithImage:(NSString*)imageFrameName withLabel:(NSString*)labelStr atPos:(CGPoint)pos withTag:(int)tag withBlock:(void(^)(id sender))choiceBlock;

+ (LabelButtonMenuItem*) buttonWithImage:(NSString*)imageFrameName withLabel:(NSString*)labelStr labelShownBelow:(BOOL)labelBelow atPos:(CGPoint)pos withTag:(int)tag withBlock:(void(^)(id sender))choiceBlock;

- (void) setLabelText:(NSString*)newLabel;

- (void) setBadge:(NSString*)badgeName withTag:(int)tag;
- (void) removeBadgeWithTag:(int)tag;

@property (nonatomic, assign) BOOL dimmedWhenDisabled;
@property (nonatomic, assign) float fontSize;
@property (nonatomic, assign) BOOL labelBelowButton;
@property (nonatomic, retain) CCLabelTTF *label;
@property (nonatomic, retain) NSString *languageForText;

@end
