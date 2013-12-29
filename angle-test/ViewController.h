//
//  ViewController.h
//  angle-test
//
//  Created by Niels Gabel on 12/27/13.
//  Copyright (c) 2013 Niels Gabel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AngleView ;
@class HandleView ;

@interface ViewController : UIViewController
-(void)angleHandleDragged:(HandleView*)sender event:(UIEvent*)event ;
@end
