//
//  CocosUtil.m
//  CompareATwist
//
//  Created by Peter Easdown on 23/04/11.
//  Copyright 2011 AppOfApproval. All rights reserved.
//

#import "CocosUtil.h"
#import "math.h"

@interface CocosUtil (private)

@end

@implementation CocosUtil

static int cachedDeviceType_ = IPHONE_DEVICE;
static bool initialized_ = NO;

+ (int) deviceType {
    if (initialized_ == NO) {
        BOOL iPad = NO;
    
#ifdef UI_USER_INTERFACE_IDIOM
        iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#endif
    
        if (iPad) {
            cachedDeviceType_ = IPAD_DEVICE;
        } else {
            cachedDeviceType_ = IPHONE_DEVICE;
        }
        
        initialized_ = YES;
    }
    
    return cachedDeviceType_;
}

+ (BOOL) isiOS6orLater {
    NSString *reqSysVer = @"6.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
    {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL) isiOS8orLater {
    NSString *reqSysVer = @"8.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
    {
        return YES;
    } else {
        return NO;
    }
}

+ (void) initStaticConstants {
    // Swap the width and height for landscape mode
    //
    if ([CocosUtil isiOS8orLater] == YES) {
        cocosutil_screenRect_.size.width = [[UIScreen mainScreen] bounds].size.width;
        cocosutil_screenRect_.size.height = [[UIScreen mainScreen] bounds].size.height;
    } else {
        cocosutil_screenRect_.size.height = [[UIScreen mainScreen] bounds].size.width;
        cocosutil_screenRect_.size.width = [[UIScreen mainScreen] bounds].size.height;
    }
    
    cocosutil_screenCentre_ = CGPointMake(cocosutil_screenRect_.size.width / 2.0f, cocosutil_screenRect_.size.height / 2.0f);
}


+ (CGPoint) centerOfRect:(CGRect)rect {
	return CGPointMake(rect.origin.x + (rect.size.width / 2.0f), rect.origin.y + (rect.size.height / 2.0f));
}

+ (CGPoint) centerWith:(float)x andY:(float)y andWidth:(float)width andHeight:(float)height {
	return CGPointMake(x + (width / 2.0f), y + (height / 2.0f));
}

static CGRect cocosutil_screenRect_;

+ (CGRect) screenRect {
    return cocosutil_screenRect_;
}

+ (float) screenHeight {
    return cocosutil_screenRect_.size.height;
}

+ (float) screenWidth {
    return cocosutil_screenRect_.size.width;
}

static CGPoint cocosutil_screenCentre_;

+ (CGPoint) screenCentre {
    return cocosutil_screenCentre_;
}

+ (NSString*) xibForDeviceForName:(NSString*)baseName {
    if ([self screenWidth] == 1024) {
        return [NSString stringWithFormat:@"%@-ipad", baseName];
    } else if ([self screenWidth] == 568) {
        return [NSString stringWithFormat:@"%@-4hd", baseName];
    } else {
        return [NSString stringWithFormat:@"%@", baseName];
    }
}

+ (NSString*) imageForDeviceForName:(NSString*)baseName {
    return [NSString stringWithFormat:@"%@.png", baseName];
}

+ (NSString*) plistForDeviceForName:(NSString*)baseName {
    return [NSString stringWithFormat:@"%@.plist", baseName];
}

+ (float) screenFactor {
    return [[CCDirector sharedDirector] contentScaleFactor];
}

+ (CCSprite*) spriteWithOverlaidImages:(UIImage*)inputImage 
                               overlay:(UIImage*)overlay 
                           overlayRect:(CGRect)overlayRect
                               centred:(BOOL)centred {
    
    CGSize largerBounds = [inputImage size];
    
    largerBounds.width = MAX(largerBounds.width, [overlay size].width);
    largerBounds.height = MAX(largerBounds.height, [overlay size].height);
    
	// create a new bitmap image context
	//
	UIGraphicsBeginImageContext(CGSizeMake(largerBounds.width, largerBounds.height));		
	
	// get context
	//
	CGContextRef context = UIGraphicsGetCurrentContext();		
	
	// push context to make it current 
	// (need to do this manually because we are not drawing in a UIView)
	//
	UIGraphicsPushContext(context);								
	
	// drawing code comes here- look at CGContext reference
	// for available operations
	//
	// this example draws the inputImage into the context
	//
    if (centred == YES) {
        [inputImage drawInRect:CGRectMake((largerBounds.width - [inputImage size].width)/2.0f, (largerBounds.height - [inputImage size].height)/2.0f, [inputImage size].width, [inputImage size].height)];
    } else {
        [inputImage drawInRect:CGRectMake(0, 0, [inputImage size].width, [inputImage size].height)];
    }
    
	[overlay drawInRect:overlayRect];
	
	// pop context 
	//
	UIGraphicsPopContext();								
	
	// get a UIImage from the image context- enjoy!!!
	//
	CCSprite *result = [CCSprite spriteWithCGImage:[UIGraphicsGetImageFromCurrentImageContext() CGImage] key:nil];
	
	// clean up drawing environment
	//
	UIGraphicsEndImageContext();
	
	return result;
}

+ (UIImage *) convertSpriteToImage:(CCSprite *)sprite {
    CGPoint p = sprite.anchorPoint;
    [sprite setAnchorPoint:ccp(0,0)];
	
    int width = (int)(sprite.contentSize.width * [sprite scale]);
    int height = (int)(sprite.contentSize.height * [sprite scale]);
	CCRenderTexture *renderer = [CCRenderTexture renderTextureWithWidth:width height:height];
	
	[renderer begin];
	[sprite visit];
	[renderer end];
	
    [sprite setAnchorPoint:p];
	
    UIImage *newImage = [renderer getUIImage];
    
//    NSLog(@"newImage size: width: %2f, height %2f", [newImage size].width, [newImage size].height);
	
    return newImage;
}

+ (CCSprite*) spriteWithLowerSprite:(CCSprite*)lowerSprite andUpperSprite:(CCSprite*)upperSprite {
	UIImage *lowerImage = [CocosUtil convertSpriteToImage:lowerSprite];
	UIImage *upperImage = [CocosUtil convertSpriteToImage:upperSprite];
	
	// Now create the merged sprite.
	//
	return [CocosUtil spriteWithOverlaidImages:lowerImage 
                                       overlay:upperImage 
                                   overlayRect:CGRectMake(0.0, 
                                                          0.0, 
                                                          [upperSprite contentSize].width * [upperSprite scale], 
                                                          [upperSprite contentSize].height * [upperSprite scale])
                                       centred:YES];

}

+ (CGPoint) randomPosInRect:(CGRect)rect {
    float x = fmodf((float)(random()), rect.size.width);
    float y = fmodf((float)(random()), rect.size.height);
    
    return CGPointMake(x + rect.origin.x, y + rect.origin.y);
}

+ (float) scaleForWidth:(float)forWidth andSprite:(CCSprite*)sprite {
    return ([CocosUtil scaledWidth:forWidth] / ([sprite contentSize].width * [sprite scale]));
}

+ (float) scaleForHeight:(float)forHeight andSprite:(CCSprite*)sprite {
    return ([CocosUtil scaledHeight:forHeight] / ([sprite contentSize].height * [sprite scale]));
}

+ (float) scaledWidth:(float)forWidth {
    return ((forWidth / IPHONE_WIDTH) * [CocosUtil screenWidth]);
}

+ (float) scaledHeight:(float)forHeight {
    return ((forHeight / IPHONE_HEIGHT) * [CocosUtil screenHeight]);
}

+ (float) scaledXCoordinate:(float)input letterBoxed:(BOOL)letterBoxed {
    if (letterBoxed == YES) {
        float adjustedInput = (IS_IPHONE_5) ? (input + ((IPHONE5_WIDTH - IPHONE_WIDTH) / 2.0f)) : input;
        return ([CocosUtil deviceType] == IPHONE_DEVICE) ? adjustedInput : [CocosUtil scaledWidth:input];
    } else {
        return ([CocosUtil deviceType] == IPHONE_DEVICE) ? input : [CocosUtil scaledWidth:input];
    }
}

/**
 *  Cubic bezier approximation of a circular arc centered at the origin, 
 *  from (radians) a1 to a2, where a2-a1 < pi/2.  The arc's radius is r.
 * 
 *  Returns an object with four points, where x1,y1 and x4,y4 are the arc's end points
 *  and x2,y2 and x3,y3 are the cubic bezier's control points.
 * 
 *  This algorithm is based on the approach described in:
 *  A. Riškus, "Approximation of a Cubic Bezier Curve by Circular Arcs and Vice Versa," 
 *  Information Technology and Control, 35(4), 2006 pp. 371-378.
 */
+ (ccBezierConfig) createSmallArcWithRadius:(float)r andAngle1:(float)a1Deg andAngle2:(float)a2Deg fromStartPos:(CGPoint)startPos {
    // Compute all four points for an arc that subtends the same total angle
    // but is centered on the X-axis
    
    float a1 = CC_DEGREES_TO_RADIANS(a1Deg);
    float a2 = CC_DEGREES_TO_RADIANS(a2Deg);

    const float a = (a2 - a1) / 2.0f; //
    
    const float x4 = r * cosf(a);
    const float y4 = r * sinf(a);
    const float x1 = x4;
    const float y1 = -y4;
    
    const float k = 0.5522847498f;
    const float f = k * tanf(a);
    
    const float x2 = x1 + f * y4;
    const float y2 = y1 + f * x4;
    const float x3 = x2; 
    const float y3 = -y2;
    
    // Find the arc points actual locations by computing x1,y1 and x4,y4 
    // and rotating the control points by a + a1
    
    const float ar = a + a1;
    const float cos_ar = cosf(ar);
    const float sin_ar = sinf(ar);
    
    ccBezierConfig result;
    CGPoint offset = ccpSub(startPos, CGPointMake(r * cosf(a1), r * sinf(a1)));
    result.controlPoint_1 = ccpAdd(offset, CGPointMake(x2 * cos_ar - y2 * sin_ar, x2 * sin_ar + y2 * cos_ar));
    result.controlPoint_2 = ccpAdd(offset, CGPointMake(x3 * cos_ar - y3 * sin_ar, x3 * sin_ar + y3 * cos_ar));
    result.endPosition = ccpAdd(offset, CGPointMake(r * cosf(a2), r * sinf(a2)));
    
    return result;
}

/**
 * spins the specified node around it's Y axis every 2 seconds.
 */
+ (void) spinNode:(CCNode*)node {
	[node runAction:[CCRepeatForever actionWithAction:[CCOrbitCamera actionWithDuration:2.0 radius:1 deltaRadius:0 angleZ:0 deltaAngleZ:720 angleX:0 deltaAngleX:0]]];
}

+ (void) moveSpriteThroughCircle:(CCNode*)sprite clockWise:(BOOL)clockWise withDriftDirection:(CGPoint)driftDirection withDuration:(float)duration withCompletionBlock:(NodeCompletionBlock)completionBlock {
    
    float delta = 7;//(float)(random() % 50);
	float durationPerSegment = duration / 4.0f;
    
	ccBezierConfig bezier;
	id bezierAction;
    NSMutableArray *actions = [NSMutableArray array];
//    bezier.autorotate = NO;
    
    void (^redoBlock)() = ^ {
        if (CGRectContainsPoint([CocosUtil screenRect], [sprite position]) == YES) {
            [CocosUtil moveSpriteThroughCircle:sprite clockWise:clockWise withDriftDirection:driftDirection withDuration:duration withCompletionBlock:completionBlock];
        } else if (completionBlock != nil) {
            completionBlock(sprite);
        }
    };
    
    if (clockWise == NO) {
        bezier = [CocosUtil createSmallArcWithRadius:delta andAngle1:0.0 andAngle2:90.0 fromStartPos:[sprite position]];
        
        if ((driftDirection.x != 0.0) || (driftDirection.y != 0.0)) {
            CGPoint oldEnd = bezier.endPosition;
            bezier.endPosition = ccpAdd(bezier.endPosition, driftDirection);
            float dist1 = ccpDistance(bezier.controlPoint_2, oldEnd);
            float dist2 = ccpDistance(bezier.controlPoint_2, bezier.endPosition);
            float timeFactor = (dist2 / dist1) / 2.0f;
            
            bezierAction = [CCBezierTo actionWithDuration:(durationPerSegment * timeFactor) bezier:bezier];
        } else {
            bezierAction = [CCBezierTo actionWithDuration:durationPerSegment bezier:bezier];
        }
        [actions addObject:bezierAction];
        
        bezier = [CocosUtil createSmallArcWithRadius:delta andAngle1:90.0 andAngle2:180.0 fromStartPos:bezier.endPosition];
        bezierAction = [CCBezierTo actionWithDuration:durationPerSegment bezier:bezier];
        [actions addObject:bezierAction];
        
        bezier = [CocosUtil createSmallArcWithRadius:delta andAngle1:180.0 andAngle2:270.0 fromStartPos:bezier.endPosition];
        bezierAction = [CCBezierTo actionWithDuration:durationPerSegment bezier:bezier];
        [actions addObject:bezierAction];
        
        bezier = [CocosUtil createSmallArcWithRadius:delta andAngle1:270.0 andAngle2:360.0 fromStartPos:bezier.endPosition];
        bezierAction = [CCBezierTo actionWithDuration:durationPerSegment bezier:bezier];
        
        [actions addObject:bezierAction];
        
        [actions addObject:[CCCallBlock actionWithBlock:redoBlock]];
    } else {
        bezier = [CocosUtil createSmallArcWithRadius:delta andAngle1:360.0 andAngle2:270.0 fromStartPos:[sprite position]];
        bezierAction = [CCBezierTo actionWithDuration:durationPerSegment bezier:bezier];
        [actions addObject:bezierAction];
        
        bezier = [CocosUtil createSmallArcWithRadius:delta andAngle1:270.0 andAngle2:180.0 fromStartPos:bezier.endPosition];
        bezierAction = [CCBezierTo actionWithDuration:durationPerSegment bezier:bezier];
        [actions addObject:bezierAction];
        
        bezier = [CocosUtil createSmallArcWithRadius:delta andAngle1:180.0 andAngle2:90.0 fromStartPos:bezier.endPosition];
        if ((driftDirection.x != 0.0) || (driftDirection.y != 0.0)) {
            CGPoint oldEnd = bezier.endPosition;
            bezier.endPosition = ccpAdd(bezier.endPosition, driftDirection);
            float dist1 = ccpDistance(bezier.controlPoint_2, oldEnd);
            float dist2 = ccpDistance(bezier.controlPoint_2, bezier.endPosition);
            float timeFactor = (dist2 / dist1) / 2.0f;
            
            bezierAction = [CCBezierTo actionWithDuration:(durationPerSegment * timeFactor) bezier:bezier];
        } else {
            bezierAction = [CCBezierTo actionWithDuration:durationPerSegment bezier:bezier];
        }
        [actions addObject:bezierAction];
        
        bezier = [CocosUtil createSmallArcWithRadius:delta andAngle1:90.0 andAngle2:0.0 fromStartPos:bezier.endPosition];
        bezierAction = [CCBezierTo actionWithDuration:durationPerSegment bezier:bezier];
        [actions addObject:bezierAction];
        
        [actions addObject:[CCCallBlock actionWithBlock:redoBlock]];
    }
    	
	[sprite runAction:[CCSequence actionWithArray:actions]];
}

// This will return a texture that can be drawn behind a CCLabelTTF object, providing an outline of the
// text within the label.
//
// This code was adapted from code found at:  
//
+(CCRenderTexture*) createStroke: (CCLabelTTF*) label   size:(float)size   color:(ccColor3B)cor
{
	CCRenderTexture* rt = [CCRenderTexture renderTextureWithWidth:(int)(label.texture.contentSize.width+size*2.0f)  height:(int)(label.texture.contentSize.height+size*2.0f)];
	CGPoint originalPos = [label position];
	ccColor3B originalColor = [label color];
	BOOL originalVisibility = [label visible];
	[label setColor:cor];
	[label setVisible:YES];
	ccBlendFunc originalBlend = [label blendFunc];
	[label setBlendFunc:(ccBlendFunc) { GL_SRC_ALPHA, GL_ONE }];
	CGPoint bottomLeft = ccp(label.texture.contentSize.width * label.anchorPoint.x + size, label.texture.contentSize.height * label.anchorPoint.y + size);
	CGPoint positionOffset = ccp(label.texture.contentSize.width * label.anchorPoint.x - label.texture.contentSize.width/2,label.texture.contentSize.height * label.anchorPoint.y - label.texture.contentSize.height/2);
	CGPoint position = ccpSub(originalPos, positionOffset);
    
	[rt begin];
	for (int i=0; i<360; i+=30) // you should optimize that for your needs
	{
		[label setPosition:ccp(bottomLeft.x + sinf(CC_DEGREES_TO_RADIANS(i))*size, bottomLeft.y + cosf(CC_DEGREES_TO_RADIANS(i))*size)];
		[label visit];
	}
	[rt end];
	[label setPosition:originalPos];
	[label setColor:originalColor];
	[label setBlendFunc:originalBlend];
	[label setVisible:originalVisibility];
	[rt setPosition:position];
	return rt;
}

+(CCRenderTexture*) createStrokeForSprite:(CCSprite*)sprite  size:(float)size  color:(ccColor3B)cor
{
	CCRenderTexture* rt = [CCRenderTexture renderTextureWithWidth:(int)(sprite.texture.contentSize.width+size*2.0f)  height:(int)(sprite.texture.contentSize.height+size*2.0f)];
	CGPoint originalPos = [sprite position];
	ccColor3B originalColor = [sprite color];
	BOOL originalVisibility = [sprite visible];
	[sprite setColor:cor];
	[sprite setVisible:YES];
	ccBlendFunc originalBlend = [sprite blendFunc];
	[sprite setBlendFunc:(ccBlendFunc) { GL_SRC_ALPHA, GL_ONE }];
	CGPoint bottomLeft = ccp(sprite.texture.contentSize.width * sprite.anchorPoint.x + size, sprite.texture.contentSize.height * sprite.anchorPoint.y + size);
	CGPoint positionOffset = ccp(sprite.texture.contentSize.width * sprite.anchorPoint.x - sprite.texture.contentSize.width/2,sprite.texture.contentSize.height * sprite.anchorPoint.y - sprite.texture.contentSize.height/2);
	CGPoint position = ccpSub(originalPos, positionOffset);
    
	[rt begin];
	for (int i=0; i<360; i+=30) // you should optimize that for your needs
	{
		[sprite setPosition:ccp(bottomLeft.x + sinf(CC_DEGREES_TO_RADIANS(i))*size, bottomLeft.y + cosf(CC_DEGREES_TO_RADIANS(i))*size)];
		[sprite visit];
	}
	[rt end];
	[sprite setPosition:originalPos];
	[sprite setColor:originalColor];
	[sprite setBlendFunc:originalBlend];
	[sprite setVisible:originalVisibility];
	[rt setPosition:position];
	return rt;
}

// Converts an angle in the world where 0 is north in a clockwise direction to a world
// where 0 is east in an anticlockwise direction.
//
+ (float) angleFromDegrees:(float)deg {
    return fmodf((450.0f - deg), 360.0);
}

// Calculates the angle from one point to another, in radians.
//
+ (float) angleFromPoint:(CGPoint)from toPoint:(CGPoint)to {
    CGPoint pnormal = ccpSub(to, from);
    float radians = atan2f(pnormal.x, pnormal.y);
    
    return radians;
}

+ (CGPoint) pointOnCircleWithCentre:(CGPoint)centerPt andRadius:(float)radius atDegrees:(float)degrees {
    float x = radius + cosf (CC_DEGREES_TO_RADIANS([self angleFromDegrees:degrees])) * radius;
    float y = radius + sinf (CC_DEGREES_TO_RADIANS([self angleFromDegrees:degrees])) * radius;
    return ccpAdd(centerPt, ccpSub(CGPointMake(x, y), CGPointMake(radius, radius)));
}

+ (void) floatNode:(CCNode<CCRGBAProtocol>*)node fromPos:(CGPoint)fromPos toPos:(CGPoint)toPos overDuration:(ccTime)duration withCompletionBlock:(CompletionBlock)completionBlock {
    [node setPosition:fromPos];
    [node setOpacity:0];
    
    ccTime slice = duration / 5.0f;
    
    [node runAction:[CCSpawn actions:
                     [CCSequence actions:
                      [CCFadeIn actionWithDuration:slice],
                      [CCDelayTime actionWithDuration:(slice * 3)],
                      [CCFadeOut actionWithDuration:slice],
                      [CCCallBlock actionWithBlock:
                       ^{
                           if (completionBlock != nil) {
                               completionBlock();
                           }
                       }],
                      [CCRemoveFromParentAction action],
                      nil],
                     [CCMoveTo actionWithDuration:duration position:toPos],
                     nil]];
}

+(UIImage*) takeScreenShot {
    //[CCDirector sharedDirector].nextDeltaTimeZero = YES;
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    CCRenderTexture* rtx = [CCRenderTexture renderTextureWithWidth:(int)winSize.width height:(int)winSize.height];
    
    [rtx beginWithClear:0 g:0 b:0 a:1.0f];
    [[[CCDirector sharedDirector] runningScene] visit];
    [rtx end];
    
    return [rtx getUIImage];
}

// Rotated Rectangles Collision Detection, Oren Becker, 2001
//
// http://www.ragestorm.net/tutorial?id=22
//
+ (ccIntersection) rect:(CGRect)rect1 withRotation:(float)rect1Rotation intersectsRect:(CGRect)rect2 withRotation:(float)rect2Rotation {
    ccIntersection result = {
        0.0f,
        NO
    };
    
    cpVect A, B;   // vertices of the rotated rr2
    cpVect C;      // center of rr2
    cpVect BL, TR; // vertices of rr2 (bottom-left, top-right)
    cpVect BS = cpv(rect2.size.width/2.0f, rect2.size.height/2.0f);
    
    float ang = CC_DEGREES_TO_RADIANS(rect1Rotation) - CC_DEGREES_TO_RADIANS(rect2Rotation); // orientation of rotated rr1
    float cosa = cosf(ang);           // precalculated trigonometic -
    float sina = sinf(ang);           // - values for repeated use
    
    float t, x, a;      // temporary variables for various uses
    float dx;           // deltaX for linear equations
    float ext1, ext2;   // min/max vertical values
    
    // move rr2 to make rr1 cannonic
    C = cpvsub(rect2.origin, rect1.origin);
    
    // rotate rr2 clockwise by rr2->ang to make rr2 axis-aligned
    C = ccpRotateByAngle(C, CGPointZero, CC_DEGREES_TO_RADIANS(-1.0f * rect2Rotation));
    
    // calculate vertices of (moved and axis-aligned := 'ma') rr2
    BL = TR = C;
    BL = cpvsub(BL, BS);
    TR = cpvadd(TR, BS);
    
    // calculate vertices of (rotated := 'r') rr1
    A.x = -(rect1.size.height/2.0f)*sina;
    B.x = A.x;
    t = (rect1.size.width/2.0f)*cosa;
    A.x += t;
    B.x -= t;
    
    A.y = (rect1.size.height/2.0f)*cosa;
    B.y = A.y;
    t = (rect1.size.width/2.0f)*sina;
    A.y += t;
    B.y -= t;
    
    t = sina*cosa;
    
    // verify that A is vertical min/max, B is horizontal min/max
    if (t < 0) {
        t = A.x;
        A.x = B.x;
        B.x = t;
        
        t = A.y;
        A.y = B.y;
        B.y = t;
    }
    
    // verify that B is horizontal minimum (leftest-vertex)
    if (sina < 0) {
        B.x = -B.x;
        B.y = -B.y;
    }
    
    // if rr2(ma) isn't in the horizontal range of
    // colliding with rr1(r), collision is impossible
    if (B.x > TR.x || B.x > -BL.x) {
        return result;
    }
    
    // if rr1(r) is axis-aligned, vertical min/max are easy to get
    if (t == 0) {
        ext1 = A.y;
        ext2 = -ext1;
    } else {
    // else, find vertical min/max in the range [BL.x, TR.x]
        x = BL.x-A.x;
        a = TR.x-A.x;
        ext1 = A.y;
        
        // if the first vertical min/max isn't in (BL.x, TR.x), then
        // find the vertical min/max on BL.x or on TR.x
        if (a*x > 0) {
            dx = A.x;
            if (x < 0) {
                dx -= B.x;
                ext1 -= B.y;
                x = a;
            } else {
                dx += B.x;
                ext1 += B.y;
            }
            
            ext1 *= x;
            ext1 /= dx;
            ext1 += A.y;
        }
        
        x = BL.x+A.x;
        a = TR.x+A.x;
        ext2 = -A.y;
        
        // if the second vertical min/max isn't in (BL.x, TR.x), then
        // find the local vertical min/max on BL.x or on TR.x
        if (a*x > 0) {
            dx = -A.x;
            if (x < 0) {
                dx -= B.x;
                ext2 -= B.y;
                x = a;
            } else {
                dx += B.x;
                ext2 += B.y;
            }
            
            ext2 *= x;
            ext2 /= dx;
            ext2 -= A.y;
        }
    }
    
    // check whether rr2(ma) is in the vertical range of colliding with rr1(r)
    // (for the horizontal range of rr2)
    if (!((ext1 < BL.y && ext2 < BL.y) ||
          (ext1 > TR.y && ext2 > TR.y))) {
        result.intersects = YES;
        result.overlapSize = MAX(BL.y - ext1, BL.y - ext2);
    }
    
    return result;
}

#define CC_DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) * 0.01745329252f) // PI / 180

// http://www.migapro.com/circle-and-rotated-rectangle-collision-detection/
//
+ (ccIntersection) intersectionOfCircleWithRadius:(float)radius atPoint:(CGPoint)circlePt andRectangle:(CGRect)rect withRotation:(float)rotation {
    ccIntersection result;
    
    // Rotate circle's center point back
    float unrotatedCircleX =
        cosf(CC_DEGREES_TO_RADIANS(rotation)) * (circlePt.x - rect.origin.x) -
        sinf(CC_DEGREES_TO_RADIANS(rotation)) * (circlePt.y - rect.origin.y) + rect.origin.x;
    
    float unrotatedCircleY =
        sinf(CC_DEGREES_TO_RADIANS(rotation)) * (circlePt.x - rect.origin.x) +
        cosf(CC_DEGREES_TO_RADIANS(rotation)) * (circlePt.y - rect.origin.y) + rect.origin.y;
    
    // Closest point in the rectangle to the center of circle rotated backwards(unrotated)
    float closestX, closestY;
    
    // Find the unrotated closest x point from center of unrotated circle
    if (unrotatedCircleX  < (rect.origin.x - (rect.size.width/2.0f))) {
        closestX = rect.origin.x - (rect.size.width/2.0f);
    } else if (unrotatedCircleX  > rect.origin.x + (rect.size.width+rect.size.width/2.0f)) {
        closestX = rect.origin.x + (rect.size.width/2.0f);
    } else {
        closestX = unrotatedCircleX ;
    }
    
    // Find the unrotated closest y point from center of unrotated circle
    if (unrotatedCircleY < (rect.origin.y - (rect.size.height/2.0f))) {
        closestY = rect.origin.y - (rect.size.height/2.0f);
    } else if (unrotatedCircleY > (rect.origin.y + (rect.size.height/2.0f))) {
        closestY = rect.origin.y + (rect.size.height/2.0f);
    } else {
        closestY = unrotatedCircleY;
    }
    
    // Determine collision
    
    float distance = [CocosUtil distanceFrom:CGPointMake(unrotatedCircleX , unrotatedCircleY) to:CGPointMake(closestX, closestY)];
    
    if (distance < radius) {
        result.intersects = YES; // Collision
        result.overlapSize = radius - distance;
    } else {
        result.intersects = NO;
        result.overlapSize = 0.0f;
    }
    
    return result;
}

+ (float) distanceFrom:(CGPoint)from to:(CGPoint)to {

    float a = abs(from.x - to.x);
    float b = abs(from.y - to.y);
    
    return sqrt((a * a) + (b * b));
}

+ (int) intFromccColor3B:(ccColor3B)color {
    return (color.r * 65536) + (color.g * 256) + color.b;
}

+ (ccColor3B) ccColor3BFromInt:(int)color {
    ccColor3B result;
    
    result.b = color & 0xff;
    result.g = (color & 0xff00) / 256;
    result.r = (color & 0xff0000) / 65536;
    
    return result;
}

@end


