//
//  ObjCViewController.h
//  ServiceProviderExample
//
//  Created by Короткий Виталий on 08.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ObjCViewController : UIViewController

@end

@protocol ServiceObjC

@end

@interface ObjCService : NSObject<ServiceObjC>

@end
