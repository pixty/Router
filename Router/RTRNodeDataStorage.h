//
//  RTRNodeDataStorage.h
//  Router
//
//  Created by Nick Tymchenko on 24/09/15.
//  Copyright © 2015 Pixty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTRNodeState.h"

@protocol RTRNode;
@protocol RTRNodeDataStorageDelegate;
@class RTRNodeData;
@class RTRNodeTree;

@interface RTRNodeDataStorage : NSObject

@property (nonatomic, weak) id<RTRNodeDataStorageDelegate> delegate;

@end


@interface RTRNodeDataStorage (Data)

- (BOOL)hasDataForNode:(id<RTRNode>)node;

- (RTRNodeData *)dataForNode:(id<RTRNode>)node;

- (void)resetDataForNode:(id<RTRNode>)node;

@end


@interface RTRNodeDataStorage (State)

@property (nonatomic, readonly) NSSet *resolvedInitializedNodes;

- (RTRNodeState)resolvedStateForNode:(id<RTRNode>)node;

- (void)updateResolvedStateForAffectedNodeTree:(RTRNodeTree *)nodeTree;

@end


@protocol RTRNodeDataStorageDelegate <NSObject>

- (void)nodeDataStorage:(RTRNodeDataStorage *)storage didCreateData:(RTRNodeData *)data forNode:(id<RTRNode>)node;
- (void)nodeDataStorage:(RTRNodeDataStorage *)storage willResetData:(RTRNodeData *)data forNode:(id<RTRNode>)node;

- (void)nodeDataStorage:(RTRNodeDataStorage *)storage didChangeResolvedStateForNode:(id<RTRNode>)node;

@end