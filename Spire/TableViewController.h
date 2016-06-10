//
//  ViewController.h
//  Spire
//
//  Created by Justin Lee on 6/8/16.
//  Copyright © 2016 Justin Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *endpointArray;
@property (strong, nonatomic) NSArray *functionArray;
@property (strong, nonatomic) NSNumber *secsUTC;
@property (strong, nonatomic) NSMutableArray *dictionaryKeyArray;
@property (strong, nonatomic) NSMutableDictionary *streakSectionDictionary;
@property (assign, nonatomic) BOOL isLoading;
@property (assign, nonatomic) int currentPage;
@property (strong, nonatomic) NSNumber *currentDayUTC;


@end