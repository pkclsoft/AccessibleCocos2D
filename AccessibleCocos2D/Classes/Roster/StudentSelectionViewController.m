//
//  StudentSelectionViewController.h
//  Tap Times Tables
//
//  Created by Peter Easdown on 13/01/12.
//  Copyright (c) 2012 PKCLsoft. All rights reserved.
//

#import "StudentSelectionViewController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "GameSoundManager.h"
#import "CocosUtil.h"
#import "AppPreferences.h"
#import "UIColor+Tools.h"
#import "Roster.h"
#import "StudentOptionsLayer.h"

@implementation StudentSelectionViewController {
    
    NSMutableArray *studentNames;
    
}

#define FONT_SIZE (([CocosUtil deviceType] == IPHONE_DEVICE) ? 14.0 : 32.0)

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andDelegate:(id<StudentSelectionDelegate>)newDelegate {
    self = [super initWithNibName:[CocosUtil xibForDeviceForName:@"StudentSelectionViewController"] bundle:nibBundleOrNil];

    if (self) {
        // Custom initialization
        
        self.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE];
        delegate_ = newDelegate;
        studentNames = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

- (id) initWithDelegate:(id<StudentSelectionDelegate>)newDelegate {
    self = [self initWithNibName:nil bundle:nil andDelegate:newDelegate];
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) addLabelToItem:(UINavigationItem*)item withText:(NSString*)text {
    int height = self.navBar.frame.size.height;
    int width = self.navBar.frame.size.width;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    [label setFont:[[label font] fontWithSize:FONT_SIZE]];
    [label setText:text];
    [item setTitleView:label];
    [label release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataTableView.layer.cornerRadius = 15.0;
    self.dataTableView.dataSource = self;
    self.dataTableView.delegate = self;
    
    [self.studentName setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
    
    [self.addButton setEnabled:NO];
    
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    
    [self.bgView addGestureRecognizer:self.tapRecognizer];
    
    [self.addButton setEnabled:YES];

    // If there's only one it must be the default class...
    //
    [self refreshCurrentClass];
    
    UINavigationItem *classItem = [[[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"ROSTER", @"roster name")] autorelease];
      
    [self addLabelToItem:classItem withText:NSLocalizedString(@"ROSTER", @"the default classname")];
                                              
    [self.navBar setItems:[NSArray arrayWithObject:classItem] animated:YES];
}

- (void)backgroundTapped:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.studentName isEditing] == YES) {
        [self.studentName endEditing:YES];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [self.dataTableView reloadData];
    [self.nameEditorView setHidden:YES];
    
    [self addKeyboardObserver];
    
    [self refreshCurrentClass];

    [super viewWillAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [self setDataTableView:nil];
    [self setBackButton:nil];
    
    [self setRemoveButton:nil];
    [self setNavBar:nil];
    [self setAddButton:nil];
    [self setNameEditorView:nil];
    [self setStudentName:nil];

    [self removeKeyboardObserver];

    [self setBgView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)dealloc {
    [studentNames removeAllObjects];
    [studentNames release];
    [self.dataTableView release];
    [self.backButton release];
    [self.removeButton release];
    [self.navBar release];
    [self.addButton release];
    [self.nameEditorView release];
    [self.studentName release];
    [self.bgView release];
    [_optionsButton release];
    [super dealloc];
}

- (IBAction)backAction:(id)sender {
//    [[GameSoundManager sharedManager] playEffect:@"pop"];
    [((AppDelegate*)[[UIApplication sharedApplication] delegate]) swapToCocos2D:nil];
}

- (IBAction)removeAction:(id)sender {
    [[AppPreferences sharedInstance] setCurrentStudent:nil];
    
    if (delegate_ != nil) {
        [delegate_ studentSelectionDidChange];
    }
    
    [self backAction:nil];
}

- (IBAction)addAction:(id)sender {
    [self.studentName setText:@""];
    [self.studentName setPlaceholder:NSLocalizedString(@"NEWSTUDENTNAMEPROMPT", @"new student name prompt")];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.nameEditorView setHidden:NO];
                         [self.studentName becomeFirstResponder];
                         
                         [self.dataTableView scrollRectToVisible:[[self.dataTableView tableFooterView] frame] animated:YES];
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (IBAction)optionsAction:(id)sender {
}

- (void) refreshCurrentClass {
    [self.addButton setEnabled:YES];
    
    [studentNames removeAllObjects];
    [studentNames addObjectsFromArray:[[Roster sharedRoster] allStudentNames]];
    
    [self.dataTableView reloadData];
}

- (void) selectStudentAt:(NSIndexPath*)indexPath {
    if ([self.nameEditorView isHidden] == YES) {
        [UIView animateWithDuration:0.5
                         animations:^{
                             [self.dataTableView setAlpha:0.0];
                         }
                         completion:^(BOOL finished) {
                             Student *student = [[Roster sharedRoster] studentWithStudentName:[studentNames objectAtIndex:indexPath.row]];
                             
                             [[AppPreferences sharedInstance] setCurrentStudent:student];
                             
                             if (delegate_ != nil) {
                                 [delegate_ studentSelectionDidChange];
                             }
                             
                             [self backAction:nil];
                         }];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertCompletionHandler != nil) {
        NSString *button = [alertView buttonTitleAtIndex:buttonIndex];
        
        if (([button isEqualToString:@"Done"] == YES) ||
            ([button isEqualToString:@"Yes"] == YES)) {
            alertCompletionHandler(YES);
        } else {
            alertCompletionHandler(NO);
        }
    }
}

- (void) removeStudentAt:(NSIndexPath*)indexPath {
    if ([self.nameEditorView isHidden] == YES) {
        
        alertCompletionHandler = [^(BOOL yes) {
            if (yes == YES) {
                [UIView animateWithDuration:0.5
                                 animations:^{
                                     Student *oldCS = [[AppPreferences sharedInstance] currentStudent];

                                     [[Roster sharedRoster] removeStudentByName:[studentNames objectAtIndex:indexPath.row]];

                                     if (oldCS != [[AppPreferences sharedInstance] currentStudent]) {
                                         [delegate_ studentSelectionDidChange];
                                     }
                                 }
                                 completion:^(BOOL finished) {
                                 }];
            }
        } copy];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Remove student data", @"remove student data warning") message:NSLocalizedString(@"Are you sure?", @"Are you sure prompt.") delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alert show];
        
        
        
    }
}

#pragma mark -
#pragma mark Keyboard handling

- (void) addKeyboardObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) removeKeyboardObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
}

- (void)keyboardShown:(NSNotification*)notification {
    NSDictionary* info = [notification userInfo];
    CGRect endFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSNumber *curveNumber = [info objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve curve = (UIViewAnimationCurve)[curveNumber intValue];
    NSNumber *durationNumber = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    double duration = [durationNumber doubleValue];
    
    CGPoint centr = [[self view] center];
    centr.y -= endFrame.size.width;
    CGRect editorFrame = [[self view] convertRect:[self.nameEditorView frame] fromView:self.nameEditorView];
    editorFrame.origin.y = [CocosUtil screenHeight] - editorFrame.origin.y;
    float temp = endFrame.size.width;
    endFrame.size.width = endFrame.size.height;
    endFrame.size.height = temp;
    
    if (CGRectIntersectsRect(editorFrame, endFrame)) {
        [UIView animateWithDuration:duration delay:0.0 options:curve animations:^{
            [[self view] setCenter:centr];
        } completion:nil];
    }
}

- (void)keyboardHidden:(NSNotification*)notification {
    NSDictionary* info = [notification userInfo];
    NSNumber *curveNumber = [info objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve curve = (UIViewAnimationCurve)[curveNumber intValue];
    NSNumber *durationNumber = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    double duration = [durationNumber doubleValue];
    
    [UIView animateWithDuration:duration delay:0.0 options:curve animations:^{
        [[self view] setCenter:[CocosUtil screenCentre]];
        
    } completion:nil];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    /* keyboard is visible, move views */
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    /* resign first responder, hide keyboard, move views */
    [self.studentName resignFirstResponder];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.nameEditorView setHidden:YES];
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL result = YES;
    
    // Before accepting the new students name, make sure it's unique.
    //
    if ([[Roster sharedRoster] rosterHasStudent:[self.studentName text]] == NO) {
        [self.studentName resignFirstResponder];
        NSString *newName = [self.studentName text];
        Student *newStudent = [[[Student alloc] initWithStudentName:newName] autorelease];
        [[Roster sharedRoster] addStudent:newStudent];
        
        [UIView animateWithDuration:0.5
                         animations:^{
                             [self.nameEditorView setHidden:YES];
                         }
                         completion:^(BOOL finished) {
                             [self refreshCurrentClass];
                         }];
    } else {
        result = NO;
    }
    
    return result;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [studentNames count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"StudentSelectCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        [cell.textLabel setFont:self.font];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        
        UIView *myBackView = [[[UIView alloc] initWithFrame:cell.frame] autorelease];
        myBackView.backgroundColor = [UIColor clearColor];
        cell.selectedBackgroundView = myBackView;
    }
    
    cell.textLabel.text = [studentNames objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= 0) {
        if ([[AppPreferences sharedInstance] optionsLocked] == NO) {
            return YES;
        } else {
            return NO;
        }
    }
    
    return NO;
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Need to remove the student that has been swiped by the user.
        //
        [self removeStudentAt:indexPath];
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= 0) {
        [self selectStudentAt:indexPath];
    }
}

@end
