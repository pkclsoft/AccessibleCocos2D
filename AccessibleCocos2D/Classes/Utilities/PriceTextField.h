//
//  PriceTextField.h
//  iPortaBill
//
//  Created by Peter Easdown on 7/10/10.
//  Copyright 2010 PortaBill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Price.h"

@interface PriceTextField : UITextField <UITextFieldDelegate> {
	
	Price *priceValue;

}

@property (strong, nonatomic) UIToolbar *accessoryBar;

- (void) setPriceValue:(double) newPrice;
- (double) getPriceValue;
- (NSNumber*) getPriceNumber;
- (Price*) price;


@end
