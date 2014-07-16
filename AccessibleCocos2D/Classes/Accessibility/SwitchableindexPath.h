//
//  SwitchableIndexPath.h
//  AccessibleCocos2D
//
//  Created by Peter Easdown on 13/06/2014.
//  Copyright (c) 2014 PKCLsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCSwitchableNode.h"

@interface SwitchableIndexPath : NSObject <CCSwitchableNode>

@property (nonatomic, retain) NSIndexPath *indexPath;

+ (SwitchableIndexPath*) switchableIndexPath:(NSIndexPath*)path forTableView:(UITableView*)tableView;

@end
