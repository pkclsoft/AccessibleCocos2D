//
//  CocosUtil.h
//  CompareATwist
//
//  This is a utility class providing a number of convenience functions that assist with
//  Cocos2D animation.  There are a number of functions that are there to help with apps
//  that need to be universal (run on iPhone and iPad).
//
//  Created by Peter Easdown on 23/04/11.
//  Copyright 2011 AppOfApproval. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IPAD_DEVICE 1
#define IPHONE_DEVICE 0

#define IPHONE_WIDTH 480.0f
#define IPHONE_RETINA_WIDTH 960.0f
#define IPHONE_HEIGHT 320.0f
#define IPHONE_RETINA_HEIGHT 640.0f
#define IPHONE5_WIDTH 568.0f

#define NORMAL_BLEND_MODE ccBlendFuncMake(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
#define ADDITIVE_BLEND_MODE ccBlendFuncMake(GL_ONE, GL_ONE)
#define ADDITIVE_BLEND_WITH_ALPHA_MODE ccBlendFuncMake(GL_SRC_ALPHA, GL_ONE)
#define SCREEN_BLEND_MODE ccBlendFuncMake(GL_ONE_MINUS_DST_COLOR, GL_ONE)
#define BLEND_BLEND_MODE ccBlendFuncMake(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
#define MULTIPLICATIVE_BLEND_MODE ccBlendFuncMake(GL_DST_COLOR, GL_ONE_MINUS_SRC_ALPHA)
#define DODGE_BLEND_MODE ccBlendFuncMake(GL_ONE_MINUS_SRC_ALPHA, GL_ONE)

#define IS_IPAD ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
#define IS_IPHONE ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone))
#define IS_IPHONE_5 ((IS_IPHONE && [CocosUtil screenWidth] == IPHONE5_WIDTH))
#define IS_IPHONE_4 ((IS_IPHONE && [CocosUtil screenWidth] == IPHONE_WIDTH))

@interface CocosUtil : NSObject {

}

+ (void) initStaticConstants;

+ (CGPoint) centerOfRect:(CGRect)rect;
+ (CGPoint) centerWith:(float)x andY:(float)y andWidth:(float)width andHeight:(float)height;
+ (CGRect) screenRect;
+ (float) screenHeight;
+ (float) screenWidth;
+ (CGPoint) screenCentre;
+ (float) screenFactor;

+ (float) scaleForWidth:(float)forWidth andSprite:(CCSprite*)sprite;
+ (float) scaleForHeight:(float)forHeight andSprite:(CCSprite*)sprite;
+ (float) scaledWidth:(float)forWidth;
+ (float) scaledHeight:(float)forHeight;
+ (float) scaledXCoordinate:(float)input letterBoxed:(BOOL)letterBoxed;

+ (NSString*) xibForDeviceForName:(NSString*)baseName;
+ (NSString*) imageForDeviceForName:(NSString*)baseName;
+ (NSString*) plistForDeviceForName:(NSString*)baseName;

// Returns IPHONE_DEVICE for iPhone/iPod or IPAD_DEVICE for iPad
//
+ (int) deviceType;

// Returns YES if the os is iOS6 or later.
//
+ (BOOL) isiOS6orLater;

+ (CCSprite*) spriteWithOverlaidImages:(UIImage*)inputImage 
                               overlay:(UIImage*)overlay 
                           overlayRect:(CGRect)overlayRect
                               centred:(BOOL)centred;
+ (UIImage *) convertSpriteToImage:(CCSprite *)sprite;
+ (CCSprite*) spriteWithLowerSprite:(CCSprite*)lowerSprite andUpperSprite:(CCSprite*)upperSprite;
+ (CGPoint) randomPosInRect:(CGRect)rect;


+ (ccBezierConfig) createSmallArcWithRadius:(float)r andAngle1:(float)a1 andAngle2:(float)a2 fromStartPos:(CGPoint)startPos;

+ (void) spinNode:(CCNode*)node;

typedef void (^CompletionBlock)(void);

typedef void (^NodeCompletionBlock)(CCNode *sprite);

+ (void) moveSpriteThroughCircle:(CCNode*)sprite clockWise:(BOOL)clockWise withDriftDirection:(CGPoint)driftDirection withDuration:(float)duration withCompletionBlock:(NodeCompletionBlock)completionBlock;

// This will return a texture that can be drawn behind a CCLabelTTF object, providing an outline of the
// text within the label.
//
// This code was adapted from code found at:  
//
+(CCRenderTexture*) createStroke: (CCLabelTTF*) label   size:(float)size   color:(ccColor3B)cor;

+(CCRenderTexture*) createStrokeForSprite:(CCSprite*)sprite  size:(float)size  color:(ccColor3B)cor;

+ (CCSpriteBatchNode*) batchNodeForSheet:(NSString*)spriteSheetName;
+ (void) addBatchNode:(CCSpriteBatchNode*)batchNode forSheet:(NSString*)spriteSheetName;
+ (CCSpriteBatchNode*) addBatchNodeWithName:(NSString*)spriteSheetName;
+ (CCSpriteBatchNode*) addBatchNodeWithName:(NSString*)spriteSheetName custom:(BOOL)custom;
+ (CCSpriteBatchNode*) addBatchNodeWithName:(NSString*)spriteSheetName custom:(BOOL)custom imageExtension:(NSString*)imageExtension;
+ (void) removeBatchNodeForSheet:(NSString*)spriteSheetName;

+ (float) angleFromDegrees:(float)deg;

+ (float) angleFromPoint:(CGPoint)from toPoint:(CGPoint)to;

+ (CGPoint) pointOnCircleWithCentre:(CGPoint)centerPt andRadius:(float)radius atDegrees:(float)degrees;

typedef struct {
    float overlapSize;
    BOOL intersects;
} ccIntersection;

+ (ccIntersection) rect:(CGRect)rect1 withRotation:(float)rect1Rotation intersectsRect:(CGRect)rect2 withRotation:(float)rect2Rotation;
+ (ccIntersection) intersectionOfCircleWithRadius:(float)radius atPoint:(CGPoint)circlePt andRectangle:(CGRect)rect withRotation:(float)rotation;

+ (void) floatNode:(CCNode<CCRGBAProtocol>*)node fromPos:(CGPoint)fromPos toPos:(CGPoint)toPos overDuration:(ccTime)duration withCompletionBlock:(CompletionBlock)completionBlock;

+(UIImage*) takeScreenShot;

+ (int) intFromccColor3B:(ccColor3B)color;
+ (ccColor3B) ccColor3BFromInt:(int)color;

@end