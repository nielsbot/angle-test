//
//  ViewController.m
//  angle-test
//
//  Created by Niels Gabel on 12/27/13.
//  Copyright (c) 2013 Niels Gabel. All rights reserved.
//

#import "ViewController.h"
#import "AngleVIew.h"
#import "View.h"
#import "HandleView.h"

#pragma mark - HandleView (ViewController)

@implementation HandleView (ViewController)

-(AngleView*)enclosingAngleView
{
	UIView * view = self ;
	while(( view = [ view superview ] ))
	{
		if ( [ view isKindOfClass:[ AngleView class ] ] )
		{
			return (AngleView*)view ;
		}
	}
	return nil ;
}

@end

@interface ViewController ()
{
	struct AnglePoints _tapPoints ;
}
@property ( nonatomic ) NSUInteger tapCount ;
@property ( nonatomic, strong ) NSMutableSet * angleViews ;
@end

#pragma mark - ViewController

@implementation ViewController

-(AngleView*)_addAngleViewForPoints:(struct AnglePoints)p
{
	CGRect frame = CGRectMakeWithAnglePoints( p ) ;
	AngleView * view = [[ AngleView alloc ] initWithFrame:frame ] ;
	[ view addTarget:nil action:@selector( angleViewTapped:event: ) forControlEvents:UIControlEventTouchDown ] ;
	
	[ self.view addSubview:view ] ;
	
	struct AnglePoints p2 = {
		.p = {
			[ self.view convertPoint:p.p[0] toView:view ]
			, [ self.view convertPoint:p.p[1] toView:view ]
			, [ self.view convertPoint:p.p[2] toView:view ]
		}
	} ;
	
	view.points = p2 ;
	
	[ self.angleViews addObject:view ] ;
	
	return view ;
}

-(void)selectAngleView:(AngleView*)view
{
	[ self.angleViews setValue:@(NO) forKey:@"selected" ] ;
	view.selected = YES ;
}

-(void)angleViewTapped:(id)sender event:(UIEvent*)e
{
	if ( self.tapCount == 0 )
	{
		[ self selectAngleView:sender ] ;
	}
	else
	{
		[ self canvasViewTapped:sender event:e ] ;
	}
}

-(void)canvasViewTapped:(id)sender event:(UIEvent*)e
{
	BOOL haveSelection = NO ;
	for( AngleView * view in self.angleViews )
	{
		haveSelection = haveSelection | view.selected ;
		view.selected = NO ;
	}
	
	if ( !haveSelection )
	{
		_tapPoints.p[ self.tapCount ] = [ [ [ e allTouches ] anyObject ] locationInView:self.view ] ;
		
		self.tapCount = self.tapCount + 1 ;
		
		if ( self.tapCount == 3 )
		{
			AngleView * newView = [ self _addAngleViewForPoints:_tapPoints ] ;
			[ self selectAngleView:newView ] ;
			self.tapCount = 0 ;
		}
	}
}

-(void)angleHandleDragged:(HandleView*)sender event:(UIEvent*)event
{
	CGPoint p0 = [ [ [ event allTouches ] anyObject ] previousLocationInView:nil ] ;
	CGPoint p = [ [ [ event allTouches ] anyObject ] locationInView:nil ] ;
	
	CGFloat dx = p.x - p0.x ;
	CGFloat dy = p.y - p0.y ;
	
	CGPoint c = ({ CGPoint point = sender.center; point.x += dx; point.y += dy; point ; }) ;
	sender.center = c ;
	
	AngleView * angleView = [ sender enclosingAngleView ] ;

	{
		struct AnglePoints points = [ angleView points ] ;
		points.p[ sender.pointIndex ] = c ;
		[ angleView setPoints:points ] ;
	}
}

-(NSMutableSet *)angleViews
{
	if ( !_angleViews ) { _angleViews = [ NSMutableSet set ] ; }
	return _angleViews ;
}

-(void)viewDidLoad
{
	[ super viewDidLoad ] ;
	[ (UIControl*)self.view addTarget:nil action:@selector( canvasViewTapped:event: ) forControlEvents:UIControlEventTouchUpInside ] ;
}

@end
