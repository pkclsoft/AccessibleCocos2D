//
//  AccessibleGLView.m
//  AccessibleCocos2D
//
//  Created by Peter Easdown on 11/07/2014.
//  Copyright (c) 2014 PKCLsoft. All rights reserved.
//

#import "AccessibleGLView.h"
#import "AccessibleSwitchableNode.h"

@implementation AccessibleGLView {
    
    NSMutableArray *elements;
    
}


- (id) initWithFrame:(CGRect)frame pixelFormat:(NSString*)format depthFormat:(GLuint)depth preserveBackbuffer:(BOOL)retained sharegroup:(EAGLSharegroup*)sharegroup multiSampling:(BOOL)sampling numberOfSamples:(unsigned int)nSamples {
    self = [super initWithFrame:frame pixelFormat:format depthFormat:depth preserveBackbuffer:retained sharegroup:sharegroup multiSampling:sampling numberOfSamples:nSamples];
    
    if (self) {
        // Initialization code
        elements = [[NSMutableArray array] retain];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) addElement:(UIAccessibilityElement*)element {
    [self addElement:element partOfBatch:NO];
}

- (void) addElement:(UIAccessibilityElement*)element partOfBatch:(BOOL)batching {
    @synchronized (elements) {
        if (element == nil) {
            NSLog(@"Adding NULL element!");
        }
        
        NSLog(@"Adding element: %@ with language: %@", element, element.accessibilityLanguage);
        [elements addObject:element];
    }
    
    if (batching == NO) {
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
    }
}

- (void) removeElement:(UIAccessibilityElement*)element {
    [self removeElement:element partOfBatch:NO];
}

- (void) removeElement:(UIAccessibilityElement*)element partOfBatch:(BOOL)batching {
    @synchronized (elements) {
        NSLog(@"Removing element: %@ with language: %@", element.accessibilityLabel, element.accessibilityLanguage);
        [elements removeObject:element];
    }
    
    if (batching == NO) {
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
    }
}

#pragma mark - CCSwitchableNode Wrapper

// Adds a single node to the layer for inclusion in the current set of nodes under control.
//
- (void) addNode:(id<CCSwitchableNode>)node {
    [self addNode:node partOfBatch:NO];
}

- (void) addNode:(id<CCSwitchableNode>)node partOfBatch:(BOOL)batching {
    AccessibleSwitchableNode *element = [AccessibleSwitchableNode accessibleSwitchableWithNode:node inContainer:self];
    
    [self addElement:element partOfBatch:batching];
}

// Adds the specified array of nodes to the layer for inclusion in the current set of nodes under control.
//
- (void) addNodes:(NSArray*)switchableNodes {
    [switchableNodes enumerateObjectsWithOptions:0 usingBlock:^(id node, NSUInteger idx, BOOL *stop) {
        if ([node conformsToProtocol:@protocol(CCSwitchableNode)] == YES) {
            [self addNode:node partOfBatch:YES];
        } else {
            NSLog(@"Attempting to insert node that does not conform to CCSwitchableNode: %@", node);
        }
    }];
    
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

// Removes the specified node from the current set of nodes under control.
//
- (void) removeNode:(id<CCSwitchableNode>)node {
    [self removeNode:node partOfBatch:NO];
}

- (void) removeNode:(id<CCSwitchableNode>)node partOfBatch:(BOOL)batching {
    AccessibleSwitchableNode *elementToRemove= nil;
    
    for (AccessibleSwitchableNode *element in elements) {
        if ([element respondsToSelector:@selector(node)] == YES) {
            if (element.node == node) {
                elementToRemove = element;
            }
        }
    }

    if (elementToRemove != nil) {
        [self removeElement:elementToRemove partOfBatch:batching];
    }
}

// Removes the specified nodes from the current set of nodes under control.
//
- (void) removeNodes:(NSArray*)switchableNodes {
    for (id node in switchableNodes) {
        if ([node conformsToProtocol:@protocol(CCSwitchableNode)] == YES) {
            [self removeNode:node partOfBatch:YES];
        } else {
            NSLog(@"Attempting to remove node that does not conform to CCSwitchableNode: %@", node);
        }
    }
    
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}


#pragma mark - UIAccessibilityContainer

-(NSArray *)accessibilityElements{
    return elements;
}

-(BOOL)isAccessibilityElement{
    return NO;
}

-(NSInteger)accessibilityElementCount{
    return [self accessibilityElements].count;
}
-(NSInteger)indexOfAccessibilityElement:(id)element{
    NSLog(@"indexOfAccessibilityElement: %@", ((UIAccessibilityElement*)element).accessibilityLabel);

    return [[self accessibilityElements] indexOfObject:element];
}
-(id)accessibilityElementAtIndex:(NSInteger)index{
    UIAccessibilityElement* result = [[self accessibilityElements] objectAtIndex:index];
    NSLog(@"accessibilityElementAtIndex: %@", ((UIAccessibilityElement*)result).accessibilityLabel);
    return result;
}

@end
