//
//  Streak.h
//  Spire
//
//  Created by Justin Lee on 6/8/16.
//  Copyright © 2016 Justin Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface Streak : NSObject

@property (strong, nonatomic) NSNumber *startAt;
@property (strong, nonatomic) NSNumber *stopAt;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSNumber *takenAt;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSNumber *arrivedAt;
@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) double longitude;

- (void)initLabel:(NSNumber *)startAt withStopAt:(NSNumber *)stopAt withType:(NSString *)type;;
- (void)initImg:(NSURL *)url withTakenAt:(NSNumber *)takenAt;
- (void)initCoordinates:(double)latitude withLongitude:(double)longitude withArrivedAt:(NSNumber *)arrivedAt;

@end