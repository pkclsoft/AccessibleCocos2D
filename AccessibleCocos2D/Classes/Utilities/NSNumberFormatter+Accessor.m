//
//  NSNumberFormatter+Accessor.m
//  iPortaBill
//
//  Created by Peter Easdown on 12/10/10.
//  Copyright 2010 PortaBill. All rights reserved.
//

#import "NSNumberFormatter+Accessor.h"
#import "NSLocale+Accessor.h"


@implementation NSNumberFormatter (Accessor)

// This method returns YES if the locale's currency requires the use
// of a decimal separator.  For example USD will return YES, however
// JPY will return NO.
//
- (BOOL) currencyRequiresDecimalSeparator {
	return [[self locale] currencyRequiresDecimalSeparator];
}

@end
