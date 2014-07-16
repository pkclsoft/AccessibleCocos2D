/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * Portions of this code are based and inspired on:
 *   http://www.71squared.co.uk/2009/04/iphone-game-programming-tutorial-4-bitmap-font-class
 *   by Michael Daley
 *
 *
 * Use any of these editors to generate BMFonts:
 *   http://glyphdesigner.71squared.com/ (Commercial, Mac OS X)
 *   http://www.n4te.com/hiero/hiero.jnlp (Free, Java)
 *   http://slick.cokeandcode.com/demos/hiero.jnlp (Free, Java)
 *   http://www.angelcode.com/products/bmfont/ (Free, Windows only)
 */

#import "ccConfig.h"
#import "ccMacros.h"
#import "CCLabelBMFont.h"
#import "CCSprite.h"
#import "CCDrawingPrimitives.h"
#import "CCConfiguration.h"
#import "CCTextureCache.h"
#import "Support/CCFileUtils.h"
#import "Support/CGPointExtension.h"
#import "Support/uthash.h"

#pragma mark -
#pragma mark FNTConfig Cache - free functions

NSMutableDictionary *configurations = nil;
CCBMFontConfiguration* FNTConfigLoadFile( NSString *fntFile)
{
	CCBMFontConfiguration *ret = nil;
    
	if( configurations == nil )
		configurations = [[NSMutableDictionary dictionaryWithCapacity:3] retain];
    
	ret = [configurations objectForKey:fntFile];
	if( ret == nil ) {
		ret = [CCBMFontConfiguration configurationWithFNTFile:fntFile];
		if( ret )
			[configurations setObject:ret forKey:fntFile];
	}
    
	return ret;
}

void FNTConfigRemoveCache( void )
{
	[configurations removeAllObjects];
}

#pragma mark -
#pragma mark BitmapFontConfiguration

@interface CCBMFontConfiguration ()
-(BOOL) parseConfigFile:(NSString*)controlFile;
-(void) parseCharacterDefinition:(NSString*)line charDef:(ccBMFontDef*)characterDefinition;
-(void) parseInfoArguments:(NSString*)line;
-(void) parseCommonArguments:(NSString*)line;
-(void) parseImageFileName:(NSString*)line fntFile:(NSString*)fntFile;
-(void) parseKerningEntry:(NSString*)line;
-(void) purgeKerningDictionary;
-(void) purgeFontDefDictionary;
@end

#pragma mark -
#pragma mark CCBMFontConfiguration

@implementation CCBMFontConfiguration
@synthesize atlasName=atlasName_;

+(id) configurationWithFNTFile:(NSString*)FNTfile
{
	return [[[self alloc] initWithFNTfile:FNTfile] autorelease];
}

-(id) initWithFNTfile:(NSString*)fntFile
{
	if((self=[super init])) {
        
		kerningDictionary_ = NULL;
		fontDefDictionary_ = NULL;
		xHeight_ = 0;
		base_ = 0;
		capHeight_ = 0;
		ascenderHeight_ = 0;
        
		if( ! [self parseConfigFile:fntFile] ) {
			[self release];
			return nil;
		}
	}
	return self;
}

- (void) dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@", self);
	[self purgeFontDefDictionary];
	[self purgeKerningDictionary];
	[atlasName_ release];
	[super dealloc];
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | Glphys:%d Kernings:%d | Image = %@>", [self class], self,
			HASH_COUNT(fontDefDictionary_),
			HASH_COUNT(kerningDictionary_),
			atlasName_];
}


-(void) purgeFontDefDictionary
{
	tCCFontDefHashElement *current, *tmp;
	
	HASH_ITER(hh, fontDefDictionary_, current, tmp) {
		HASH_DEL(fontDefDictionary_, current);
		free(current);
	}
}

-(void) purgeKerningDictionary
{
	tCCKerningHashElement *current;
    
	while(kerningDictionary_) {
		current = kerningDictionary_;
		HASH_DEL(kerningDictionary_,current);
		free(current);
	}
}

- (BOOL)parseConfigFile:(NSString*)fntFile
{
	NSString *fullpath = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:fntFile];
	NSError *error;
	NSString *contents = [NSString stringWithContentsOfFile:fullpath encoding:NSUTF8StringEncoding error:&error];
    
	if( ! contents ) {
		NSLog(@"cocos2d: Error parsing FNTfile %@: %@", fntFile, error);
		return NO;
	}
    
	// Move all lines in the string, which are denoted by \n, into an array
	NSArray *lines = [[NSArray alloc] initWithArray:[contents componentsSeparatedByString:@"\n"]];
    
	// Create an enumerator which we can use to move through the lines read from the control file
	NSEnumerator *nse = [lines objectEnumerator];
    
	// Create a holder for each line we are going to work with
	NSString *line;
    
	// Loop through all the lines in the lines array processing each one
	while( (line = [nse nextObject]) ) {
		// parse spacing / padding
		if([line hasPrefix:@"info face"]) {
			// XXX: info parsing is incomplete
			// Not needed for the Hiero editors, but needed for the AngelCode editor
            //			[self parseInfoArguments:line];
		}
		// Check to see if the start of the line is something we are interested in
		else if([line hasPrefix:@"common lineHeight"]) {
			[self parseCommonArguments:line];
		}
		else if([line hasPrefix:@"page id"]) {
			[self parseImageFileName:line fntFile:fntFile];
		}
		else if([line hasPrefix:@"chars c"]) {
			// Ignore this line
		}
		else if([line hasPrefix:@"char"]) {
			// Parse the current line and create a new CharDef
			tCCFontDefHashElement *element = malloc( sizeof(*element) );
			
			[self parseCharacterDefinition:line charDef:&element->fontDef];
			
			element->key = element->fontDef.charID;
			HASH_ADD_INT(fontDefDictionary_, key, element);
			float nextAscender =  commonHeight_ - element->fontDef.yOffset;
			if (ascenderHeight_ < nextAscender) {
				ascenderHeight_ = nextAscender;
			}
			
			//  Now we determine the cap height, I chose H,I,T to determine the cap height.
			//	Not sure if there's an easier way but those are Flat on top and capitalized
			if (element->fontDef.charID == 'H' || element->fontDef.charID == 'I' || element->fontDef.charID == 'T') {
				capHeight_ = MAX(capHeight_, commonHeight_ - element->fontDef.yOffset);
			}
		}
        //		else if([line hasPrefix:@"kernings count"]) {
        //			[self parseKerningCapacity:line];
        //		}
		else if([line hasPrefix:@"kerning first"]) {
			[self parseKerningEntry:line];
		}
	}
	// Finished with lines so release it
	[lines release];
	
    //  Now we determine the xHeight which helps us handle different text displays
    //  The default xHeight is the base height in case we don't have an x.
    xHeight_ = base_;
    tCCFontDefHashElement *element;
    unsigned int key = 'x';
    HASH_FIND_INT(fontDefDictionary_ , &key, element);
    if (element) {
        xHeight_ = commonHeight_ - element->fontDef.yOffset;
    }
    
	return  YES;
}

-(void) parseImageFileName:(NSString*)line fntFile:(NSString*)fntFile
{
	NSString *propertyValue = nil;
    
	// Break the values for this line up using =
	NSArray *values = [line componentsSeparatedByString:@"="];
    
	// Get the enumerator for the array of components which has been created
	NSEnumerator *nse = [values objectEnumerator];
    
	// We need to move past the first entry in the array before we start assigning values
	[nse nextObject];
    
	// page ID. Sanity check
	propertyValue = [nse nextObject];
	NSAssert( [propertyValue intValue] == 0, @"XXX: LabelBMFont only supports 1 page");
    
	// file
	propertyValue = [nse nextObject];
	NSArray *array = [propertyValue componentsSeparatedByString:@"\""];
	propertyValue = [array objectAtIndex:1];
	NSAssert(propertyValue,@"LabelBMFont file could not be found");
    
	// Supports subdirectories
	NSString *dir = [fntFile stringByDeletingLastPathComponent];
	atlasName_ = [dir stringByAppendingPathComponent:propertyValue];
    
	[atlasName_ retain];
}

-(void) parseInfoArguments:(NSString*)line
{
	//
	// possible lines to parse:
	// info face="Script" size=32 bold=0 italic=0 charset="" unicode=1 stretchH=100 smooth=1 aa=1 padding=1,4,3,2 spacing=0,0 outline=0
	// info face="Cracked" size=36 bold=0 italic=0 charset="" unicode=0 stretchH=100 smooth=1 aa=1 padding=0,0,0,0 spacing=1,1
	//
	NSArray *values = [line componentsSeparatedByString:@"="];
	NSEnumerator *nse = [values objectEnumerator];
	NSString *propertyValue = nil;
    
	// We need to move past the first entry in the array before we start assigning values
	[nse nextObject];
    
	// face (ignore)
	[nse nextObject];
    
	// size (ignore)
	[nse nextObject];
    
	// bold (ignore)
	[nse nextObject];
    
	// italic (ignore)
	[nse nextObject];
    
	// charset (ignore)
	[nse nextObject];
    
	// unicode (ignore)
	[nse nextObject];
    
	// strechH (ignore)
	[nse nextObject];
    
	// smooth (ignore)
	[nse nextObject];
    
	// aa (ignore)
	[nse nextObject];
    
	// padding (ignore)
	propertyValue = [nse nextObject];
	{
        
		NSArray *paddingValues = [propertyValue componentsSeparatedByString:@","];
		NSEnumerator *paddingEnum = [paddingValues objectEnumerator];
		// padding top
		propertyValue = [paddingEnum nextObject];
		padding_.top = [propertyValue intValue];
        
		// padding right
		propertyValue = [paddingEnum nextObject];
		padding_.right = [propertyValue intValue];
        
		// padding bottom
		propertyValue = [paddingEnum nextObject];
		padding_.bottom = [propertyValue intValue];
        
		// padding left
		propertyValue = [paddingEnum nextObject];
		padding_.left = [propertyValue intValue];
        
		CCLOG(@"cocos2d: padding: %d,%d,%d,%d", padding_.left, padding_.top, padding_.right, padding_.bottom);
	}
    
	// spacing (ignore)
	[nse nextObject];
}

-(void) parseCommonArguments:(NSString*)line
{
	//
	// line to parse:
	// common lineHeight=104 base=26 scaleW=1024 scaleH=512 pages=1 packed=0
	//
	NSArray *values = [line componentsSeparatedByString:@"="];
	NSEnumerator *nse = [values objectEnumerator];
	NSString *propertyValue = nil;
    
	// We need to move past the first entry in the array before we start assigning values
	[nse nextObject];
    
	// Character ID
	propertyValue = [nse nextObject];
	commonHeight_ = [propertyValue intValue];
    
	// base
	propertyValue = [nse nextObject];
	base_ = [propertyValue intValue];
    
	// scaleW. sanity check
	propertyValue = [nse nextObject];
	NSAssert( [propertyValue intValue] <= [[CCConfiguration sharedConfiguration] maxTextureSize], @"CCLabelBMFont: page can't be larger than supported");
    
	// scaleH. sanity check
	propertyValue = [nse nextObject];
	NSAssert( [propertyValue intValue] <= [[CCConfiguration sharedConfiguration] maxTextureSize], @"CCLabelBMFont: page can't be larger than supported");
    
	// pages. sanity check
	propertyValue = [nse nextObject];
	NSAssert( [propertyValue intValue] == 1, @"CCBitfontAtlas: only supports 1 page");
    
	// packed (ignore) What does this mean ??
}
- (void)parseCharacterDefinition:(NSString*)line charDef:(ccBMFontDef*)characterDefinition
{
	// Break the values for this line up using =
	NSArray *values = [line componentsSeparatedByString:@"="];
	NSEnumerator *nse = [values objectEnumerator];
	NSString *propertyValue;
    
	// We need to move past the first entry in the array before we start assigning values
	[nse nextObject];
    
	// Character ID
	propertyValue = [nse nextObject];
	propertyValue = [propertyValue substringToIndex: [propertyValue rangeOfString: @" "].location];
	characterDefinition->charID = [propertyValue intValue];
    
	// Character x
	propertyValue = [nse nextObject];
	characterDefinition->rect.origin.x = [propertyValue intValue];
	// Character y
	propertyValue = [nse nextObject];
	characterDefinition->rect.origin.y = [propertyValue intValue];
	// Character width
	propertyValue = [nse nextObject];
	characterDefinition->rect.size.width = [propertyValue intValue];
	// Character height
	propertyValue = [nse nextObject];
	characterDefinition->rect.size.height = [propertyValue intValue];
	// Character xoffset
	propertyValue = [nse nextObject];
	characterDefinition->xOffset = [propertyValue intValue];
	// Character yoffset
	propertyValue = [nse nextObject];
	characterDefinition->yOffset = [propertyValue intValue];
	// Character xadvance
	propertyValue = [nse nextObject];
	characterDefinition->xAdvance = [propertyValue intValue];
}

-(void) parseKerningEntry:(NSString*) line
{
	NSArray *values = [line componentsSeparatedByString:@"="];
	NSEnumerator *nse = [values objectEnumerator];
	NSString *propertyValue;
    
	// We need to move past the first entry in the array before we start assigning values
	[nse nextObject];
    
	// first
	propertyValue = [nse nextObject];
	int first = [propertyValue intValue];
    
	// second
	propertyValue = [nse nextObject];
	int second = [propertyValue intValue];
    
	// second
	propertyValue = [nse nextObject];
	int amount = [propertyValue intValue];
    
	tCCKerningHashElement *element = calloc( sizeof( *element ), 1 );
	element->amount = amount;
	element->key = (first<<16) | (second&0xffff);
	HASH_ADD_INT(kerningDictionary_,key, element);
}

@end

#pragma mark -
#pragma mark CCLabelBMFont

@interface CCLabelBMFont ()

-(int) kerningAmountForFirst:(unichar)first second:(unichar)second;
-(void) updateLabel;
-(void) setString:(NSString*) newString updateLabel:(BOOL)update;

@end

#pragma mark -
#pragma mark CCLabelBMFont

@implementation CCLabelBMFont

@synthesize alignment = alignment_;
@synthesize verticalAlignment = vAlignment_;
@synthesize opacity = opacity_, color = color_;
@synthesize lineHeight = lineHeight_;
@synthesize bottomDisplay = bottomDisplay_;
@synthesize topDisplay = topDisplay_;

#pragma mark LabelBMFont - Purge Cache
+(void) purgeCachedData
{
	FNTConfigRemoveCache();
}

#pragma mark LabelBMFont - Creation & Init

+(id) labelWithString:(NSString *)string fntFile:(NSString *)fntFile
{
	return [[[self alloc] initWithString:string fntFile:fntFile width:kCCLabelAutomaticWidth alignment:kCCTextAlignmentLeft imageOffset:CGPointZero] autorelease];
}

+(id) labelWithString:(NSString*)string fntFile:(NSString*)fntFile width:(float)width alignment:(CCTextAlignment)alignment
{
    return [[[self alloc] initWithString:string fntFile:fntFile width:width alignment:alignment imageOffset:CGPointZero] autorelease];
}

+(id) labelWithString:(NSString*)string fntFile:(NSString*)fntFile width:(float)width alignment:(CCTextAlignment)alignment imageOffset:(CGPoint)offset
{
    return [[[self alloc] initWithString:string fntFile:fntFile width:width alignment:alignment imageOffset:offset] autorelease];
}

-(id) init
{
	return [self initWithString:nil fntFile:nil width:kCCLabelAutomaticWidth alignment:kCCTextAlignmentLeft imageOffset:CGPointZero];
}

-(id) initWithString:(NSString*)theString fntFile:(NSString*)fntFile
{
    return [self initWithString:theString fntFile:fntFile width:kCCLabelAutomaticWidth alignment:kCCTextAlignmentLeft];
}

-(id) initWithString:(NSString*)theString fntFile:(NSString*)fntFile width:(float)width alignment:(CCTextAlignment)alignment
{
	return [self initWithString:theString fntFile:fntFile width:width alignment:alignment imageOffset:CGPointZero];
}

// designated initializer
-(id) initWithString:(NSString*)theString fntFile:(NSString*)fntFile width:(float)width alignment:(CCTextAlignment)alignment imageOffset:(CGPoint)offset
{
	NSAssert(!configuration_, @"re-init is no longer supported");
	
	// if theString && fntfile are both nil, then it is OK
	NSAssert( (theString && fntFile) || (theString==nil && fntFile==nil), @"Invalid params for CCLabelBMFont");
	
	CCTexture2D *texture = nil;
    
	if( fntFile ) {
		CCBMFontConfiguration *newConf = FNTConfigLoadFile(fntFile);
		NSAssert( newConf, @"CCLabelBMFont: Impossible to create font. Please check file: '%@'", fntFile );
        
		configuration_ = [newConf retain];
        
		fntFile_ = [fntFile retain];
        
		texture = [[CCTextureCache sharedTextureCache] addImage:configuration_.atlasName];
        
	} else
		texture = [[[CCTexture2D alloc] init] autorelease];
    
    
	if( (self=[super initWithTexture:texture capacity:[theString length]]) ) {
        width_ = width;
        alignment_ = alignment;
        
		opacity_ = 255;
		color_ = ccWHITE;
		
		contentSize_ = CGSizeZero;
		
		opacityModifyRGB_ = [[textureAtlas_ texture] hasPremultipliedAlpha];
		
		anchorPoint_ = ccp(0.5f, 0.5f);
        
        lineHeight_ = 1;
		imageOffset_ = offset;
        topDisplay_ = kCCLabelTopDisplayAscender;
        bottomDisplay_ = kCCLabelBottomDisplayLineHeight;
        
		[self setString:theString updateLabel:YES];
	}
    
	return self;
}

-(void) dealloc
{
	[string_ release];
    [initialString_ release];
	[configuration_ release];
    [fntFile_ release];
    
	[super dealloc];
}

#pragma mark LabelBMFont - Alignment

- (void)updateLabel
{
    [self setString:initialString_ updateLabel:NO];
	
    if (width_ > 0){
        //Step 1: Make multiline
		
        NSString *multilineString = @"", *lastWord = @"";
        int line = 1, i = 0;
        NSUInteger stringLength = [self.string length];
        float startOfLine = -1, startOfWord = -1;
        int skip = 0;
        //Go through each character and insert line breaks as necessary
        for (int j = 0; j < [children_ count]; j++) {
            CCSprite *characterSprite;
			
            while(!(characterSprite = (CCSprite *)[self getChildByTag:j+skip]))
                skip++;
			
            if (!characterSprite.visible) continue;
			
            if (i >= stringLength || i < 0)
                break;
			
            unichar character = [self.string characterAtIndex:i];
			
            if (startOfWord == -1)
                startOfWord = characterSprite.position.x - characterSprite.contentSize.width/2;
            if (startOfLine == -1)
                startOfLine = startOfWord;
			
            //Character is a line break
            //Put lastWord on the current line and start a new line
            //Reset lastWord
            if ([[NSCharacterSet newlineCharacterSet] characterIsMember:character]) {
                lastWord = [[lastWord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] stringByAppendingFormat:@"%C", character];
                multilineString = [multilineString stringByAppendingString:lastWord];
                lastWord = @"";
                startOfWord = -1;
                line++;
                startOfLine = -1;
                i++;
				
                //CCLabelBMFont do not have a character for new lines, so do NOT "continue;" in the for loop. Process the next character
                if (i >= stringLength || i < 0)
                    break;
                character = [self.string characterAtIndex:i];
				
                if (startOfWord == -1)
                    startOfWord = characterSprite.position.x - characterSprite.contentSize.width/2;
                if (startOfLine == -1)
                    startOfLine = startOfWord;
            }
			
            //Character is a whitespace
            //Put lastWord on current line and continue on current line
            //Reset lastWord
            if ([[NSCharacterSet whitespaceCharacterSet] characterIsMember:character]) {
                lastWord = [lastWord stringByAppendingFormat:@"%C", character];
                multilineString = [multilineString stringByAppendingString:lastWord];
                lastWord = @"";
                startOfWord = -1;
                i++;
                continue;
            }
			
            //Character is out of bounds
            //Do not put lastWord on current line. Add "\n" to current line to start a new line
            //Append to lastWord
            if (characterSprite.position.x + characterSprite.contentSize.width/2 - startOfLine >  width_) {
                lastWord = [lastWord stringByAppendingFormat:@"%C", character];
                NSString *trimmedString = [multilineString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                multilineString = [trimmedString stringByAppendingString:@"\n"];
                line++;
                startOfLine = -1;
                i++;
                continue;
            } else {
                //Character is normal
                //Append to lastWord
                lastWord = [lastWord stringByAppendingFormat:@"%C", character];
                i++;
                continue;
            }
        }
		
        multilineString = [multilineString stringByAppendingFormat:@"%@", lastWord];
		
        [self setString:multilineString updateLabel:NO];
    }
	
    //Step 2: Make alignment
	
    if (self.alignment != kCCTextAlignmentLeft) {
		
        int i = 0;
        //Number of spaces skipped
        int lineNumber = 0;
        //Go through line by line
        for (NSString *lineString in [string_ componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]) {
            int lineWidth = 0;
			
            //Find index of last character in this line
            NSInteger index = i + [lineString length] - 1 + lineNumber;
            if (index < 0)
                continue;
			
            //Find position of last character on the line
            CCSprite *lastChar = (CCSprite *)[self getChildByTag:index];
			
            lineWidth = lastChar.position.x + lastChar.contentSize.width/2;
			
            //Figure out how much to shift each character in this line horizontally
            float shift = 0;
            switch (self.alignment) {
                case kCCTextAlignmentCenter:
                    shift = self.contentSize.width/2 - lineWidth/2;
                    break;
                case kCCTextAlignmentRight:
                    shift = self.contentSize.width - lineWidth;
                default:
                    break;
            }
			
            if (shift != 0) {
                int j = 0;
                //For each character, shift it so that the line is center aligned
                for (j = 0; j < [lineString length]; j++) {
                    index = i + j + lineNumber;
                    if (index < 0)
                        continue;
                    CCSprite *characterSprite = (CCSprite *)[self getChildByTag:index];
                    characterSprite.position = ccpAdd(characterSprite.position, ccp(shift, 0));
                }
            }
            i += [lineString length];
            lineNumber++;
        }
    }
}

#pragma mark LabelBMFont - Atlas generation

-(int) kerningAmountForFirst:(unichar)first second:(unichar)second
{
	int ret = 0;
	unsigned int key = (first<<16) | (second & 0xffff);
    
	if( configuration_->kerningDictionary_ ) {
		tCCKerningHashElement *element = NULL;
		HASH_FIND_INT(configuration_->kerningDictionary_, &key, element);
		if(element)
			ret = element->amount;
	}
    
	return ret;
}

/**
 *	@return the top display height based on the topDisplay property
 */
-(float)topDisplayHeight
{
	float value = 0;
	switch (topDisplay_) {
		case kCCLabelTopDisplayAscender:
			value = configuration_->commonHeight_ - configuration_->ascenderHeight_;
			break;
		case kCCLabelTopDisplayCapHeight:
			value = configuration_->commonHeight_ - configuration_->capHeight_;
			break;
		case kCCLabelTopDisplayXHeight:
			value = configuration_->commonHeight_ - configuration_->xHeight_;
			break;
	}
	return value;
}

/**
 *	@params	adjustedByLineHeight	the text at the bottom can be affected by lineHeight
 *	@return the bottom display height based on the bottomDisplay property.
 */
-(float)bottomDisplayHeight:(BOOL)adjustedByLineHeight
{
	float value = 0;
	switch (bottomDisplay_) {
		case kCCLabelBottomDisplayLineHeight:
			//	The default height of the text is the common line height including any
			//	extra height due to the line height scalar
			value = configuration_->commonHeight_;
			if (adjustedByLineHeight) value *= lineHeight_;
			break;
		case kCCLabelBottomDisplayDescender:
			//	We use the common line height including but we won't allow the extra
			//	space at the end so we clamp up to the descender
			value = configuration_->commonHeight_;
			if (adjustedByLineHeight) {
                value += (configuration_->base_ * 0.5f);
                value *= MIN(lineHeight_, 1);
            }
			break;
		case kCCLabelBottomDisplayBaseline:
			//	We find the adjusted line height but we clip the height to the baseline.
			value = configuration_->commonHeight_;
			if (adjustedByLineHeight) value *= lineHeight_;
			value = MIN(value, configuration_->base_);
			break;
			
		default:
			break;
	}
	return value;
}

-(void) createFontChars
{
	NSInteger nextFontPositionX = 0;
	float nextFontPositionY = 0;
	unichar prev = -1;
	NSInteger kerningAmount = 0;
    
	CGSize tmpSize = CGSizeZero;
    
	NSInteger longestLine = 0;
	float totalHeight = 0;
    
	NSUInteger quantityOfLines = 1;
    
	NSUInteger stringLen = [string_ length];
	if( ! stringLen )
		return;
    
	// quantity of lines NEEDS to be calculated before parsing the lines,
	// since the Y position needs to be calcualted before hand
	for(NSUInteger i=0; i < stringLen-1;i++) {
		unichar c = [string_ characterAtIndex:i];
		if( c=='\n')
			quantityOfLines++;
	}
	
	// We substitute the regular common line height with an adjustable line height
	float adjustedLineHeight = configuration_->commonHeight_ * lineHeight_;
	
	// Get the top half height of a character and align it to the top
	float topHeight = [self topDisplayHeight];
	nextFontPositionY += topHeight;
	
	if (quantityOfLines == 1) {
		// When we have only 1 line of text we deal with the bottom and top display height at once
		totalHeight += MAX([self bottomDisplayHeight:YES] - topHeight, [self bottomDisplayHeight:NO] - topHeight);
	} else {
		// Handle the first line height
		totalHeight += MAX(configuration_->commonHeight_ * lineHeight_ - topHeight, [self bottomDisplayHeight:NO] - topHeight);
		// Handle the last line height
		totalHeight += [self bottomDisplayHeight:YES];
		if (quantityOfLines > 2) {
			// We have 3 or more lines which means we need to compute the middle lines
			totalHeight += adjustedLineHeight * (quantityOfLines - 2);
		}
	}
	
	nextFontPositionY += totalHeight - adjustedLineHeight;
    
    CGRect rect;
    ccBMFontDef fontDef;
	
	short lineOffset = 0;
    float topY = 0.0;
    float bottomY = 0.0;
    
	for(NSUInteger i = 0; i<stringLen; i++) {
		unichar c = [string_ characterAtIndex:i];
        
		if (c == '\n') {
			nextFontPositionX = 0;
			nextFontPositionY -= adjustedLineHeight;
			prev = -1;
			continue;
		}
        
		kerningAmount = [self kerningAmountForFirst:prev second:c];
        
		
		tCCFontDefHashElement *element = NULL;
		
		// unichar is a short, and an int is needed on HASH_FIND_INT
		NSUInteger key = (NSUInteger)c;
		HASH_FIND_INT(configuration_->fontDefDictionary_ , &key, element);
		if( ! element ) {
			CCLOGWARN(@"cocos2d: LabelBMFont: characer not found %c", c);
			continue;
		}
        
		fontDef = element->fontDef;
		
		if (nextFontPositionX == 0) {
			// Testing if removing the xOffset of the first character helps with horizontal alignment
			//lineOffset = -(fontDef.xOffset);
		}
        
        rect = fontDef.rect;
		rect = CC_RECT_PIXELS_TO_POINTS(rect);
		
		rect.origin.x += imageOffset_.x;
		rect.origin.y += imageOffset_.y;
        
		CCSprite *fontChar;
        
		fontChar = (CCSprite*) [self getChildByTag:i];
		if( ! fontChar ) {
			fontChar = [[CCSprite alloc] initWithTexture:textureAtlas_.texture rect:rect];
			[self addChild:fontChar z:0 tag:i];
			[fontChar release];
		}
		else {
			// reusing fonts
			[fontChar setTextureRect:rect rotated:NO untrimmedSize:rect.size];
            
			// restore to default in case they were modified
			fontChar.visible = YES;
			fontChar.opacity = 255;
		}
        
		// See issue 1343. cast( signed short + unsigned integer ) == unsigned integer (sign is lost!)
		float yOffset = adjustedLineHeight - fontDef.yOffset;
		CGPoint fontPos = ccp( (CGFloat)nextFontPositionX + fontDef.xOffset + lineOffset + fontDef.rect.size.width*0.5f + kerningAmount,
							  (CGFloat)nextFontPositionY + yOffset - rect.size.height*0.5f * CC_CONTENT_SCALE_FACTOR() );
		fontChar.position = CC_POINT_PIXELS_TO_POINTS(fontPos);
//        if (fontPos.y + (rect.size.height*0.5f * CC_CONTENT_SCALE_FACTOR()) > topY) {
//            topY = fontPos.y + (rect.size.height*0.5f * CC_CONTENT_SCALE_FACTOR());
//        }
//        
//        if (fontPos.y - (rect.size.height*0.5f * CC_CONTENT_SCALE_FACTOR()) < bottomY) {
//            bottomY = (fontPos.y - (rect.size.height*0.5f * CC_CONTENT_SCALE_FACTOR()));
//        }
		
		// update kerning
		nextFontPositionX += fontDef.xAdvance + kerningAmount;
		prev = c;
        
		// Apply label properties
		[fontChar setOpacityModifyRGB:opacityModifyRGB_];
		// Color MUST be set before opacity, since opacity might change color if OpacityModifyRGB is on
		[fontChar setColor:color_];
        
		// only apply opacity if it is different than 255 )
		// to prevent modifying the color too (issue #610)
		if( opacity_ != 255 )
			[fontChar setOpacity: opacity_];
        
		if (longestLine < nextFontPositionX)
			longestLine = nextFontPositionX;
	}
    
    totalHeight = max(totalHeight, (topY - bottomY));
    
    // If the last character processed has an xAdvance which is less that the width of the characters image, then we need
    // to adjust the width of the string to take this into account, or the character will overlap the end of the bounding
    // box
    if (fontDef.xAdvance < fontDef.rect.size.width) {
        tmpSize.width = longestLine + fontDef.rect.size.width - fontDef.xAdvance;
    } else {
        tmpSize.width = longestLine;
    }
    tmpSize.height = totalHeight;
    
	[self setContentSize:CC_SIZE_PIXELS_TO_POINTS(tmpSize)];
}

#pragma mark LabelBMFont - CCLabelProtocol protocol
-(NSString*) string
{
	return string_;
}

-(void) setCString:(char*)label
{
	[self setString:[NSString stringWithUTF8String:label] ];
}

- (void) setString:(NSString*)newString
{
	[self setString:newString updateLabel:YES];
}

- (void) setString:(NSString*) newString updateLabel:(BOOL)update
{
    if( !update ) {
        [string_ release];
        string_ = [newString copy];
    } else {
        [initialString_ release];
        initialString_ = [newString copy];
    }
	
    CCSprite *child;
    CCARRAY_FOREACH(children_, child)
	child.visible = NO;
	
	[self createFontChars];
	
    if (update)
        [self updateLabel];
}

#pragma mark LabelBMFont - CCRGBAProtocol protocol

-(void) setColor:(ccColor3B)color
{
	color_ = color;
    
	CCSprite *child;
	CCARRAY_FOREACH(children_, child)
    [child setColor:color_];
}

-(void) setOpacity:(GLubyte)opacity
{
	opacity_ = opacity;
    
	id<CCRGBAProtocol> child;
	CCARRAY_FOREACH(children_, child)
    [child setOpacity:opacity_];
}
-(void) setOpacityModifyRGB:(BOOL)modify
{
	opacityModifyRGB_ = modify;
    
	id<CCRGBAProtocol> child;
	CCARRAY_FOREACH(children_, child)
    [child setOpacityModifyRGB:modify];
}

-(BOOL) doesOpacityModifyRGB
{
	return opacityModifyRGB_;
}

#pragma mark LabelBMFont - AnchorPoint
-(void) setAnchorPoint:(CGPoint)point
{
	if( ! CGPointEqualToPoint(point, anchorPoint_) ) {
		[super setAnchorPoint:point];
		[self createFontChars];
	}
}

#pragma mark LabelBMFont - Alignment
- (void)setWidth:(float)width {
    width_ = width;
    [self updateLabel];
}

- (void)setAlignment:(CCTextAlignment)alignment {
    alignment_ = alignment;
    [self updateLabel];
}

- (void)setBottomDisplay:(CCLabelBottomDisplay)bottomDisplay {
	bottomDisplay_ = bottomDisplay;
    [self updateLabel];
}

- (void)setTopDisplay:(CCLabelTopDisplay)topDisplay {
	topDisplay_ = topDisplay;
	[self updateLabel];
}

-(void)setLineHeight:(float)lineHeight {
    lineHeight_ = MAX(lineHeight, 0);
    [self updateLabel];
}

#pragma mark LabelBMFont - FntFile
- (void) setFntFile:(NSString*) fntFile
{
	if( fntFile != fntFile_ ) {
		
		CCBMFontConfiguration *newConf = FNTConfigLoadFile(fntFile);
		
		NSAssert( newConf, @"CCLabelBMFont: Impossible to create font. Please check file: '%@'", fntFile );
		
		[fntFile_ release];
		fntFile_ = [fntFile retain];
		
		[configuration_ release];
		configuration_ = [newConf retain];
        
		[self setTexture:[[CCTextureCache sharedTextureCache] addImage:configuration_.atlasName]];
		[self createFontChars];
	}
}

- (NSString*) fntFile
{
    return fntFile_;
}

#pragma mark LabelBMFont - Debug draw
#if CC_LABELBMFONT_DEBUG_DRAW
-(void) draw
{
	[super draw];
    
	CGSize s = [self contentSize];
	CGPoint vertices[4]={
		ccp(0,0),ccp(s.width,0),
		ccp(s.width,s.height),ccp(0,s.height),
	};
	ccDrawPoly(vertices, 4, YES);
}
#endif // CC_LABELBMFONT_DEBUG_DRAW
@end