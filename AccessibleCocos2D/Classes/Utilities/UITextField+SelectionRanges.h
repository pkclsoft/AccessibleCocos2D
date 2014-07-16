//
//  UITextField+SelectionRanges.h
//  Kitchen Unit Converter
//
//  Created by Anthony Mattox on 1/5/13.
//  Copyright (c) 2013 Friends of The Web. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (SelectionRanges)

- (NSRange) selectionRange;
- (void) selectRange:(NSRange) range;

@end
