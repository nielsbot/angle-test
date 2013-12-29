//
//  AngleView.h
//  angle-test
//
//  Created by Niels Gabel on 12/27/13.
//  Copyright (c) 2013 Niels Gabel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HandleView.h"

struct AnglePoints {
	CGPoint p[3] ;
};

CGRect CGRectMakeWithAnglePoints( struct AnglePoints p ) ;

@interface AngleView : UIControl
@property ( nonatomic ) struct AnglePoints points ;
@property ( nonatomic, readonly ) CAShapeLayer * shapeLayer ;
@end

@interface HandleView (AngleView)
@property ( nonatomic ) NSUInteger pointIndex ;
@end

