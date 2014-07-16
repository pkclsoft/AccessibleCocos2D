//
//  MyRootController.m
//  AccessibleCocos2D
//
//  Created by Peter Easdown on 2/09/12.
//  Copyright (c) 2014 PKCLsoft. All rights reserved.
//

#import "MyRootController.h"

@implementation MyRootViewController

-(NSUInteger)supportedInterfaceOrientations{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
    return UIInterfaceOrientationMaskLandscape;
#else
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
#endif
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (BOOL)shouldAutorotate {
    return YES;
}

@end