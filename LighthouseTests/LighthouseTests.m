//
//  LighthouseTests.m
//  LighthouseTests
//
//  Created by Nick Tymchenko on 20/01/16.
//  Copyright © 2016 Pixty. All rights reserved.
//

#import "LHMacro.h"
#import "LHGraph.h"
#import "LHGraphEdge.h"
#import "LHLeafNode.h"
#import "LHRouteHint.h"
#import "LHStackNode.h"
#import "LHTarget.h"
#import <XCTest/XCTest.h>

@interface LighthouseTests : XCTestCase

@end

@implementation LighthouseTests

- (void)testAddingRoot {
    LHMutableGraph<NSString *> *graph = [[LHMutableGraph alloc] init];
    
    NSString *root = @"root";
    graph.rootNode = root;
    
    XCTAssertNotNil(graph.rootNode);
    XCTAssertTrue([graph.nodes containsObject:graph.rootNode]);
}

- (void)testAddingEdges {
    LHMutableGraph<NSString *> *graph = [[LHMutableGraph alloc] init];
    
    NSString *root = @"root";
    NSString *child1 = @"child 1";
    NSString *child2 = @"child 2";
    NSString *child3 = @"child 3";
    NSString *child4 = @"child 4";
    
    graph.rootNode = root;
    [graph addEdgeFromNode:root toNode:child1];
    [graph addEdgeFromNode:root toNode:child2];
    [graph addEdgeFromNode:root toNode:child4];
    [graph addEdgeFromNode:child1 toNode:child2];
    [graph addEdgeFromNode:child2 toNode:child3];
    [graph addEdgeFromNode:child2 toNode:child4];
    
    XCTAssertEqual(graph.nodes.count, 5);
    XCTAssertEqual(graph.edges.count, 6);
}

- (void)testFindingPath1 {
    LHMutableGraph<NSString *> *graph = [[LHMutableGraph alloc] init];
    
    NSString *root = @"root";
    NSString *child1 = @"child 1";
    NSString *child2 = @"child 2";
    NSString *child3 = @"child 3";
    NSString *child4 = @"child 4";
    
    graph.rootNode = root;
    [graph addEdgeFromNode:root toNode:child1];
    [graph addEdgeFromNode:root toNode:child2];
    [graph addEdgeFromNode:child1 toNode:child2];
    [graph addEdgeFromNode:child1 toNode:child3];
    [graph addEdgeFromNode:child2 toNode:child4];
    [graph addEdgeFromNode:child3 toNode:child4];
    
    NSOrderedSet *path = [NSOrderedSet orderedSetWithArray:@[root, child2, child4]];
    XCTAssertEqualObjects([graph pathFromNode:root toNode:child4], path);
}

- (void)testFindingPath2 {
    LHMutableGraph<NSString *> *graph = [[LHMutableGraph alloc] init];
    
    NSString *root = @"root";
    NSString *child1 = @"child 1";
    NSString *child2 = @"child 2";
    
    graph.rootNode = root;
    [graph addEdgeFromNode:root toNode:child1];
    [graph addEdgeFromNode:root toNode:child2];
    [graph addEdgeFromNode:child1 toNode:child2];
    
    NSOrderedSet *path = [NSOrderedSet orderedSetWithArray:@[root, child1]];
    XCTAssertEqualObjects([graph pathFromNode:root toNode:child1], path);
}

- (void)testFindingPathVisitingNodes {
    LHMutableGraph<NSString *> *graph = [[LHMutableGraph alloc] init];
    
    NSString *root = @"root";
    NSString *child1 = @"child 1";
    NSString *child2 = @"child 2";
    NSString *child3 = @"child 3";
    NSString *child4 = @"child 4";
    
    graph.rootNode = root;
    [graph addEdgeFromNode:root toNode:child1];
    [graph addEdgeFromNode:root toNode:child2];
    [graph addEdgeFromNode:child1 toNode:child2];
    [graph addEdgeFromNode:child1 toNode:child3];
    [graph addEdgeFromNode:child2 toNode:child4];
    [graph addEdgeFromNode:child3 toNode:child4];
    
    NSOrderedSet *path = [NSOrderedSet orderedSetWithArray:@[root, child1, child3, child4]];
    NSOrderedSet *visitNodes = [NSOrderedSet orderedSetWithObject:child3];
    XCTAssertEqualObjects([graph pathFromNode:root toNode:child4 visitingNodes:visitNodes], path);
}

- (void)testBidirectionalSearchOfPath {
    let node1 = [[LHLeafNode alloc] initWithLabel:@"node 1"];
    let node2 = [[LHLeafNode alloc] initWithLabel:@"node 2"];
    let node3 = [[LHLeafNode alloc] initWithLabel:@"node 3"];
    let node4 = [[LHLeafNode alloc] initWithLabel:@"node 4"];

    let stackNode = [[LHStackNode alloc] initWithGraphBlock:^(LHMutableGraph<id<LHNode>> *graph) {
        graph.rootNode = node1;
        [graph addBidirectionalEdgeFromNode:node1 toNode:node2];
        [graph addBidirectionalEdgeFromNode:node2 toNode:node3];
        [graph addBidirectionalEdgesFromNode:node3 toNodes:@[node3, node4]];
    } label:@"stack"];

    [stackNode updateChildrenState:[LHTarget withActiveNode:node2]];
    [stackNode updateChildrenState:[LHTarget withActiveNode:node3]];
    [stackNode updateChildrenState:[LHTarget withActiveNode:node3]];
    [stackNode updateChildrenState:[LHTarget withActiveNode:node4]];

    let routeHint = [[LHRouteHint alloc] initWithNodes:nil origin:LHRouteHintOriginActiveNode bidirectional:YES];
    let target = [[LHTarget alloc] initWithActiveNodes:[NSSet setWithObject:node2] inactiveNodes:nil routeHint:routeHint];

    [stackNode updateChildrenState:target];

    XCTAssertEqualObjects(stackNode.childrenState.stack, (@[node1, node2]));
}

@end
