//
//  ScreenshotManager.m
//  Claustrophobic
//
//  Created by Peter Easdown on 7/12/12.
//  Copyright (c) 2012 PKCLsoft. All rights reserved.
//

#import "ScreenshotManager.h"
#import "CCDirector+Util.h"

@implementation ScreenshotManager {
    
}

#define SNAP_PREFIX @"SNAP"

// Returns the path of the folder within the app that contains all lesson documents.
//
+ (NSString *) imagePath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
}

// Returns an array of NSString objects, where each contains the pathname to a single lesson
// document within the folder specified by [self lessonPath].
//
+ (NSArray*) getAllScreenshotPathnames {
	NSError *fError;
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[ScreenshotManager imagePath] error:&fError];
	NSMutableArray *result = [[[NSMutableArray alloc] init] autorelease];
    
	for (NSString *file in files) {
        NSLog(@"file found: %@", file);
		if (([[file pathExtension] isEqualToString:@"jpg"] == YES) && ([file hasPrefix:SNAP_PREFIX])) {
            [result addObject:[[ScreenshotManager imagePath] stringByAppendingPathComponent:file]];
		}
	}
    
	return result;
}

+ (void) snapForReason:(NSString*)reason {
    UIImage *snap = [[CCDirector sharedDirector] screenshotUIImage];
    NSString *pngPath = [[self imagePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.jpg", SNAP_PREFIX, reason]];
  
    //[UIImageJPEGRepresentation(snap, 1.0) writeToFile:pngPath atomically:NO];
    NSLog(@"written file: %@", pngPath);
}

+ (void) removeAll {
    NSArray *files = [self getAllScreenshotPathnames];
    
    if ([files count] > 0) {
        NSError *error;
        
        for (NSString *file in files) {
            NSLog(@"removing file: %@", file);
            [[NSFileManager defaultManager] removeItemAtPath:file error:&error];
        }
    }
}

+ (UIImage*) getSnapForReason:(NSString*)reason {
    NSString *pngPath = [[self imagePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.jpg", SNAP_PREFIX, reason]];
    NSLog(@"loading file: %@", pngPath);
    return [UIImage imageWithContentsOfFile:pngPath];
}

@end
