//
//  AccessibleCCLabelTTF.h
//
//  Created by Peter Easdown on 15/07/2014.
//

#import "CCLabelTTF.h"
#import "AccessibleLabel.h"

@interface AccessibleCCLabelTTF : CCLabelTTF <AccessibleLabel>

@property (nonatomic, retain) NSString *languageForText;
@property (nonatomic, retain) NSString *textForSpeaking;

@end
