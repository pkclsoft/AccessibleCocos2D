//
//  PriceTextField.m
//  iPortaBill
//
//  Created by Peter Easdown on 7/10/10.
//  Copyright 2010 PortaBill. All rights reserved.
//

#import "PriceTextField.h"
#import "UITextField+SelectionRanges.h"
#import "AppDelegate.h"

typedef enum {
    coNone = 0,
    coAdd = 1,
    coSubtract = 2,
    coDivide = 3,
    coMultiply = 4
} CalculatorOperation;

@implementation PriceTextField {
    Price *firstOperand;
    CalculatorOperation lastOperation;
    
    UIBarButtonItem *operatorButton[coMultiply+1];
}

- (void) commonInit {
    priceValue = [[[Price alloc] initWithNewValue:0.0] retain];
    firstOperand = [[[Price alloc] initWithNewValue:0.0] retain];
    lastOperation = coNone;
    operatorButton[coNone] = nil;
    
    self.keyboardType = UIKeyboardTypeNumberPad;
    self.keyboardAppearance = UIKeyboardAppearanceDefault;
    
    [self createAccessoryView];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(gotControl:)
												 name:UITextFieldTextDidBeginEditingNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(lostControl:)
												 name:UITextFieldTextDidEndEditingNotification object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(valueChanged:)
												 name:UITextFieldTextDidChangeNotification object:nil];
    

}

- (id) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self != nil) {
        [self commonInit];
    }
	
	return self;
}

- (id) init {
	self = [super init];
    
	if (self != nil) {
        [self commonInit];
    }
	
	return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
    
	if (self != nil) {
        [self commonInit];
    }
	
	return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidEndEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    
    [super dealloc];
}

- (void)valueChanged:(NSNotification*)notification {
	if ([notification object] == self) {
        if (lastOperation != coNone) {
            [operatorButton[lastOperation] setTintColor:[UIColor brownColor]];
        }
	}
}

- (void)gotControl:(NSNotification*)notification {
	if ([notification object] == self) {
		[self setText:[priceValue getUnformattedAmountForEditing]];
        [self selectRange:NSMakeRange(0, [[self text] length])];
        [self selectAll:self];
        [firstOperand setAmount:0.0];
	}
}

- (void)lostControl:(NSNotification*)notification {
	if ([notification object] == self) {
		//NSLog(@"lostControl(%@)", notification);
		[priceValue setAmountToString:[self text]];
		[self setText:[priceValue getFormattedAmount]];
		
		// Now call the delegate (again) so that it can pick up the actual value.
		//
		[self.delegate textFieldDidEndEditing:self];
	}
}

- (void) setPriceValue:(double) newPrice {
	[priceValue setAmountForCurrentLocale:newPrice];
	
	if ([self isEditing]) {
		[self setText:[priceValue getUnformattedAmountForEditing]];
	} else {
		[self setText:[priceValue getFormattedAmount]];
	}
}

- (double) getPriceValue {
	return [priceValue Amount];
}

- (NSNumber*) getPriceNumber {
    return [NSNumber numberWithDouble:[self getPriceValue]];
}

- (Price*) price {
    return priceValue;
}

#pragma mark - accessory view - calculator!

- (void) doOperation:(CalculatorOperation)operation usingFirstOperand:(Price*)onFirstOperand {
    if (operation == coNone) {
        return;
    }
    
    Price *operand = [[Price alloc] initWithNewValue:0.0];
    [operand setAmountToString:[self text]];
    
    switch (operation) {
        case coNone:
            break;
            
        case coAdd:
            [onFirstOperand addAmount:[operand Amount]];
            break;
            
        case coSubtract:
            [onFirstOperand subtractAmount:[operand Amount]];
            break;
            
        case coDivide:
            [onFirstOperand divideBy:[operand Amount]];
            break;
            
        case coMultiply:
            [onFirstOperand multiplyBy:[operand Amount]];
            break;
    }
    
    [self setText:[onFirstOperand getUnformattedAmountForEditing]];
    [onFirstOperand setAmount:0.0];
    [operatorButton[lastOperation] setTintColor:[UIColor brownColor]];
    lastOperation = coNone;
}

- (void) operationAction:(CalculatorOperation)operation {
    if (lastOperation != operation) {
        [self doOperation:lastOperation usingFirstOperand:firstOperand];
    }
    
    if (lastOperation == coNone) {
        [firstOperand setAmountToString:[self text]];
        [self setText:[firstOperand getUnformattedAmountForEditing]];
        [operatorButton[operation] setTintColor:[UIColor redColor]];
    } else {
        [self doOperation:operation usingFirstOperand:firstOperand];
    }
    
    lastOperation = operation;
    
    [self setSelectedTextRange:[self textRangeFromPosition:self.beginningOfDocument toPosition:self.endOfDocument]];
}

- (IBAction) addAction:(id)sender {
    [self operationAction:coAdd];
}

- (IBAction) subtractAction:(id)sender {
    [self operationAction:coSubtract];
}

- (IBAction) divideAction:(id)sender {
    [self operationAction:coDivide];
}

- (IBAction) multiplyAction:(id)sender {
    if (lastOperation == coNone) {
        [firstOperand setAmount:1.0];
    }

    [self operationAction:coMultiply];
}

- (IBAction) equalsAction:(id)sender {
    [self doOperation:lastOperation usingFirstOperand:firstOperand];
}

- (IBAction) clearAction:(id)sender {
    [firstOperand setAmount:0.0];
    [self setText:[firstOperand getUnformattedAmountForEditing]];
    lastOperation = coNone;
}

const int buttonWidth = 34;

+ (UIColor*) buttonColor {
    return [UIColor colorWithRed:0.647082 green:0.68231 blue:1 alpha:0.48];
}

- (void) createAccessoryView {
    self.accessoryBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [[[AppDelegate sharedInstance] window] frame].size.width, 44)];
    self.accessoryBar.tintColor = [PriceTextField buttonColor];
    
    UIBarButtonItem* addButton = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStyleBordered target:self action:@selector(addAction:)];
    addButton.width = buttonWidth;
    [addButton setTintColor:[UIColor brownColor]];
    operatorButton[coAdd] = addButton;
    
    UIBarButtonItem* subtractButton = [[UIBarButtonItem alloc] initWithTitle:@"−" style:UIBarButtonItemStyleBordered target:self action:@selector(subtractAction:)];
    subtractButton.width = buttonWidth;
    [subtractButton setTintColor:[UIColor brownColor]];
    operatorButton[coSubtract] = subtractButton;

    UIBarButtonItem* divideButton = [[UIBarButtonItem alloc] initWithTitle:@"÷" style:UIBarButtonItemStyleBordered target:self action:@selector(divideAction:)];
    divideButton.width = buttonWidth;
    [divideButton setTintColor:[UIColor brownColor]];
    operatorButton[coDivide] = divideButton;
    
    UIBarButtonItem* multiplyButton = [[UIBarButtonItem alloc] initWithTitle:@"×" style:UIBarButtonItemStyleBordered target:self action:@selector(multiplyAction:)];
    multiplyButton.width = buttonWidth;
    [multiplyButton setTintColor:[UIColor brownColor]];
    operatorButton[coMultiply] = multiplyButton;
    
    UIBarButtonItem* equalsButton = [[UIBarButtonItem alloc] initWithTitle:@"=" style:UIBarButtonItemStyleBordered target:self action:@selector(equalsAction:)];
    equalsButton.width = buttonWidth;
    [equalsButton setTintColor:[UIColor orangeColor]];
    
    UIBarButtonItem * gap = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem* clearButton = [[UIBarButtonItem alloc] initWithTitle:@"C" style:UIBarButtonItemStyleBordered target:self action:@selector(clearAction:)];
    clearButton.width = buttonWidth;
    [clearButton setTintColor:[UIColor brownColor]];
    
    [self.accessoryBar setItems:@[addButton, subtractButton, divideButton, multiplyButton, equalsButton, gap, clearButton]];
    [self setInputAccessoryView:self.accessoryBar];
}

@end
