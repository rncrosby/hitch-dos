//
//  feedView.m
//  Hitch
//
//  Created by Robert Crosby on 8/6/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "feedView.h"

@interface feedView ()

@end

@implementation feedView

- (void)viewDidLoad {
    [References cardshadow:searchCard];
    [References createLine:self.view xPos:0 yPos:searchCard.frame.origin.y+searchCard.frame.size.height inFront:TRUE];
    [References createLine:self.view xPos:0 yPos:menuCard.frame.origin.y inFront:TRUE];
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    table.refreshControl = refreshControl;
    [super viewDidLoad];
    location = [[CLLocationManager alloc] init];
    location.delegate = self;
    location.distanceFilter = kCLDistanceFilterNone;
    location.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [location requestWhenInUseAuthorization];
    }
    [location startUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return rides.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 155;
}

-(bool)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"feedCell";
    
    feedCell *cell = (feedCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"feedCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    rideObject *ride = rides[indexPath.row];
    cell.from.text = ride.plainStart;
    cell.to.text = ride.plainEnd;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, MMMM d"];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"h a"];
    cell.date.text = [NSString stringWithFormat:@"%@ around %@",[dateFormatter stringFromDate:ride.date],[timeFormatter stringFromDate:ride.date]];
    [References tintUIButton:cell.chevron color:[UIColor darkGrayColor]];
    cell.backgroundColor = [UIColor clearColor];
    [References cardshadow:cell.shadow];
    [References cornerRadius:cell.card radius:8.0f];
    return cell;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    if (newLocation != nil) {
        [[NSUserDefaults standardUserDefaults] setDouble:newLocation.coordinate.latitude forKey:@"currentLatitude"];
        [[NSUserDefaults standardUserDefaults] setDouble:newLocation.coordinate.longitude forKey:@"currentLongitude"];
        [self getAllRides];
        [manager stopUpdatingLocation];
    }
 
}

-(void)getAllRides {
    [rides removeAllObjects];
    rides = [[NSMutableArray alloc] init];
    [rideRecords removeAllObjects];
    rideRecords = [[NSMutableArray alloc] init];
    NSString *string = @"TRUEPREDICATE";
    CKContainer *defaultContainer = [CKContainer defaultContainer];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:string];
    CKDatabase *publicDatabase = [defaultContainer publicCloudDatabase];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Rides" predicate:predicate];
    [publicDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (!error) {
                for (int a = 0; a < results.count; a++) {
                    CKRecord *record = results[a];
                    NSDate *date = [record valueForKey:@"date"];
                    NSDate *time = [record valueForKey:@"time"];
                    NSString *name = [record valueForKey:@"name"];
                    NSString *plainStart = [record valueForKey:@"plainStart"];
                    NSString *plainEnd = [record valueForKey:@"plainEnd"];
                    NSNumber *seats = [record valueForKey:@"seats"];
                    NSNumber *price = [record valueForKey:@"price"];
                    NSMutableArray *messages = [record valueForKey:@"messages"];
                    NSMutableArray *riders = [record valueForKey:@"riders"];
                    CLLocation *start = [record valueForKey:@"start"];
                    CLLocation *end = [record valueForKey:@"end"];
                    rideObject *ride = [[rideObject alloc] initWithType:start andEnd:end andDate:date andTime:time andSeats:seats andPrice:price andMessages:messages andRiders:riders andName:name andPlainStart:plainStart andPlainEnd:plainEnd];
                    [rideRecords addObject:results[a]];
                    [rides addObject:ride];
                }
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [table reloadData];
                    [refreshControl endRefreshing];
            });
        } else {
            NSLog(@"%@",error.localizedDescription);
        }
    }];
}

-(void)refreshData
{
    [self getAllRides];
}
@end
