//
//  UICollectionViewStackLayout.h
//  Collector
//
//  Created by Florian Heller on 11/12/12.
//  Copyright (c) 2012 Florian Heller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FHCollectionViewStackLayout : PSUICollectionViewLayout

@property (assign) int numberOfStacksPerLine;
@property (assign) float leftMargin;
@property (assign) float topMargin;
@property (assign) float horizontalStackSpacing;
@property (assign) float verticalStackSpacing;
@property (assign) CGSize itemSize;

@end
