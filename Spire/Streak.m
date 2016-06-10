//
//  Streak.m
//  Spire
//
//  Created by Justin Lee on 6/8/16.
//  Copyright © 2016 Justin Lee. All rights reserved.
//

#import "Streak.h"

@interface Streak ()

@end

@implementation Streak

#pragma mark - init

- (void)initLabel:(NSNumber *)startAt withStopAt:(NSNumber *)stopAt withType:(NSString *)type{
	self.startAt = startAt;
	self.stopAt = stopAt;
	self.type = type;
}

- (void)initImg:(NSURL *)url withTakenAt:(NSNumber *)takenAt{
	self.url = url;
	self.takenAt = takenAt;
}

- (void)initCoordinates:(double)latitude withLongitude:(double)longitude withArrivedAt:(NSNumber *)arrivedAt{
	self.latitude = latitude;
	self.longitude = longitude;
	self.arrivedAt = arrivedAt;
}

@end