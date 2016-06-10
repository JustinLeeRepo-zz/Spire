//
//  TableViewCell.m
//  Spire
//
//  Created by Justin Lee on 6/8/16.
//  Copyright © 2016 Justin Lee. All rights reserved.
//

#import "TableViewCell.h"

@interface TableViewCell()

@end

@implementation TableViewCell


#pragma mark - init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
	
	if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
		[self setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 100)];
		
		self.backgroundColor = [UIColor lightGrayColor];
		
		self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width / 2, self.frame.size.height)];
		[self.label setFont:[UIFont systemFontOfSize:17]];
		[self.label setTextColor:[UIColor blackColor]];
		[self.label setTextAlignment:NSTextAlignmentCenter];
		[self.label setNumberOfLines:3];
		
//		self.view = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2, 0, self.frame.size.width / 2, self.frame.size.height)];
		
//		self.imgView = [[UIImageView alloc] init];
//		self.mapView = [[MKMapView alloc] init];
		
		[self.contentView addSubview:self.label];
//		[self addSubview:self.view];
	}
	
	return self;
}

#pragma mark - Set Values

- (void)setLabelText:(NSString *)text {
	self.label.text = text;
}

- (void)initSetImg{
	self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2, 0, self.frame.size.width / 2, self.frame.size.height)];
	self.imgView.tag = 99;
	[self.contentView addSubview:self.imgView];
}

- (void)initSetMap:(double)latitude withLongitude:(double)longitude {
	self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2, 0, self.frame.size.width / 2, self.frame.size.height)];
	self.mapView.tag = 98;
	CLLocationCoordinate2D mapCenter;
	mapCenter.latitude = latitude;
	mapCenter.longitude = longitude;
	
	MKCoordinateRegion region;
	region.center.latitude = mapCenter.latitude;
	region.center.longitude = mapCenter.longitude;
	region.span.latitudeDelta = .002;
	region.span.longitudeDelta = .002;
	
	[self.mapView setRegion:region animated:NO];
	[self.contentView addSubview:self.mapView];
}

@end
