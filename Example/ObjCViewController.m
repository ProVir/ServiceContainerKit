//
//  ObjCViewController.m
//  ServiceProviderExample
//
//  Created by Короткий Виталий on 08.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

#import "ObjCViewController.h"
@import ServiceContainerKit;

#import "Example-Swift.h"

@interface ObjCViewController ()

@property (nonatomic, readonly) ServiceContainer* serviceContainer;

@end

@implementation ObjCViewController

- (void) setupWithContainer:(id)container {
    _serviceContainer = container;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}


@end

