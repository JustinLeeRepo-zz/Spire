//
//  TableViewCell.h
//  Spire
//
//  Created by Justin Lee on 6/8/16.
//  Copyright © 2016 Justin Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface TableViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIView *card;
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) MKMapView *mapView;

- (void)setLabelText:(NSString *)text;
- (void)initSetImg;
- (void)initSetMap:(double)latitude withLongitude:(double)longitude;

@end
