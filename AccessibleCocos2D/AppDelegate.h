//
//  AppDelegate.mm
//  AccessibleCocos2D
//
//  Created by Peter Easdown on 17/6/2012.
//  Copyright PKCLsoft 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainMenuLayer.h"

@class MyRootController;

@interface AppDelegate : NSObject <UIApplicationDelegate, CCDirectorDelegate>
{
	UIWindow			*window_;
	MyRootController	*cocosController_;
    UINavigationController *navController_;
	CCDirectorIOS	*director_;							// weak ref
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) UINavigationController *navController;
@property (readonly) CCDirectorIOS *director;
@property (nonatomic, retain) MainMenuLayer *mainMenu;

+ (AppDelegate*) sharedInstance;

- (void) swapToUIKit:(UIViewController*)newViewController;

// Swaps control to the Cocos2D framework for UI handling, and, if sceneToShow
// is not nil, that scene is pushed into view.
//
- (void) swapToCocos2D:(CCScene*)sceneToShow;


@end
