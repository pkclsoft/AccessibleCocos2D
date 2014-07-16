//
//  AppDelegate.mm
//  AccessibleCocos2D
//
//  Created by Peter Easdown on 17/6/2012.
//  Copyright PKCLsoft 2012. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "MyRootController.h"
#import "AccessibleGLView.h"

@implementation AppDelegate

@synthesize window=window_, navController=navController_, director=director_;
@synthesize mainMenu;

static AppDelegate *shared_instance_ = nil;

+ (AppDelegate*) sharedInstance {
    return shared_instance_;
}

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    shared_instance_ = self;

	// Create the main window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	CGSize sz = [[UIScreen mainScreen] bounds].size;
    NSLog(@"size = %@", NSStringFromCGSize(sz));
	
	// Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	AccessibleGLView *glView = [AccessibleGLView viewWithFrame:[window_ bounds]
                                                   pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
                                                   depthFormat:0	//GL_DEPTH_COMPONENT24_OES
                                            preserveBackbuffer:NO
                                                    sharegroup:nil
                                                 multiSampling:NO
                                               numberOfSamples:0];
    
	// Enable multitouch
	[glView setMultipleTouchEnabled:YES];
	 
	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];
	
//	director_.wantsFullScreenLayout = YES;
	
#ifdef DEBUG
	// Display FSP and SPF
//	[director_ setDisplayStats:YES];
#else
	[director_ setDisplayStats:NO];
#endif
    
	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];
	
	// attach the openglView to the director
	[director_ setView:glView];
	
	// for rotation and other messages
	[director_ setDelegate:self];
	
	// 2D projection
	//[director_ setProjection:kCCDirectorProjection2D];
    [director_ setProjection:kCCDirectorProjection3D];
    	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	// Create a Navigation Controller with the Director
	//navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	navController_ = [[MyRootViewController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;
	
	// set the Navigation Controller as the root view controller
	//	[window_ setRootViewController:rootViewController_];
    if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
        [window_ addSubview:navController_.view];
    } else {
        [window_ setRootViewController:navController_];
    }

	// make main window visible
	[window_ makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
	
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
	
    [CocosUtil initStaticConstants];
    
    // Prevent the screen from dimming as the kids using this app may be slow to react.
    //
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
	// create scene
	CCScene *scene = [CCScene node];
    self.mainMenu = [MainMenuLayer sharedInstance];
	[scene addChild:self.mainMenu];
    
	// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
	[director_ pushScene: scene]; 
	
	return YES;
}

// Supported orientations: Landscape. Customize it for your own needs
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
    if( [navController_ visibleViewController] == director_ )
		[director_ pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ resume];

}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window_ release];
	[navController_ release];
	
	[super dealloc];
}

#pragma mark UKit stuff

- (void) swapToUIKit:(UIViewController*)newViewController {
    if (newViewController != nil) {
        if ([newViewController parentViewController] == nil) {
            [[CCDirector sharedDirector] pause];
            [[CCDirector sharedDirector] stopAnimation];
            
            [navController_ pushViewController:newViewController animated:YES];
        }
    }
}

// Swaps control to the Cocos2D framework for UI handling, and, if sceneToShow
// is not nil, that scene is pushed into view.
//
- (void) swapToCocos2D:(CCScene*)sceneToShow {
    [navController_ popViewControllerAnimated:(sceneToShow == nil)];
        
    if (sceneToShow != nil) {
        [[CCDirector sharedDirector] pushScene:sceneToShow];
    }
    
    if ([[CCDirector sharedDirector] isPaused] == YES) {
        [[CCDirector sharedDirector] resume];
        [[CCDirector sharedDirector] startAnimation];
    }
}

@end
