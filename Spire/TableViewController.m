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
#import <QuartzCore/QuartzCore.h>
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
	self.tableView.pagingEnabled = NO;
	self.currentPage = 0;
	NSTimeInterval currentDay = [[NSDate date] timeIntervalSince1970];
	NSInteger currentDayInt = currentDay;
	self.currentDayUTC = [NSNumber numberWithLong:currentDayInt];
	self.isLoading = YES;
	[self fetchNextPage:self.currentPage];
	
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
	NSString *secsUTCString = [NSString stringWithFormat:@"%@", self.secsUTC];
	NSMutableArray *currentDayStreak = [self.streakSectionDictionary objectForKey:secsUTCString] != nil ? [self.streakSectionDictionary objectForKey:secsUTCString] : [[NSMutableArray alloc] init];


	if(response.count == 0){
		//empty array for day/section with no streaks
		[self.streakSectionDictionary setObject:currentDayStreak forKey:secsUTCString];
	}
	else {
		for (NSDictionary *dict in response) {
			Streak *streak = [[Streak alloc] init];
			
			if([dict objectForKey:@"start_at"] != nil){
				NSNumber *startAt = [NSNumber numberWithInt:[[dict objectForKey:@"start_at"] intValue]];
				NSNumber *stopAt = [NSNumber numberWithInt:[[dict objectForKey:@"stop_at"] intValue]];
				NSString *type = [dict objectForKey:@"type"];
				
				[streak initLabel:startAt withStopAt:stopAt withType:type];

				[currentDayStreak addObject:streak];
				
				[self.streakSectionDictionary setObject:currentDayStreak forKey:secsUTCString];
			}
			else if([dict objectForKey:@"arrived_at"] != nil){
				NSNumber *arrivedAt = [NSNumber numberWithInt:[[dict objectForKey:@"arrived_at"] intValue]];
				double latitude = [[dict objectForKey:@"latitude"] doubleValue];
				double longitude = [[dict objectForKey:@"longitude"] doubleValue];
				
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
}

#pragma mark - Pagination

- (void)fetchNextPage:(int)pageNumber {
	self.isLoading = YES;
	int subtractDay = (60 * 60 * 24) * pageNumber;
	
	self.secsUTC = [NSNumber numberWithInt:([self.currentDayUTC intValue] - subtractDay)];
	NSString *baseURL = @"http://spire-challenge.herokuapp.com/";
	NSString *streakURL = [NSString stringWithFormat:@"%@%@/%@", baseURL, @"streaks", self.secsUTC];
	NSString *imgURL = [NSString stringWithFormat:@"%@%@/%@", baseURL, @"photos", self.secsUTC];
	NSString *mapURL = [NSString stringWithFormat:@"%@%@/%@", baseURL, @"locations", self.secsUTC];
	self.endpointArray = [[NSArray alloc] initWithObjects:streakURL, imgURL, mapURL, nil];
	
	
	AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
	
	dispatch_group_t group = dispatch_group_create();
	
	[manager GET:[self.endpointArray objectAtIndex:0] parameters:nil progress:nil success:^(NSURLSessionTask *task, NSArray *responseObject){
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
			[self parseStreak:responseObject];
		});
		for (int i = 1; i < 3; i++) {
			//Enter group for each request
			dispatch_group_enter(group);
			
			[manager GET:[self.endpointArray objectAtIndex:i] parameters:nil progress:nil success:^(NSURLSessionTask *task, NSArray *responseObject){
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
					[self parseStreak:responseObject];
				});
				
				dispatch_group_leave(group);
			} failure:^(NSURLSessionTask *operation, NSError *error){
				NSLog(@"HTTP GET REQUEST img / data FAILED %@", error);
				
				dispatch_group_leave(group);
				return;
			}];
		}
		
		//wait for all the requests to finish
		dispatch_group_notify(group, dispatch_get_main_queue(), ^{
			self.dictionaryKeyArray = [self.streakSectionDictionary allKeys];
			NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:nil ascending:NO];
			self.dictionaryKeyArray = [self.dictionaryKeyArray sortedArrayUsingDescriptors:@[sd]];
			[self.tableView reloadData];
			self.isLoading = NO;
		});
	} failure:^(NSURLSessionTask *operation, NSError *error){
		NSLog(@"HTTP GET REQUEST streak FAILED %@", error);
		
		return;
	}];
	
	
	
}

#pragma mark - TableView Delegate / DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return self.streakSectionDictionary.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	NSString *key = [self.dictionaryKeyArray objectAtIndex:section];
	return ((NSArray *)[self.streakSectionDictionary objectForKey:key]).count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 110;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 40;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	int section = [indexPath section];
	int row = [indexPath row];
	
	NSString *lastDay = [self.dictionaryKeyArray objectAtIndex:([self.dictionaryKeyArray count] - 1)];
	NSMutableArray * lastDayStreaks = [self.streakSectionDictionary objectForKey:lastDay];
	int lastSection = self.streakSectionDictionary.count - 1;
	int lastRowInLastSection = lastDayStreaks.count - 1;
	
	if (section == lastSection && row == lastRowInLastSection && !self.isLoading) {
		[self fetchNextPage:++self.currentPage];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	NSInteger row = [indexPath row];
	NSInteger section = [indexPath section];
	static NSString *CellIdentifier = @"StreakIdentifier";
	TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	
	if (cell == nil) {
		cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	} else {
		for (UIView *view in [cell.contentView.subviews objectAtIndex:0].subviews) {
			if (view.tag == 99 || view.tag == 98) {
				[view removeFromSuperview];
			}
		}
	}
	NSString *sectionDate = [self.dictionaryKeyArray objectAtIndex:section];
	NSArray *streaksPerSection = [self.streakSectionDictionary objectForKey:sectionDate];
	
	Streak *streak = [streaksPerSection  objectAtIndex:row];
	int duration = ([streak.stopAt intValue]- [streak.startAt intValue]) / 60;
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:[streak.startAt doubleValue]];
	
	NSDateFormatter* timeUTC = [[NSDateFormatter alloc] init];
	[timeUTC setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	[timeUTC setDateFormat:@"h:mma"];
	NSString* timeString= [timeUTC stringFromDate:date];
	
	[cell setLabelText:[NSString stringWithFormat:@"%@\n%d min\n%@", streak.type, duration, timeString]];
	
	if(streak.url != nil){
		[cell initSetImg];
		[cell.imgView setImageWithURL:streak.url];
	}
	else if(streak.arrivedAt != nil){
		[cell initSetMap:streak.latitude withLongitude:streak.longitude];
	}
	else{
	}
	return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
	NSString *key = [self.dictionaryKeyArray objectAtIndex:section];
	NSUInteger numberOfStreaksForSection = ((NSArray *)[self.streakSectionDictionary objectForKey:key]).count;
	
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width, view.frame.size.height)];
	[label setFont:[UIFont boldSystemFontOfSize:14]];
	NSString *utcString = [self.dictionaryKeyArray objectAtIndex:section];
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:[utcString doubleValue]];
	NSDateFormatter* timeUTC = [[NSDateFormatter alloc] init];
	[timeUTC setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	[timeUTC setDateFormat:@"MMMM d, YYYY"];
	NSString* timeString= [timeUTC stringFromDate:date];
	
	if (numberOfStreaksForSection == 0) {
		[label setText:[NSString stringWithFormat:@"No Streak for %@", timeString]];
		view.layer.borderColor = [UIColor grayColor].CGColor;
		view.layer.borderWidth = 1.0f;
	} else {
		
		UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, 35, view.frame.size.width, 1)];
		line.backgroundColor = [UIColor blackColor];
		[view addSubview:line];
		[label setText:timeString];
	}

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
