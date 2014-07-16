//
//  Price.m
//  iPortaBill
//
//  Created by Peter Easdown on 18/05/10.
//  Copyright 2010 PortaBill. All rights reserved.
//

#import "Price.h"
#import "NSNumberFormatter+Accessor.h"
#import "AppPreferences.h"

@implementation Price

//+ (int) amountFromCurrencyAmount:(double)currencyAmount {
//	if ([[NSLocale currentLocale] currencyRequiresDecimalSeparator]) {
//		return (int)(currencyAmount * 100.0);
//	} else {
//		return (int)currencyAmount;
//	}
//}	

- (id) initWithNewValue:(double) newValue {
	self = [super init];
	mAmount = newValue;
	
	return self;
}

//- (id) initWithAmountForCurrentLocale:(double) newValue {
//	self = [super init];
//	
//	mAmount = [Price amountFromCurrencyAmount:newValue];
//	
//	return self;
//}

- (NSString *) getFormattedAmount:(BOOL)includeAmount 
					   includeTax:(BOOL)includeTax {
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setFormatterBehavior:NSNumberFormatterBehaviorDefault];
	[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[numberFormatter setLocale:[NSLocale currentLocale]];

	NSString *result = nil;
	
	double amountToFormat;
	
	if (includeTax && includeAmount) {
		// We want the tax inclusive amount
		amountToFormat = [Price getTaxInclusiveAmount:mAmount];
	} else if (includeAmount && !includeTax) {
		amountToFormat = mAmount;
	} else if (includeTax && !includeAmount) {
		// We only want the tax amount
		amountToFormat = [Price getTaxAmount:mAmount includingTax:YES];
	} else {
		// We don't want anything?  This is a bug.
		[NSException raise:@"Bug: getFormattedAmount given nothing to do" format:@""];
	}
	
	if ([numberFormatter currencyRequiresDecimalSeparator]) {
		result = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:(int)(amountToFormat) / 100.0]];

	} else {
		result = [numberFormatter stringFromNumber:[NSNumber numberWithInt:(int)amountToFormat]];
	}
	
	return result;
}

- (NSString *) getFormattedAmount {
	return [self getFormattedAmount:YES includeTax:NO];
}
						  
- (NSString *) getFormattedTaxInclusiveAmount {
	return [self getFormattedAmount:YES includeTax:YES];
}

- (NSString *) getFormattedTaxAmount {
	return [self getFormattedAmount:NO includeTax:YES];
}
						  
//- (NSString*) getFormattedTaxInclusiveAmount:(BOOL)includingTax {
//}

- (double) amountForCurrentLocale {
	if ([[NSLocale currentLocale] currencyRequiresDecimalSeparator]) {
		return (double)mAmount / 100.0;
	} else {
		return (double)mAmount;
	}
}

- (void) setAmountForCurrentLocale:(double)newAmount {
	if ([[NSLocale currentLocale] currencyRequiresDecimalSeparator]) {
        mAmount = roundf(newAmount * 100.0f);
	} else {
		mAmount = newAmount;
	}
}

/*
 Returns the string representation of the price as an integer for editing.
 */
- (NSString *) getUnformattedAmountForEditing {
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setFormatterBehavior:NSNumberFormatterBehaviorDefault];
	[numberFormatter setNumberStyle:NSNumberFormatterNoStyle];
	[numberFormatter setLocale:[NSLocale currentLocale]];
	
	NSString *result = [numberFormatter stringFromNumber:[NSNumber numberWithInt:(int)mAmount]];
	
	return result;
}

- (void) setAmountToString:(NSString*) toStringValue {
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setFormatterBehavior:NSNumberFormatterBehaviorDefault];
	[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	NSLocale *locale = [NSLocale currentLocale];
	[numberFormatter setLocale:locale];
	
	if (![toStringValue hasPrefix:[numberFormatter currencySymbol]]) {
		toStringValue = [NSString stringWithFormat:@"%@%@", [numberFormatter currencySymbol], toStringValue]; 
	}
	
	mAmount = (double)[[numberFormatter numberFromString:toStringValue] doubleValue];
}

- (void) setAmount:(double) toNewValue {
	mAmount = toNewValue;
}

- (double) Amount {
	return mAmount;
}

- (NSNumber*) amountNumber {
    return [NSNumber numberWithDouble:[self Amount]];
}

- (void) addAmount:(double)additonalValue {
	mAmount += additonalValue;
}

- (void) subtractAmount:(double)operand {
	mAmount -= operand;
}

- (void) divideBy:(double)divisor {
	mAmount /= divisor;
}

- (void) multiplyBy:(double)multiplier {
	mAmount *= multiplier;
}

- (void) addPrice:(Price*)additionalValue {
    mAmount += [additionalValue Amount];
}

//- (void) addAmountForCurrentLocale:(double)additionalValue {
//	mAmount += [Price amountFromCurrencyAmount:additionalValue];
//}


- (NSString*) description {
	return [[NSString alloc] initWithFormat:@"Price.doubleValue:%.2f, formatted:%@, unformatted:%@", mAmount, [self getFormattedAmount], [self getUnformattedAmountForEditing]];
}

/**
 * Returns the "money" amount of the input parameter, ensuring that it rounded to two decimal places.
 * @param value - double containing amount to be rounded.
 * @return - double containing input value rounded to two decimal places.
 */
//- (int)  roundedAmount:(double)value) {
//    return Math.round(value * 100.0) / 100.0;
//}

#define getTaxRate 0.1f

+ (double)  getTaxInclusiveAmount:(double)forAmount {
    return forAmount * (1.0 + getTaxRate);
}

- (double) getTaxInclusiveAmount {
	return [Price getTaxInclusiveAmount:mAmount];
}

+ (double) getTaxAmount:(double)forAmount includingTax:(BOOL)amountIncludesTax {
    if (!amountIncludesTax) {
		return forAmount * getTaxRate;
    } else {
		return [Price getNONTaxAmount:forAmount] * getTaxRate;
    }
}

- (double) getTaxAmountIncludingTax:(BOOL)amountIncludesTax {
	return [Price getTaxAmount:mAmount includingTax:amountIncludesTax];
}

+ (double) getNONTaxAmount:(double)forAmount {
    return forAmount / (1.0 + getTaxRate);
}

- (double) getNONTaxAmount {
	return [Price getNONTaxAmount:mAmount];
}


@end
