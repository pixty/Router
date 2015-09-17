//
//  AppDelegate.m
//  RouterDemo
//
//  Created by Nick Tymchenko on 14/09/15.
//  Copyright © 2015 Pixty. All rights reserved.
//

#import "AppDelegate.h"
#import "PXColorViewControllers.h"
#import "PXModalViewController.h"
#import "PXDeepModalViewController.h"
#import "PXPresentRed.h"
#import "PXPresentGreen.h"
#import "PXPresentBlue.h"
#import "PXPresentModal.h"
#import "PXPresentAnotherModal.h"
#import "RTRRouter+Shared.h"
#import <Router.h>

@interface AppDelegate ()

@property (nonatomic, strong) RTRRouter *router;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    [self setupRouter];
    
    [self doSomething];
    [self performSelector:@selector(doSomethingLater) withObject:nil afterDelay:3.0];
    [self performSelector:@selector(doSomethingEvenLater) withObject:nil afterDelay:6.0];
    [self performSelector:@selector(doSomethingEvenMoreLater) withObject:nil afterDelay:9.0];
    
    return YES;
}

- (void)setupRouter {
    // Nodes
    
    id<RTRNode> redNode = [[RTRLeafNode alloc] init];
    id<RTRNode> greenNode = [[RTRLeafNode alloc] init];
    id<RTRNode> blueNode = [[RTRLeafNode alloc] init];
    id<RTRNode> mainStackNode = [[RTRStackNode alloc] initWithSingleBranch:@[ redNode, greenNode, blueNode ]];
    
    id<RTRNode> modalNode = [[RTRLeafNode alloc] init];
    id<RTRNode> modalStackNode = [[RTRStackNode alloc] initWithSingleBranch:@[ modalNode ]];
    
    id<RTRNode> deepModalNode = [[RTRLeafNode alloc] init];
    id<RTRNode> deepModalStackNode = [[RTRStackNode alloc] initWithSingleBranch:@[ deepModalNode ]];
    
    id<RTRNode> anotherRedNode = [[RTRLeafNode alloc] init];
    id<RTRNode> anotherGreenNode = [[RTRLeafNode alloc] init];
    id<RTRNode> anotherBlueNode = [[RTRLeafNode alloc] init];
    NSArray *anotherTabNodes = @[ anotherRedNode, anotherGreenNode, anotherBlueNode ];
    id<RTRNode> anotherTabNode = [[RTRTabNode alloc] initWithChildren:[NSOrderedSet orderedSetWithArray:anotherTabNodes]];
    id<RTRNode> anotherModalStackNode = [[RTRStackNode alloc] initWithSingleBranch:@[ anotherTabNode ]];
    
    RTRNodeTree *rootTree = [[RTRNodeTree alloc] init];
    [rootTree addBranch:@[ mainStackNode, modalStackNode, deepModalStackNode ] afterNodeOrNil:nil];
    [rootTree addNode:anotherModalStackNode afterNodeOrNil:mainStackNode];
    
    id<RTRNode> rootNode = [[RTRStackNode alloc] initWithTree:rootTree];
    
    
    // Node Content
    
    RTRBlockNodeContentProvider *nodeContentProvider = [[RTRBlockNodeContentProvider alloc] init];
    
    [nodeContentProvider bindNodeClass:[RTRStackNode class] toBlock:^id<RTRNodeContent>(id<RTRNode> node) {
        return [[RTRNavigationControllerContent alloc] init];
    }];
    
    [nodeContentProvider bindNodeClass:[RTRTabNode class] toBlock:^id<RTRNodeContent>(id<RTRNode> node) {
        return [[RTRTabBarControllerContent alloc] init];
    }];
    
    [nodeContentProvider bindNodes:@[ redNode, anotherRedNode ] toBlock:^id<RTRNodeContent>(id<RTRNode> node) {
        return [[RTRViewControllerContent alloc] initWithViewControllerClass:[PXRedViewController class]];
    }];
    
    [nodeContentProvider bindNodes:@[ greenNode, anotherGreenNode ] toBlock:^id<RTRNodeContent>(id<RTRNode> node) {
        return [[RTRViewControllerContent alloc] initWithViewControllerClass:[PXGreenViewController class]];
    }];
    
    [nodeContentProvider bindNodes:@[ blueNode, anotherBlueNode ] toBlock:^id<RTRNodeContent>(id<RTRNode> node) {
        return [[RTRViewControllerContent alloc] initWithViewControllerClass:[PXBlueViewController class]];
    }];
    
    [nodeContentProvider bindNode:modalNode toBlock:^id<RTRNodeContent>(id<RTRNode> node) {
        return [[RTRViewControllerContent alloc] initWithViewControllerClass:[PXModalViewController class]];
    }];
    
    [nodeContentProvider bindNode:deepModalNode toBlock:^id<RTRNodeContent>(id<RTRNode> node) {
        return [[RTRViewControllerContent alloc] initWithViewControllerClass:[PXDeepModalViewController class]];
    }];
    
    [nodeContentProvider bindNode:rootNode toBlock:^id<RTRNodeContent>(id<RTRNode> node) {
        return [[RTRModalPresentationContent alloc] initWithWindow:self.window];
    }];


    // Command Registry
    
    RTRCommandRegistry *commandRegistry = [[RTRCommandRegistry alloc] init];
    
    [commandRegistry bindNode:redNode toCommandClass:[PXPresentRed class]];
    [commandRegistry bindNode:greenNode toCommandClass:[PXPresentGreen class]];
    [commandRegistry bindNode:blueNode toCommandClass:[PXPresentBlue class]];
    [commandRegistry bindNode:deepModalNode toCommandClass:[PXPresentModal class]];
    [commandRegistry bindNode:anotherBlueNode toCommandClass:[PXPresentAnotherModal class]];

    
    // Router
    
    RTRRouter *router = [RTRRouter sharedInstance];
    router.rootNode = rootNode;
    router.nodeContentProvider = nodeContentProvider;
    router.commandRegistry = commandRegistry;
    
    self.router = router;
}

- (void)doSomething {
    [self.router executeCommand:[[PXPresentGreen alloc] init] animated:NO];
}

- (void)doSomethingLater {
    [self.router executeCommand:[[PXPresentAnotherModal alloc] init] animated:YES];
}

- (void)doSomethingEvenLater {
    [self.router executeCommand:[[PXPresentModal alloc] init] animated:YES];
}

- (void)doSomethingEvenMoreLater {
    [self.router executeCommand:[[PXPresentBlue alloc] init] animated:YES];
}

//- (void)doSomething {
//    [self.router executeCommand:[[PXPresentRed alloc] init] animated:NO];
//}
//
//- (void)doSomethingLater {
//    [self.router executeCommand:[[PXPresentBlue alloc] init] animated:YES];
//}
//
//- (void)doSomethingEvenLater {
//    [self.router executeCommand:[[PXPresentGreen alloc] init] animated:YES];
//}
//
//- (void)doSomethingEvenMoreLater {
//    [self.router executeCommand:[[PXPresentRed alloc] init] animated:YES];
//}

@end
