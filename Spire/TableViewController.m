//
//  ViewController.m
//  Spire
//
//  Created by Justin Lee on 6/8/16.
//  Copyright © 2016 Justin Lee. All rights reserved.
//

#import "TableViewController.h"
#import <AFNetworking.h>

@interface TableViewController ()

@end

@implementation TableViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	self.view.backgroundColor = [UIColor redColor];
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	
//	NSDate *currentDate = [[NSDate alloc] init];
	int secsUtc1970 = [[NSDate date] timeIntervalSince1970];
	NSString *baseURL = @"http://spire-challenge.herokuapp.com/";
	
	NSString *url = [NSString stringWithFormat:@"%@%@/%d", baseURL, @"streaks",secsUtc1970];
	
	AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
	[manager GET:url parameters:nil progress:nil success:^(NSURLSessionTask *task, NSArray *responseObject){
				NSLog(@"HTTP REQUEST SUCCESS %@", responseObject);
//		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
//			[self parseData:(NSDictionary *)responseObject];
//		});
	} failure:^(NSURLSessionTask *operation, NSError *error){
		NSLog(@"HTTP GET REQUEST FAILED %@", error);
		return;
	}];
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
