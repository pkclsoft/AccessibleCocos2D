//
//  UICollectionViewStackLayout.m
//  Collector
//
//  Created by Florian Heller on 11/12/12.
//  Copyright (c) 2012 Florian Heller. All rights reserved.
//

#import "FHCollectionViewStackLayout.h"

@interface FHCollectionViewStackLayout ()
@property (strong) NSMutableArray *layoutAttributes;	//This is a local copy of the layout attributes
	
@end

@implementation FHCollectionViewStackLayout

- (id) init {
    self = [super init];
    
    if (self != nil) {
        [self initialiseDefaultProperties];
    }
    
    return self;
}

// We try to fill the entire space
-(CGSize)collectionViewContentSize {
	return self.collectionView.frame.size;
}

- (void) initialiseDefaultProperties {
    self.numberOfStacksPerLine = 3;
    self.leftMargin = 100.0f;
    self.topMargin = 150.0f;
    self.horizontalStackSpacing = ((self.collectionView.frame.size.width - (self.leftMargin * 2.0f)) / (float)(self.numberOfStacksPerLine - 1));
    self.verticalStackSpacing = self.topMargin;
    self.itemSize = CGSizeMake(180, 180);
}

- (void)prepareLayout {
	[super prepareLayout];
    
    [self initialiseDefaultProperties];

	self.layoutAttributes = [NSMutableArray arrayWithCapacity:[self.collectionView numberOfSections]];

	for (NSInteger section=0; section<[self.collectionView numberOfSections]; section++) {
		NSMutableArray *attributesInSection = [NSMutableArray arrayWithCapacity:[self.collectionView numberOfItemsInSection:section]];

		for (NSInteger row=0; row<[self.collectionView numberOfItemsInSection:section]; row++) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row inSection:section];
			PSTCollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
			//UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

			if (row==0) {
				attributes.zIndex = 1;
				attributes.alpha = 1.0;
			} else {
				attributes.zIndex = 0;
				attributes.alpha = 0.3;
			}
            
			float angle = arc4random_uniform(10);
			angle = (angle - 5.)*M_PI/180;
            
			attributes.transform3D = CATransform3DMakeRotation(angle, 0, 0, 1);
			[attributesInSection addObject:attributes];
		}
        
		[self.layoutAttributes addObject:attributesInSection];
	}
}



// Make stacks for every section
- (PSUICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {

	PSUICollectionViewLayoutAttributes *attributes = [PSUICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
	float xCoord = self.leftMargin+(self.horizontalStackSpacing * fmodf(attributes.indexPath.section, self.numberOfStacksPerLine));
	float yCoord = self.topMargin+(self.verticalStackSpacing * floor(attributes.indexPath.section / self.numberOfStacksPerLine));
    
	attributes.center = CGPointMake(xCoord, yCoord);
	attributes.size = self.itemSize;
    
	return attributes;
	
}



- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect {
	NSMutableArray *attributes = [NSMutableArray array];

	NSPredicate *filterPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject,NSDictionary* bindings) {
        
        CGRect frame = [(UICollectionViewLayoutAttributes*)evaluatedObject frame];
        return CGRectIntersectsRect(frame,rect);
    }];
    
	for (NSArray *section in _layoutAttributes) {
		[attributes addObjectsFromArray:[section filteredArrayUsingPredicate:filterPredicate]];
	}
	
    return attributes;
}



- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
	return YES;
}

@end
