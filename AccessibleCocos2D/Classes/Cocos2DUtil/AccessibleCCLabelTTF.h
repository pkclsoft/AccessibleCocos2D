//
//  AccessibleCCLabelTTF.h
//  AccessibleCocos2D
//
//  Created by Peter Easdown on 15/07/2014.
//  Copyright (c) 2014 PKCLsoft. All rights reserved.
//

#import "CCLabelTTF.h"
#import "AccessibleLabel.h"

@interface AccessibleCCLabelTTF : CCLabelTTF <AccessibleLabel>

@property (nonatomic, retain) NSString *languageForText;

@end
