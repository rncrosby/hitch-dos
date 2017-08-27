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
        NSString *string = [NSString stringWithFormat:@"rideID = '%@'",_rideToOpen];
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
                        NSString *rideID = [record valueForKey:@"rideID"];
                        NSNumber *seats = [record valueForKey:@"seats"];
                        NSNumber *price = [record valueForKey:@"price"];
                        NSMutableArray *messages = [record valueForKey:@"messages"];
                        NSMutableArray *riders = [record valueForKey:@"riders"];
                        NSMutableArray *requests = [record valueForKey:@"requests"];
                        NSMutableArray *payments = [record valueForKey:@"payments"];
                        CLLocation *start = [record valueForKey:@"start"];
                        CLLocation *end = [record valueForKey:@"end"];
                        rideObject *ride = [[rideObject alloc] initWithType:start andEnd:end andDate:date andTime:time andSeats:seats andPrice:price andMessages:messages andRiders:riders andName:name andPlainStart:plainStart andPlainEnd:plainEnd andPhone:[record valueForKey:@"email"] andRequests:requests andPayments:payments andID:rideID];
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
     else {
    }
}

- (void)viewDidLoad {
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    profileLabel.text = name;
    name = [name uppercaseString];
    name = [NSString stringWithFormat:@"%c",[name characterAtIndex:0]];
    [profileButton setTitle:name forState:UIControlStateNormal];
    [References cornerRadius:profileButton radius:profileButton.frame.size.width/2];
    movement = [References screenHeight] - menuCard.frame.origin.y;
    movement = menuCard.frame.size.height - movement;
    menuShowing = false;
    menuBarLine.frame = CGRectMake(0, menuCard.frame.origin.y, [References screenWidth], 1);
    isRestrictedSearch = NO;
    //[References cardshadow:searchCard];
    [currentLocation setBackgroundColor:[UIColor clearColor]];
    [References tintUIButton:currentLocation color:[UIColor lightGrayColor]];
    [References tintUIButton:menuButton color:[UIColor blackColor]];
    [References createLine:self.view xPos:0 yPos:searchCard.frame.origin.y+searchCard.frame.size.height inFront:TRUE];
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [References tintUIButton:refreshButton color:[UIColor lightGrayColor]];
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
    ogPostRideFrame = postRide.frame;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return rides.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 130;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField.tag == 1) {
        [References tintUIButton:currentLocation color:[UIColor lightGrayColor]];
    }
    return YES;
}

-(bool)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 1) {
        if (textField.text.length > 1) {
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
                                         [References tintUIButton:currentLocation color:[UIColor lightGrayColor]];
                                         MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
                                         start = topResult;
                                         [startPoint setText:placemark.locality];
                                         [self getAllRides:YES];
                                     }
                                 }];
                                 
                             }
                         }
             ];
        } else {
            [location startUpdatingLocation];
        }
        
    } else if (textField.tag == 2) {
        if (textField.text.length > 1) {
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
                                         isRestrictedSearch = YES;
                                     }
                                 }];
                                 
                             }
                         }
             ];
        } else {
            [self getAllRides:NO];
        }
        
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
    NSArray *startArray = [ride.plainStart componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSInteger startCount = [startArray count];
    if (startCount == 1) {
        cell.from.text = [NSString stringWithFormat:@"%@",[ride.plainStart substringWithRange:NSMakeRange(0, 3)]];
    } else if (startCount == 2) {
        cell.from.text = [NSString stringWithFormat:@"%c%c",[startArray[0] characterAtIndex:0],[startArray[1] characterAtIndex:0]];
    } else if (startCount == 3) {
        cell.from.text = [NSString stringWithFormat:@"%c%c%c",[startArray[0] characterAtIndex:0],[startArray[1] characterAtIndex:0],[startArray[2] characterAtIndex:0]];
    }
    NSArray *endArray = [ride.plainEnd componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSInteger endCount = [endArray count];
    if (endCount == 1) {
        cell.to.text = [NSString stringWithFormat:@"%@",[ride.plainEnd substringWithRange:NSMakeRange(0, 3)]];
    } else if (endCount == 2) {
        cell.to.text = [NSString stringWithFormat:@"%c%c",[endArray[0] characterAtIndex:0],[endArray[1] characterAtIndex:0]];
    } else if (endCount == 3) {
        cell.to.text = [NSString stringWithFormat:@"%c%c%c",[endArray[0] characterAtIndex:0],[endArray[1] characterAtIndex:0],[endArray[2] characterAtIndex:0]];
    }
    cell.from.text = [cell.from.text uppercaseString];
    cell.to.text = [cell.to.text uppercaseString];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM"];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"d"];
    cell.month.text = [dateFormatter stringFromDate:ride.date];
    cell.date.text = [timeFormatter stringFromDate:ride.date];
    cell.month.text = [cell.month.text uppercaseString];
    [References cornerRadius:cell.whiteBack radius:9.0];
    [References cornerRadius:cell.redBack radius:9.0];
    if (indexPath.row % 2) {
        [cell.contentView setBackgroundColor:[UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1.0]];
    } else {
        [cell.contentView setBackgroundColor:[UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0]];
    }
        [cell.triptype setImage:[UIImage imageNamed:@"round-trip.png"]];
    [References cornerRadius:cell.kind radius:cell.price.frame.size.width/2];
    [References cornerRadius:cell.price radius:cell.price.frame.size.width/2];
    [References cornerRadius:cell.seats radius:cell.seats.frame.size.width/2];
    //[References borderColor:cell.price color:[References colorFromHexString:@"#1abc9c"]];
    return cell;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    if (newLocation != nil) {
        
        [manager stopUpdatingLocation];
        [[NSUserDefaults standardUserDefaults] setDouble:newLocation.coordinate.latitude forKey:@"currentLatitude"];
        [[NSUserDefaults standardUserDefaults] setDouble:newLocation.coordinate.longitude forKey:@"currentLongitude"];
        CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
        [geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            if (placemarks && placemarks.count > 0) {
                CLPlacemark *topResult = [placemarks objectAtIndex:0];
                MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
                start = placemark;
                [startPoint setText:placemark.locality];
                [self getAllRides:NO];
                [References tintUIButton:currentLocation color:[[self view] tintColor]];
            }
        }];
    }
 
}

-(void)getAllRides:(bool)isRestricted{
    noRides.text = @"Finding Rides";
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
                    noRides.text = @"No Rides Found";
                    table.hidden = YES;
                    noRides.hidden = NO;
                    refreshButton.hidden = NO;
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
                    NSMutableArray *payments = [record valueForKey:@"payments"];
                    CLLocation *start = [record valueForKey:@"start"];
                    CLLocation *end = [record valueForKey:@"end"];
                    NSString *rideID = [record valueForKey:@"rideID"];
                    rideObject *ride = [[rideObject alloc] initWithType:start andEnd:end andDate:date andTime:time andSeats:seats andPrice:price andMessages:messages andRiders:riders andName:name andPlainStart:plainStart andPlainEnd:plainEnd andPhone:[record valueForKey:@"email"] andRequests:requests andPayments:payments andID:rideID];
                    [rideRecords addObject:results[a]];
                    [rides addObject:ride];
                }
            dispatch_async(dispatch_get_main_queue(), ^(void){
                noRides.hidden = YES;
                refreshButton.hidden = YES;
                table.hidden = NO;
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
    [self getMyDrives];
    [self getAllRides:NO];
    [endPoint setText:@""];
}
- (IBAction)inbox:(id)sender {
}

- (IBAction)postDrive:(id)sender {
    feedback = [[UINotificationFeedbackGenerator alloc] init];
    [feedback prepare];
    if (canMakeDrive == NO) {
        [References fullScreenToast:@"You've already posted a ride." inView:self withSuccess:NO andClose:NO];
//        [References toastMessage:@"You've already posted a drive." andView:self andClose:NO];
        [feedback notificationOccurred:UINotificationFeedbackTypeWarning];
    } else {
            postView *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"postView"];
            [self presentViewController:viewController animated:YES completion:nil];
    }
}

- (IBAction)more:(id)sender {
    if (menuShowing == FALSE) {
        [References moveUp:postRideDestinationFrame yChange:fabs(movement)];
        [References moveUp:menuBarLine yChange:fabs(movement)];
        [References moveUp:menuCard yChange:fabs(movement)];
        [References moveUp:menuButton yChange:fabs(movement)];
        [References moveUp:profileButton yChange:fabs(movement)];
        [References moveUp:profileLabel yChange:fabs(movement)];
        [References moveUp:forYou yChange:fabs(movement)];
        [UIView animateWithDuration:.25 animations:^{
            [postRide setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            postRide.frame = CGRectMake(16, postRideDestinationFrame.frame.origin.y, postRide.frame.size.width, postRide.frame.size.height);
        }];
        [References moveUp:transactionHistory yChange:fabs(movement)];
        [References moveUp:signOut yChange:fabs(movement)];
        menuShowing = TRUE;
    } else {
        [References moveDown:postRideDestinationFrame yChange:fabs(movement)];
        [UIView animateWithDuration:.25 animations:^{
            [postRide setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
            postRide.frame = ogPostRideFrame;
        }];
        [References moveDown:menuBarLine yChange:fabs(movement)];
        [References moveDown:menuCard yChange:fabs(movement)];
        [References moveDown:menuButton yChange:fabs(movement)];
        [References moveDown:forYou yChange:fabs(movement)];
        [References moveDown:transactionHistory yChange:fabs(movement)];
        [References moveDown:signOut yChange:fabs(movement)];
        [References moveDown:profileButton yChange:fabs(movement)];
        [References moveDown:profileLabel yChange:fabs(movement)];
        
        menuShowing = FALSE;
    }
    
}

- (IBAction)refreshButton:(id)sender {
    [endPoint setText:@""];
    [self getAllRides:NO];
    [self getMyDrives];
}

- (IBAction)currentLocation:(id)sender {
    [References tintUIButton:currentLocation color:[[self view] tintColor]];
    [endPoint setText:@""];
    isRestrictedSearch = NO;
    [location startUpdatingLocation];
    [self getAllRides:NO];
}

- (IBAction)transactionHistory:(id)sender {
    historyView *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"historyView"];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)signOut:(id)sender {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"email"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"phone"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"name"];
    startView *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"startView"];
    [self presentViewController:viewController animated:YES completion:nil];
}
@end
