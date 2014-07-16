//
//  StudentSelectionViewController.h
//  Tap Times Tables
//
//  Created by Peter Easdown on 13/01/12.
//  Copyright (c) 2012 PKCLsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransparentUINavigationBar.h"
#import "PromptDelegate.h"

@protocol StudentSelectionDelegate <NSObject>

- (void) studentSelectionDidChange;

@end

@interface StudentSelectionViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    
    id<StudentSelectionDelegate> delegate_;
        
    OperationCompletionHandler alertCompletionHandler;
}

- (id) initWithDelegate:(id<StudentSelectionDelegate>)newDelegate;

@property (retain, nonatomic) UIFont *font;

@property (retain, nonatomic) IBOutlet UIImageView *bgView;
@property (retain, nonatomic) IBOutlet UITableView *dataTableView;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UIButton *removeButton;
@property (retain, nonatomic) IBOutlet UIButton *addButton;
@property (retain, nonatomic) IBOutlet UIButton *optionsButton;
@property (retain, nonatomic) IBOutlet TransparentUINavigationBar *navBar;
@property (retain, nonatomic) IBOutlet UIView *nameEditorView;
@property (retain, nonatomic) IBOutlet UITextField *studentName;
@property (retain, nonatomic) IBOutlet UITapGestureRecognizer *tapRecognizer;

// Action handler for the back button.
//
- (IBAction)backAction:(id)sender;
- (IBAction)removeAction:(id)sender;
- (IBAction)addAction:(id)sender;
- (IBAction)optionsAction:(id)sender;

@end
