//
//  Price.h
//  iPortaBill
//
//  Created by Peter Easdown on 18/05/10.
//  Copyright 2010 pkclSoft. All rights reserved.
//


@interface Price : NSObject {
	
	// Whilst this is a double, the fractional component is only to store the 
	// fractional component of the smallest unit of currency.  e.g. if the currency
	// is dollars and cents, then mAmount will contain the number of cents, with
	// the fractional component being  a fraction of a cent.  For Japanese Yen,
	// the smallest unit is Yen, so the fractional component is a fraction of a Yen
	// which is not normally seen.
	//
	// When the two formatted and unformatted values are generated, they do not
	// show the fractional component.
	//
	double mAmount;
}

- (id) initWithNewValue:(double) newValue;

/*
 Returns the string representation of the price for display purposes.
 */
- (NSString *) getFormattedAmount;
- (NSString *) getFormattedTaxInclusiveAmount;
- (NSString *) getFormattedTaxAmount;

/*
 Returns the string representation of the price as an integer for editing.
 */
- (NSString *) getUnformattedAmountForEditing;
	
- (void) setAmountToString:(NSString*) toStringValue;
- (void) setAmount:(double) toNewValue;
- (double) Amount;
- (NSNumber*) amountNumber;
- (double) amountForCurrentLocale;
- (void) setAmountForCurrentLocale:(double)newAmount;

- (void) addAmount:(double)additonalValue;
- (void) subtractAmount:(double)operand;
- (void) divideBy:(double)divisor;
- (void) multiplyBy:(double)multiplier;

- (void) addPrice:(Price*)additionalValue;

+ (double) getTaxInclusiveAmount:(double)forAmount;
- (double) getTaxInclusiveAmount;
+ (double) getTaxAmount:(double)forAmount includingTax:(BOOL)amountIncludesTax;
- (double) getTaxAmountIncludingTax:(BOOL)amountIncludesTax;
+ (double) getNONTaxAmount:(double)forAmount;
- (double) getNONTaxAmount;
	
@end
