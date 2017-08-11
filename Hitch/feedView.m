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

-(void)viewDidAppear:(BOOL)animated {
    if (_rideToOpen.length > 1) {
        NSString *string = [NSString stringWithFormat:@"email = '%@'",_rideToOpen];
        CKContainer *defaultContainer = [CKContainer defaultContainer];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:string];
        CKDatabase *publicDatabase = [defaultContainer publicCloudDatabase];
        CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Rides" predicate:predicate];
        [publicDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
            if (!error) {
                if (results.count > 0) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        
                        CKRecord *record = results[0];
                        
                        NSDate *date = [record valueForKey:@"date"];
                        NSDate *time = [record valueForKey:@"time"];
                        NSString *name = [record valueForKey:@"name"];
                        NSString *plainStart = [record valueForKey:@"plainStart"];
                        NSString *plainEnd = [record valueForKey:@"plainEnd"];
                        NSNumber *seats = [record valueForKey:@"seats"];
                        NSNumber *price = [record valueForKey:@"price"];
                        NSMutableArray *messages = [record valueForKey:@"messages"];
                        NSMutableArray *riders = [record valueForKey:@"riders"];
                        NSMutableArray *requests = [record valueForKey:@"requests"];
                        CLLocation *start = [record valueForKey:@"start"];
                        CLLocation *end = [record valueForKey:@"end"];
                        rideObject *ride = [[rideObject alloc] initWithType:start andEnd:end andDate:date andTime:time andSeats:seats andPrice:price andMessages:messages andRiders:riders andName:name andPlainStart:plainStart andPlainEnd:plainEnd andPhone:[record valueForKey:@"email"] andRequests:requests];
                        rideView *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"rideView"];
                        viewController.ride = ride;
                        viewController.rideRecord = record;
                        _rideToOpen = @"";
                        [self presentViewController:viewController animated:YES completion:nil];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        NSLog(@"error");
                    });
                }
            } else {
                NSLog(@"%@",error.localizedDescription);
            }
        }];
    }
}

- (void)viewDidLoad {
    //[References cardshadow:searchCard];
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
    [self getMyDrives];
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
    if (textField.tag == 1) {
        // zip start
    } else if (textField.tag == 2) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:textField.text
                     completionHandler:^(NSArray* placemarks, NSError* error){
                         if (placemarks && placemarks.count > 0) {
                             CLPlacemark *topResult = [placemarks objectAtIndex:0];
                             MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
                             
                             CLLocation *location = [[CLLocation alloc] initWithLatitude:placemark.coordinate.latitude longitude:placemark.coordinate.longitude];
                             CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
                             [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                                 if (placemarks && placemarks.count > 0) {
                                     CLPlacemark *topResult = [placemarks objectAtIndex:0];
                                     
                                     MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
                                     end = topResult;
                                     [endPoint setText:placemark.locality];
                                     [self getAllRides:YES];
                                 }
                             }];
                             
                         }
                     }
         ];
    }
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
    cell.seats.text = [NSString stringWithFormat:@"%i",ride.seats.intValue];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, MMMM d"];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"h a"];
    cell.date.text = [NSString stringWithFormat:@"%@ around %@",[dateFormatter stringFromDate:ride.date],[timeFormatter stringFromDate:ride.date]];
    [References tintUIButton:cell.chevron color:[[self view] tintColor]];
    cell.backgroundColor = [UIColor clearColor];
    [References cardshadow:cell.shadow];
    [References cornerRadius:cell.card radius:8.0f];
    return cell;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    if (newLocation != nil) {
        
        [manager stopUpdatingLocation];
        [[NSUserDefaults standardUserDefaults] setDouble:newLocation.coordinate.latitude forKey:@"currentLatitude"];
        [[NSUserDefaults standardUserDefaults] setDouble:newLocation.coordinate.longitude forKey:@"currentLongitude"];
        [self getAllRides:NO];
        CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
        [geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            if (placemarks && placemarks.count > 0) {
                CLPlacemark *topResult = [placemarks objectAtIndex:0];
                MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
                start = placemark;
                [startPoint setText:placemark.locality];
                [self getAllRides:NO];
            }
        }];
    }
 
}

-(void)getAllRides:(bool)isRestricted{
    rides = [[NSMutableArray alloc] init];
    rideRecords = [[NSMutableArray alloc] init];
    NSString *string = @"";
    if (isRestricted == YES) {
        int lowerZip = start.postalCode.intValue-45;
        int upperZip = start.postalCode.intValue+45;
        int upperEndZip = end.postalCode.intValue+45;
        int lowerEndZip = end.postalCode.intValue-45;
        string = [NSString stringWithFormat:@"zipStart < %i AND zipStart > %i AND zipEnd < %i AND zipEnd > %i AND seats > 0",upperZip,lowerZip,upperEndZip,lowerEndZip];
    } else {
        int lowerZip = start.postalCode.intValue-45;
        int upperZip = start.postalCode.intValue+45;
        string = [NSString stringWithFormat:@"zipStart < %i AND zipStart > %i AND seats > 0",upperZip,lowerZip];
    }
    CKContainer *defaultContainer = [CKContainer defaultContainer];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:string];
    CKDatabase *publicDatabase = [defaultContainer publicCloudDatabase];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Rides" predicate:predicate];
    [publicDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (!error) {
            if (results.count == 0) {
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    noRides.hidden = NO;
                    [refreshControl endRefreshing];
                });
            } else {
                
            [rides removeAllObjects];
            [rideRecords removeAllObjects];
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
                    NSMutableArray *requests = [record valueForKey:@"requests"];
                    CLLocation *start = [record valueForKey:@"start"];
                    CLLocation *end = [record valueForKey:@"end"];
                    rideObject *ride = [[rideObject alloc] initWithType:start andEnd:end andDate:date andTime:time andSeats:seats andPrice:price andMessages:messages andRiders:riders andName:name andPlainStart:plainStart andPlainEnd:plainEnd andPhone:[record valueForKey:@"email"] andRequests:requests];
                    [rideRecords addObject:results[a]];
                    [rides addObject:ride];
                }
            dispatch_async(dispatch_get_main_queue(), ^(void){
                noRides.hidden = YES;
                [table reloadData];
                [refreshControl endRefreshing];
            });
        }
        } else {
            NSLog(@"%@",error.localizedDescription);
        }
    }];
}

-(void)getMyDrives {
        NSString *string = [NSString stringWithFormat:@"email = '%@'",[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]];
        CKContainer *defaultContainer = [CKContainer defaultContainer];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:string];
        CKDatabase *publicDatabase = [defaultContainer publicCloudDatabase];
        CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Rides" predicate:predicate];
        [publicDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
            if (!error) {
                if (results.count > 0) {
                    canMakeDrive = NO;
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        canMakeDrive = YES;
                        
                    });
                }
            } else {
                NSLog(@"%@",error.localizedDescription);
            }
        }];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectionFeedback = [[UISelectionFeedbackGenerator alloc] init];
    [selectionFeedback prepare];
    [selectionFeedback selectionChanged];
    dispatch_async(dispatch_get_main_queue(), ^(void){
        rideView *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"rideView"];
        viewController.ride = rides[indexPath.row];
        viewController.rideRecord = rideRecords[indexPath.row];
        [self presentViewController:viewController animated:YES completion:nil];
    });
    
}

-(void)refreshData
{
    [self getAllRides:NO];
    [endPoint setText:@""];
}
- (IBAction)inbox:(id)sender {
}

- (IBAction)postDrive:(id)sender {
    feedback = [[UINotificationFeedbackGenerator alloc] init];
    [feedback prepare];
    if (canMakeDrive == NO) {
        [References toastMessage:@"You've already posted a drive." andView:self andClose:NO];
        [feedback notificationOccurred:UINotificationFeedbackTypeWarning];
    } else {
            postView *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"postView"];
            [self presentViewController:viewController animated:YES completion:nil];
    }
}

- (IBAction)more:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"More" message:@"Note: This page will be updated" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Sign Out" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:^() {
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"email"];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"name"];
        }];
    }]];
    
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}
@end
