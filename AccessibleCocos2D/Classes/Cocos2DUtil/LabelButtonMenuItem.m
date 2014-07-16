//
//  LabelButtonMenuItem.m
//  AccessibleCocos2D
//
//  Created by Peter Easdown on 29/01/13.
//  Copyright (c) 2014 PKCLsoft. All rights reserved.
//

#import "LabelButtonMenuItem.h"

@implementation LabelButtonMenuItem

#define DISABLED_BUTTON_OPACITY 128

+ (CCSprite*) selectedSpriteFor:(NSString*)imageFrameName {
    NSString *defaultName = [NSString stringWithFormat:@"sel_%@", imageFrameName];
    
    if ([[CCSpriteFrameCache sharedSpriteFrameCache] containsFrameByName:defaultName] == NO) {
        // Create a sprite using the supplied name and overlaying it.
        //
        CCSprite *result = [CCSprite spriteWithSpriteFrameName:imageFrameName];
        CCSprite *overlay = [CCSprite spriteWithSpriteFrameName:@"buttonOverlay.png"];
        overlay.position = result.centre;
        
        if (CGSizeEqualToSize(overlay.contentSize, result.contentSize) == NO) {
            overlay.scaleX = result.contentSize.width / overlay.contentSize.width;
            overlay.scaleY = result.contentSize.height / overlay.contentSize.height;
        }
        
        [result addChild:overlay z:1 tag:tLabelButtonMenuItemOverlay];
        
        return result;
    } else {
        return [CCSprite spriteWithSpriteFrameName:defaultName];
    }
}

- (id) initWithImage:(NSString*)imageFrameName withLabel:(NSString*)labelStr atPos:(CGPoint)pos withTag:(int)tag withBlock:(void(^)(id sender))choiceBlock {
    return [self initWithImage:imageFrameName withLabel:labelStr labelShownBelow:NO atPos:pos withTag:tag withBlock:choiceBlock];
}

- (id) initWithImage:(NSString*)imageFrameName withLabel:(NSString*)labelStr labelShownBelow:(BOOL)labelBelow atPos:(CGPoint)pos withTag:(int)tag withBlock:(void(^)(id sender))choiceBlock {
    self = [super initWithNormalSprite:[CCSprite spriteWithSpriteFrameName:imageFrameName] selectedSprite:[LabelButtonMenuItem selectedSpriteFor:imageFrameName] disabledSprite:nil block:choiceBlock];
    
    if (self != nil) {
        [self setPosition:pos];
        
        // default this to NO for all buttons.
        //
        self.labelBelowButton = NO;
        
        if (labelStr != nil) {
            self.labelBelowButton = labelBelow;
            
            CGSize size = self.contentSize;
            
            if (labelBelow == YES) {
                size = CGSizeMake(self.contentSize.width * 1.8f, (([CocosUtil deviceType] == IPAD_DEVICE) ? 60.0f : 30.0f));
            }
            
            self.label = [CCLabelTTF labelWithString:NSLocalizedString(labelStr, @"") fontName:@"Helvetica" fontSize:[self fontSize] dimensions:size hAlignment:kCCTextAlignmentCenter vAlignment:kCCVerticalTextAlignmentCenter lineBreakMode:kCCLineBreakModeWordWrap];
            [self.label setColor:ccBLACK];
            
            CGPoint labelPos = ccp(self.contentSize.width/2.0f, self.contentSize.height/2.0f);
            
            if (labelBelow == YES) {
                // a label "below" the button has to be positioned in the parent using the same coordinate space as the button.
                //
                labelPos = pos;
                labelPos.y -= ((self.contentSize.height / 2.0) * self.scale) + (([CocosUtil deviceType] == IPAD_DEVICE) ? 30.0f : 0.0f);
                [self.label setFontSize:(([CocosUtil deviceType] == IPAD_DEVICE) ? 24.0f : 14.0f)];
            } else {
                [self.label setFontSize:[self fontSize]];
            }
            
            [self.label setPosition:labelPos];
            
            if (labelBelow == NO) {
                [self addChild:self.label z:1 tag:tLabelButtonMenuItemLabel];
            }
        }
        
        [self setTag:tag];
        
        self.dimmedWhenDisabled = YES;
    }
    
    return self;
}

- (void) cleanup {
    self.label = nil;
    
    [super cleanup];
}

- (void) setScale:(float)scale {
    [super setScale:scale];
    
    if (self.labelBelowButton == YES) {
        // a label "below" the button has to be positioned in the parent using the same coordinate space as the button.
        //
        CGPoint labelPos = self.position;
        labelPos.y -= ((self.contentSize.height * self.scale) / 2.0) + ([self.label fontSize] / 2.0f);
        self.label.position = labelPos;
    }
}

- (void) selected {
    [super selected];
}

- (float) fontSize {
    if (self.label != nil) {
        return [self.label fontSize];
    } else {
        return 14.0;
    }
}

- (void) setFontSize:(float)newFontSize {
    
    if (self.label != nil) {
        [self.label setFontSize:newFontSize];
        
        if (self.labelBelowButton == YES) {
            CGPoint labelPos = self.position;
            labelPos.y -= ((self.contentSize.height * self.scale) / 2.0) + ([self.label fontSize] / 2.0f);
//            labelPos.y -= ((self.contentSize.height * self.scale) / 2.0) + ([self.label dimensions].height / 2.0f);
//            labelPos.y -= (self.contentSize.height / 2.0) + newFontSize + 5.0f;

        }
    }
}

+ (LabelButtonMenuItem*) buttonWithImage:(NSString*)imageFrameName withLabel:(NSString*)labelStr atPos:(CGPoint)pos withTag:(int)tag withBlock:(void(^)(id sender))choiceBlock {
    return [[[LabelButtonMenuItem alloc] initWithImage:imageFrameName withLabel:labelStr atPos:pos withTag:tag withBlock:choiceBlock] autorelease];
}

+ (LabelButtonMenuItem*) buttonWithImage:(NSString*)imageFrameName withLabel:(NSString*)labelStr labelShownBelow:(BOOL)labelBelow atPos:(CGPoint)pos withTag:(int)tag withBlock:(void(^)(id sender))choiceBlock {
    return [[[LabelButtonMenuItem alloc] initWithImage:imageFrameName withLabel:labelStr labelShownBelow:labelBelow atPos:pos withTag:tag withBlock:choiceBlock] autorelease];
}

- (void) setLabelText:(NSString*)newLabel {
    if (self.label != nil) {
        [self.label setString:NSLocalizedString(newLabel, @"")];
    }
}

- (void) setColor:(ccColor3B)color {
    [super setColor:color];
    
    if (self.label != nil) {
        [self.label setColor:color];
    }
}

- (void) setOpacity:(GLubyte)opacity {
    if (self.visible == YES) {
        if (self.dimmedWhenDisabled == YES) {
            if ([self isEnabled] == NO) {
                if (opacity > DISABLED_BUTTON_OPACITY) {
                    opacity = DISABLED_BUTTON_OPACITY;
                }
            }
        }
    } else {
        opacity = 0;
    }
    
    for( CCNode *node in [self children] ) {
        if( [node conformsToProtocol:@protocol( CCRGBAProtocol)] ) {
            [(id<CCRGBAProtocol>) node setOpacity:opacity];
        }
    }
    
    if (self.label != nil) {
        [self.label setOpacity:opacity];
    }
    
    [super setOpacity:opacity];
}

- (void) setBadge:(NSString*)badgeName withTag:(int)tag {
    CCSprite *badge = (CCSprite*)[self getChildByTag:tag];
    
    CCSpriteFrame *newFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:badgeName];
    
    if (badge == nil) {
        badge = [CCSprite spriteWithSpriteFrame:newFrame];
        
        if (tag == tLabelButtonMenuItemBadge1) {
            badge.position = cpvmult([self centre], 0.25);
        } else {
            CGPoint pos = [self centre];
            pos.x *= 1.75;
            pos.y *= 0.25;
            badge.position = pos;
        }
        
        badge.scale = 0.0f;
        [self addChild:badge z:10 tag:tag];
        [badge runAction:[CCEaseBounceOut actionWithAction:
                          [CCScaleTo actionWithDuration:0.7 scale:1.0]]];
    } else {
        [badge runAction:[CCSequence actions:
                          [CCEaseBounceInOut actionWithAction:
                           [CCScaleTo actionWithDuration:0.3 scale:0.0]],
                          [CCCallBlock actionWithBlock:
                           ^{
                               [badge setDisplayFrame:newFrame];
                           }],
                          [CCEaseBounceOut actionWithAction:
                           [CCScaleTo actionWithDuration:0.3 scale:1.0]],
                          nil]];
    }
}

- (void) removeBadgeWithTag:(int)tag {
    CCSprite *badge = (CCSprite*)[self getChildByTag:tag];
    
    if (badge != nil) {
        [badge runAction:[CCSequence actions:
                          [CCEaseBounceInOut actionWithAction:
                           [CCScaleTo actionWithDuration:0.3 scale:0.0]],
                          [CCRemoveFromParentAction action],
                          nil]];
    }
}

@end
