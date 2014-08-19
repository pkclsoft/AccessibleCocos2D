//
//  MainMenuLayer.m
//  AccessibleCocos2D
//
//  Created by Peter Easdown on 8/10/13.
//  Copyright 2014 PKCLsoft. All rights reserved.
//

#import "MainMenuLayer.h"
#import "AppDelegate.h"
#import "AccessibleCCLabelTTF.h"

@implementation MainMenuLayer {
    
    float menuY;
    float menuX;
    BOOL fileDownloaded;
}

static MainMenuLayer *sharedInstance_;

+ (MainMenuLayer*) sharedInstance {
    if (sharedInstance_ == nil) {
        sharedInstance_ = [MainMenuLayer node];
    }
    
    return sharedInstance_;
}

typedef enum {
    kTitle,
    kEnglishButton,
    kSpanishButton,
    kMenu,
    kSwitchControlLayer
} MainMenuTag;

typedef enum {
    kZMenu = 50,
    kZTitle = 80,
    kZSwitchControlLayer = 300
    
} MainMenuZOrder;

#define MENU_ITEM_TOP  ([CocosUtil scaledHeight:158.5f])
#define VERTICAL_SPACE ([CocosUtil scaledHeight:10.0f])

#define BUTTON_SCALE (1.0f)
#define MIN_BUTTON_SCALE (0.1f)

#define SHADOW_Y  ([CocosUtil scaledHeight:290.0f])
#define BADGE_Y  ([CocosUtil scaledHeight:300.0f])
#define BADGE_MARGIN ([CocosUtil scaledWidth:10.0f])

#define FONT_SIZE (IS_IPAD ? 45.0 : 22.0)

typedef struct {
    NSString *name;
    NSString *language;
    int tag;
} MenuItemDefinition;

static const MenuItemDefinition MENU_ITEMS[] = {
    {
        @"TEST_EN", @"en-US", kEnglishButton
    },
    {
        @"TEST_ES", @"es-ES", kSpanishButton
    }
};

- (void) handleMenuItemByTag:(int)tag {
    switch (tag) {
        case kEnglishButton:
            break;
            
        case kSpanishButton:
            break;
            
        default:
            break;
    }
}

- (CCMenuItemLabel*) nextMenuItemWithDefinition:(MenuItemDefinition)definition {
    AccessibleCCLabelTTF *buttonLabel = [AccessibleCCLabelTTF labelWithString:NSLocalizedString(definition.name, @"") fontName:@"Helvetica" fontSize:FONT_SIZE];
    
    [buttonLabel setColor:ccWHITE];
    
    CCMenuItemLabel *button = [CCMenuItemLabel itemWithLabel:buttonLabel block:^(id sender) {
        [self handleMenuItemByTag:[(CCNode*)sender tag]];
    }];
    button.scale = BUTTON_SCALE;
    button.tag = definition.tag;
    buttonLabel.languageForText = definition.language;
    
    CGPoint pos = cpv(menuX, menuY);
    button.position = pos;
    
    menuY -= (buttonLabel.contentSize.height/2.0f + VERTICAL_SPACE + buttonLabel.contentSize.height/2.0f) * BUTTON_SCALE;
    menuX += 50.0;

    return button;
}

- (id) init {
    self = [super init];
    
    if (self != nil) {
        CCLabelTTF *title = [CCLabelTTF labelWithString:@"AccessibleCocos2D Demo" fontName:@"Helvetica" fontSize:FONT_SIZE];
        title.position = cpv([CocosUtil screenCentre].x, [CocosUtil scaledHeight:220.0f]);
        [self addChild:title z:kZTitle tag:kTitle];
        
        menuY = MENU_ITEM_TOP;
        menuX = [CocosUtil screenCentre].x;
        
        fileDownloaded = NO;

        NSMutableArray *items = [NSMutableArray arrayWithCapacity:20];
        CCMenuItemLabel *item = nil;
        float maxWidth = 0.0;
        
        for (int itemIndex = 0; itemIndex <= 1; itemIndex++) {
            item = [self nextMenuItemWithDefinition:MENU_ITEMS[itemIndex]];
            
            if (maxWidth < (item.contentSize.width * item.scale)) {
                maxWidth = (item.contentSize.width * item.scale);
            }
            
            [items addObject:item];
        }

        CCMenu *menu = [CCMenu menuWithArray:items];
        [menu setPosition:CGPointZero];
        [self addChild:menu z:kZMenu tag:kMenu];
        
        [[AccessibleGLView accessibilityView] addNodes:[menu.children getNSArray]];
    }
    
    return self;
}

@end
