//
//  View.m
//  angle-test
//
//  Created by Niels Gabel on 12/27/13.
//  Copyright (c) 2013 Niels Gabel. All rights reserved.
//

#import "Utils.h"
#import "View.h"
#import "AngleView.h"
#import "ViewController.h"

@interface View ()
@end

@implementation View

-(UIView *)hitTest:(CGPoint)p withEvent:(UIEvent *)e
{
	UIView * subview = [ super hitTest:p withEvent:e ] ;
	return subview ;
}

@end
