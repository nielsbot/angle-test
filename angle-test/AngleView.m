//
//  AngleView.m
//  angle-test
//
//  Created by Niels Gabel on 12/27/13.
//  Copyright (c) 2013 Niels Gabel. All rights reserved.
//

#import "AngleView.h"
#import "HandleView.h"
#import "ViewController.h"

#import <objc/runtime.h>

CGRect CGRectMakeWithAnglePoints( struct AnglePoints p )
{
	CGFloat minX = MIN( MIN( p.p[0].x, p.p[1].x ), p.p[2].x ) ;
	CGFloat maxX = MAX( MAX( p.p[0].x, p.p[1].x ), p.p[2].x ) ;
	CGFloat minY = MIN( MIN( p.p[0].y, p.p[1].y ), p.p[2].y ) ;
	CGFloat maxY = MAX( MAX( p.p[0].y, p.p[1].y ), p.p[2].y ) ;
	
	return (CGRect){ { minX, minY }, { maxX - minX, maxY - minY } } ;
}

#pragma mark - HandleView (AngleView)
@implementation HandleView (AngleView)

static const char * kPointIndexKey = "kPointIndexKey" ;

-(void)setPointIndex:(NSUInteger)pointIndex
{
	objc_setAssociatedObject( self, kPointIndexKey, @(pointIndex), OBJC_ASSOCIATION_RETAIN_NONATOMIC ) ;
}

-(NSUInteger)pointIndex
{
	return [ objc_getAssociatedObject( self, kPointIndexKey ) unsignedIntegerValue ] ;
}

@end

#pragma mark - AngleView ()
@interface AngleView ()
@property ( nonatomic, readonly ) NSArray * handleViews ;
@property ( nonatomic, readonly ) CAShapeLayer * selectionShapeLayer ;
@property ( nonatomic, readonly ) CGPathRef hitTestPath ;
@property ( nonatomic, readonly ) CGPathRef anglePath ;
@end

#pragma mark - AngleView

@implementation AngleView
@synthesize shapeLayer = _shapeLayer ;
@synthesize handleViews = _handleViews ;
@synthesize selectionShapeLayer = _selectionShapeLayer ;
@synthesize anglePath = _anglePath ;
@synthesize hitTestPath = _hitTestPath ;

-(CGPathRef)anglePath
{
	if ( !_anglePath )
	{
		struct AnglePoints p = self.points ;
		CGMutablePathRef path = CGPathCreateMutable() ;
		CGPathMoveToPoint( path, NULL, p.p[0].x, p.p[0].y ) ;
		CGPathAddLineToPoint( path, NULL, p.p[1].x, p.p[1].y ) ;
		CGPathAddLineToPoint( path, NULL, p.p[2].x, p.p[2].y ) ;

		_anglePath = path ;
	}

	return _anglePath ;
}

-(void)setPoints:(struct AnglePoints)p
{
	_points = p ;
	
	CGPathRelease( _anglePath ); _anglePath = NULL ;
	CGPathRelease( _hitTestPath ) ; _hitTestPath = NULL ;
	
	self.shapeLayer.path = self.anglePath ;
	self.selectionShapeLayer.path = self.hitTestPath ;
}

-(void)layoutSubviews
{
	[ super layoutSubviews ] ;
	
	struct AnglePoints p = self.points ;
	__unsafe_unretained UIView * handleViews[3]  ;
	[ self.handleViews getObjects:handleViews ] ;
	
	handleViews[0].center = p.p[0] ;
	handleViews[1].center = p.p[1] ;
	handleViews[2].center = p.p[2] ;
}

-(CAShapeLayer *)shapeLayer
{
	if ( !_shapeLayer )
	{
		CAShapeLayer * layer = [ CAShapeLayer layer ] ;
		layer.strokeColor = [[ UIColor darkGrayColor ] CGColor ] ;
		layer.lineWidth = 2.0 ;
		layer.fillColor = 0 ;
		layer.path = self.anglePath ;
		layer.lineJoin = @"bevel" ;
		[ self.layer addSublayer:layer ] ;
		
		_shapeLayer = layer ;
	}
	
	return _shapeLayer ;
}

-(CAShapeLayer *)selectionShapeLayer
{
	if ( !_selectionShapeLayer )
	{
		CAShapeLayer * layer = [ CAShapeLayer layer ] ;
		layer.fillColor = [[[ UIColor blueColor ] colorWithAlphaComponent:0.1 ] CGColor ] ;
		
		layer.path = self.hitTestPath ;
		[ self.layer addSublayer:layer ] ;
		
		_selectionShapeLayer = layer ;
	}
	
	return _selectionShapeLayer ;
}

-(UIView *)hitTest:(CGPoint)p withEvent:(UIEvent *)e
{
	UIView * subview = nil ;
	for( UIView * view in self.subviews )
	{
		CGPoint subviewPoint = [ self convertPoint:p toView:view ] ;
		if ( [ view hitTest:subviewPoint withEvent:e ] )
		{
			subview = view ;
			break ;
		}
	}
	
	if ( !subview )
	{
		CGPathRef path = self.hitTestPath ;
		if ( CGPathContainsPoint( path, NULL, p, false ) )
		{
			NSLog(@"YES\n") ;
			subview = self ;
		}
	}
	
	return subview ;
}

-(void)setSelected:(BOOL)b
{
	[ super setSelected:b ] ;
	
	[self.handleViews setValue:@(!b) forKey:@"hidden"] ;
	self.selectionShapeLayer.hidden = !b ;
}

-(NSArray *)handleViews
{
	if ( !_handleViews )
	{
		NSMutableArray * array = [ NSMutableArray arrayWithCapacity:3 ] ;
		for( int index=0; index < 3; ++index )
		{
			HandleView * v =  [[ HandleView alloc ] init ] ;
			v.bounds = (CGRect){ .size = { 50, 50 } } ;
			v.pointIndex = index ;
			
			[ v addTarget:nil action:@selector( angleHandleDragged:event: ) forControlEvents:UIControlEventTouchDragInside ] ;
			
			[ self addSubview:v ] ;
			
			[ array addObject:v ] ;
		}
		
		_handleViews = array ;
	}
	return _handleViews ;
}

-(CGPathRef)hitTestPath
{
	if ( !_hitTestPath )
	{
		_hitTestPath = CGPathCreateCopyByStrokingPath( self.anglePath, NULL, 15.0, kCGLineCapRound, kCGLineJoinRound, 0.0 ) ;
	}
	return _hitTestPath ;
}
@end
