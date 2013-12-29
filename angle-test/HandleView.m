//
//  HandleView.m
//  angle-test
//
//  Created by Niels Gabel on 12/27/13.
//  Copyright (c) 2013 Niels Gabel. All rights reserved.
//

#import "HandleView.h"

@interface HandleView ()
@property ( nonatomic, readonly ) CAShapeLayer * shapeLayer ;
@end

@implementation HandleView
@synthesize shapeLayer = _shapeLayer ;

-(void)layoutSubviews
{
	self.shapeLayer.path = CGPathCreateWithEllipseInRect( self.bounds, NULL ) ;
}

-(CAShapeLayer *)shapeLayer
{
	if ( !_shapeLayer )
	{
		CAShapeLayer * layer = [ CAShapeLayer layer  ] ;
		layer.fillColor = [[[ UIColor blueColor ] colorWithAlphaComponent:0.1 ] CGColor ] ;
		
		[ self.layer addSublayer:layer ] ;
		
		_shapeLayer = layer ;
	}
	
	return _shapeLayer ;
}

@end
