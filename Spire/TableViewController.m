//
//  ViewController.m
//  Spire
//
//  Created by Justin Lee on 6/8/16.
//  Copyright © 2016 Justin Lee. All rights reserved.
//

#import "TableViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "Streak.h"
#import "TableViewCell.h"

@interface TableViewController ()

@end

@implementation TableViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	self.view.backgroundColor = [UIColor whiteColor];
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	self.streakSectionDictionary = [[NSMutableDictionary alloc] init];
	self.dictionaryKeyArray = [[NSMutableArray alloc] init];
	
	self.secsUTC = [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]];
	NSString *baseURL = @"http://spire-challenge.herokuapp.com/";
	NSString *streakURL = [NSString stringWithFormat:@"%@%@/%@", baseURL, @"streaks", self.secsUTC];
	NSString *imgURL = [NSString stringWithFormat:@"%@%@/%@", baseURL, @"photos", self.secsUTC];
	NSString *mapURL = [NSString stringWithFormat:@"%@%@/%@", baseURL, @"locations", self.secsUTC];
	self.endpointArray = [[NSArray alloc] initWithObjects:streakURL, imgURL, mapURL, nil];

	
	AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
	
	dispatch_group_t group = dispatch_group_create();
	
	for (int i = 0; i < 3; i++) {
		NSLog(@"yoyo");
		// Enter the group for each request we create
		dispatch_group_enter(group);
		
		// Fire the request
		[manager GET:[self.endpointArray objectAtIndex:i] parameters:nil progress:nil success:^(NSURLSessionTask *task, NSArray *responseObject){
			NSLog(@"HTTP REQUEST SUCCESS %@ count %lu", responseObject, (unsigned long)responseObject.count);
			//		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
			[self parseStreak:responseObject];
			//		});
			
			
			// Leave the group as soon as the request succeeded
			dispatch_group_leave(group);
		} failure:^(NSURLSessionTask *operation, NSError *error){
			NSLog(@"HTTP GET REQUEST FAILED %@", error);
			
			// Leave the group as soon as the request failed
			dispatch_group_leave(group);
			return;
		}];
	}
	
	// Here we wait for all the requests to finish
	dispatch_group_notify(group, dispatch_get_main_queue(), ^{
		
		self.dictionaryKeyArray = [self.streakSectionDictionary allKeys];
		NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:nil ascending:NO];
		self.dictionaryKeyArray = [self.dictionaryKeyArray sortedArrayUsingDescriptors:@[sd]];
		[self.tableView reloadData];
		
//		for (Streak *s in [self.streakSectionDictionary objectForKey:self.secsUTC]) {
//			NSLog(@"oh year %@ %@", s.arrivedAt, s.takenAt);
//		}
//		NSLog(@"oh yeah %@ count %d", [self.streakSectionDictionary objectForKey:self.secsUTC], ((NSArray *)[self.streakSectionDictionary objectForKey:self.secsUTC]).count);
		// Do whatever you need to do when all requests are finished
	});
}

#pragma mark - Data Parse

- (Streak *)inRangeOfTime:(NSNumber *)target withStreakArray:(NSArray *)streakArray{
	for (Streak *s in streakArray) {
		if (s.startAt  < target && target < s.stopAt) {
			return s;
		}
	}
	return nil;
}

- (void)parseStreak:(NSArray *)response {
	for (NSDictionary *dict in response) {
		Streak *streak = [[Streak alloc] init];
		NSMutableArray *currentDayStreak = [self.streakSectionDictionary objectForKey:[NSString stringWithFormat:@"%@", self.secsUTC]];
		
		if([dict objectForKey:@"start_at"] != nil){
			NSNumber *startAt = [NSNumber numberWithInt:[[dict objectForKey:@"start_at"] intValue]];
			NSNumber *stopAt = [NSNumber numberWithInt:[[dict objectForKey:@"stop_at"] intValue]];
			NSString *type = [dict objectForKey:@"type"];
			
			[streak initLabel:startAt withStopAt:stopAt withType:type];
			NSString *secsUTCString = [NSString stringWithFormat:@"%@", self.secsUTC];
			NSMutableArray *sectionArray = [self.streakSectionDictionary objectForKey:secsUTCString] != nil ? [self.streakSectionDictionary objectForKey:secsUTCString] : [[NSMutableArray alloc] init];
			[sectionArray addObject:streak];
			
			[self.streakSectionDictionary setObject:sectionArray forKey:secsUTCString];
		}
		else if([dict objectForKey:@"arrived_at"] != nil){
			NSNumber *arrivedAt = [NSNumber numberWithInt:[[dict objectForKey:@"arrived_at"] intValue]];
			double latitude = [[dict objectForKey:@"latitude"] doubleValue];
			double longitude = [[dict objectForKey:@"longitude"] doubleValue];
			
			//iterate through streaksectiondictionary object for key:self.secutc
			//find streak with startAt < arrivedAt && stopAt > arrivedAt
			// initimg for that streak instance
			
			Streak *s = [self inRangeOfTime:arrivedAt withStreakArray:currentDayStreak];
			if(s != nil){
				[s initCoordinates:latitude withLongitude:longitude withArrivedAt:arrivedAt];
			}
		}
		else if([dict objectForKey:@"taken_at"] != nil){
			NSNumber *takenAt = [NSNumber numberWithInt:[[dict objectForKey:@"taken_at"] intValue]];
			NSURL *url = [NSURL URLWithString:[dict objectForKey:@"url"]];
			
			Streak *s = [self inRangeOfTime:takenAt withStreakArray:currentDayStreak];
			if(s != nil) {
				[s initImg:url withTakenAt:takenAt];
			}
		}
	}
}


#pragma mark - TableView Delegate / DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return self.streakSectionDictionary.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	NSString *key = [self.dictionaryKeyArray objectAtIndex:section];
	NSLog(@"how many rows %lu", (unsigned long)((NSArray *)[self.streakSectionDictionary objectForKey:key]).count);
	return ((NSArray *)[self.streakSectionDictionary objectForKey:key]).count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	NSInteger row = [indexPath row];
	NSInteger section = [indexPath section];
	static NSString *CellIdentifier = @"StreakIdentifier";
	TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	
	if (cell == nil) {
		cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	} else {
		for (UIView *view in cell.contentView.subviews) {
			if (view.tag == 99 || view.tag == 98) {
				[view removeFromSuperview];
			}
		}
	}
	NSString *sectionDate = [self.dictionaryKeyArray objectAtIndex:section];
	NSArray *streaksPerSection = [self.streakSectionDictionary objectForKey:sectionDate];
	
	Streak *streak = [streaksPerSection  objectAtIndex:row];
	int duration = ([streak.stopAt intValue]- [streak.startAt intValue]) / 60;
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:[streak.stopAt doubleValue]];
	
	NSDateFormatter* timeUTC = [[NSDateFormatter alloc] init];
	[timeUTC setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	[timeUTC setDateFormat:@"h:mma"];
	NSString* timeString= [timeUTC stringFromDate:date];
	
	[cell setLabelText:[NSString stringWithFormat:@"%@\n%d min\n%@", streak.type, duration, timeString]];
	
	if(streak.url != nil){
		NSLog(@"OH YEAH BABY SET IMG");
		[cell initSetImg];
		[cell.imgView setImageWithURL:streak.url];
	}
	else if(streak.arrivedAt != nil){
		NSLog(@"OH NO DADDY SET MAP");
		[cell initSetMap:streak.latitude withLongitude:streak.longitude];
	}
	else{
		NSLog(@"WTF");
	}
	return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 15)];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width, 15)];
	[label setFont:[UIFont boldSystemFontOfSize:12]];
	NSString *string = [self.dictionaryKeyArray objectAtIndex:section];
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:[string doubleValue]];
	
	NSDateFormatter* timeUTC = [[NSDateFormatter alloc] init];
	[timeUTC setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	[timeUTC setDateFormat:@"MMMM d, YYYY"];
	NSString* timeString= [timeUTC stringFromDate:date];
	
	[label setText:timeString];
	[view addSubview:label];
	[view setBackgroundColor:[UIColor whiteColor]];
	
	return view;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
