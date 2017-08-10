//
//  rideView.m
//  Hitch
//
//  Created by Robert Crosby on 8/7/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "rideView.h"

@interface rideView ()

@end

@implementation rideView

- (void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messageDidStart:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [References ViewToLine:line withView:scroll xPos:0 yPos:ridePanelMessage.frame.origin.y];
    [References createLine:self.view xPos:0 yPos:menuBar.frame.origin.y+menuBar.frame.size.height inFront:TRUE];
    [scroll addSubview:line];
    [scroll bringSubviewToFront:line];
    [self IsMyDrive];
    [self isRidePending];
    [self isRideConfirmed];
    from.text = _ride.plainStart;
    to.text = _ride.plainEnd;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, MMMM d"];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"h a"];
    date.text = [NSString stringWithFormat:@"%@ around %@",[dateFormatter stringFromDate:_ride.date],[timeFormatter stringFromDate:_ride.date]];
    [References cardshadow:cardShadow];
    [References cornerRadius:card radius:8.0f];
    [References cardshadow:mapShadow];
    [References cornerRadius:map radius:8.0f];
    [References cardshadow:contactShadow];
    [References cornerRadius:contactCard radius:8.0f];
    [References cardshadow:ridePanelShadow];
    [References cornerRadius:ridePanel radius:8.0f];
    [References cornerRadius:contactImage radius:contactImage.frame.size.width/2];
    [contactImage setImage:[UIImage imageNamed:@"user.jpg"]];
    if (_ride.price.intValue > 0) {
        price.text = [NSString stringWithFormat:@"$%i",_ride.price.intValue];
    } else {
        price.text = @"Free";
    }
    [References cornerRadius:price radius:8.0f];
    [References cardshadow:priceShadow];
    [self loadMap];
    contactName.text = _ride.name;
    seats.text = [NSString stringWithFormat:@"%i",_ride.seats.intValue];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendMessage:(id)sender {
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"email"] isEqualToString:_ride.phone]) {
        [References toastMessage:@"You can't contact your self" andView:self];
    } else {
        [References toastMessage:@"Soon" andView:self];
    }
    
}

- (IBAction)showMessages:(id)sender {
    ridePanelSendMessage.enabled = YES;
    ridePanelMessageField.enabled = YES;
    if (_ride.messages.count == 0) {
        rideTable.hidden = YES;
        noRiders.hidden = NO;
        noRiders.text = @"No Messages";
    } else {
        rideTable.hidden = NO;
        noRiders.hidden = YES;
        noRiders.text = @"No Messages";
    }
    [ridersButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [messagesButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
     [rideTable reloadData];
}

- (IBAction)showRiders:(id)sender {
    if (_ride.riders.count == 0) {
        rideTable.hidden = YES;
        noRiders.hidden = NO;
        noRiders.text = @"No Riders";
    } else {
        rideTable.hidden = NO;
        noRiders.hidden = YES;
        noRiders.text = @"No Riders";
    }
    ridePanelSendMessage.enabled = NO;
    ridePanelMessageField.enabled = NO;
    [ridersButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [messagesButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
     [rideTable reloadData];
}

- (IBAction)messageDidStart:(NSNotification*)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    if (keyboard.size.height < 1) {
        keyboard = [keyboardFrameBegin CGRectValue];
    }
    int height = keyboard.size.height;
    if (ridePanelMessage.frame.origin.y> scroll.contentSize.height-50) {
        [References moveUp:ridePanelMessage yChange:height-1];
        [References moveUp:ridePanelMessageField yChange:height-1];
        [References moveUp:ridePanelSendMessage yChange:height-1];
        [References moveUp:line yChange:height-1];
        [References fadeColor:ridePanelMessage color:[References colorFromHexString:@"#D2D5DC"]];
    }
}

- (IBAction)sendGroupMessage:(id)sender {
    if (ridePanelMessageField.text.length > 0) {
        messages = [[NSMutableArray alloc] initWithArray:[_rideRecord objectForKey:@"messages"]];
        [messages addObject:[NSString stringWithFormat:@"%@^&^%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"name"],ridePanelMessageField.text]];
        _rideRecord[@"messages"] = messages;
        CKModifyRecordsOperation *modifyRecords= [[CKModifyRecordsOperation alloc]
                                                  initWithRecordsToSave:[[NSArray alloc] initWithObjects:_rideRecord, nil] recordIDsToDelete:nil];
        modifyRecords.savePolicy=CKRecordSaveAllKeys;
        modifyRecords.qualityOfService=NSQualityOfServiceUserInitiated;
        modifyRecords.modifyRecordsCompletionBlock=
        ^(NSArray * savedRecords, NSArray * deletedRecordIDs, NSError * operationError){
            //   the completion block code here
            dispatch_async(dispatch_get_main_queue(), ^(void){
                CKRecord *record = savedRecords[0];
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
                _rideRecord = record;
                _ride = ride;
                [rideTable reloadData];
                [ridePanelMessageField setText:@""];
            });
        };
        CKContainer *defaultContainer = [CKContainer defaultContainer];
        [[defaultContainer publicCloudDatabase] addOperation:modifyRecords];
    }
    
}

- (IBAction)showKeyboard:(id)sender {
    int height = keyboard.size.height;
    if (ridePanelMessage.frame.origin.y> scroll.contentSize.height-50) {
        [References moveUp:ridePanelMessage yChange:height-1];
        [References moveUp:ridePanelMessageField yChange:height-1];
        [References moveUp:ridePanelSendMessage yChange:height-1];
        [References moveUp:line yChange:height-1];
        [References fadeColor:ridePanelMessage color:[References colorFromHexString:@"#D2D5DC"]];
    }
}

-(bool)textFieldShouldReturn:(UITextField *)textField {
    int height = keyboard.size.height;
    if (ridePanelMessage.frame.origin.y< scroll.contentSize.height-50) {
        [References moveDown:ridePanelMessage yChange:height-1];
        [References moveDown:line yChange:height-1];
        [References moveDown:ridePanelMessageField yChange:height-1];
        [References moveDown:ridePanelSendMessage yChange:height-1];
        [References fadeColor:ridePanelMessage color:[UIColor whiteColor]];
        
    }
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)loadMap {
    MKCoordinateRegion region = map.region;
    region.span.longitudeDelta /= 8.0;
    region.span.latitudeDelta /= 8.0;
    
    [map setRegion:region animated:YES];
    MKPointAnnotation *start = [[MKPointAnnotation alloc] init];
    start.coordinate = _ride.start.coordinate;
    [start setTitle:_ride.plainStart];
    MKPointAnnotation *end = [[MKPointAnnotation alloc] init];
    [end setTitle:_ride.plainEnd];
    end.coordinate = _ride.end.coordinate;
    [map addAnnotation:start];
    [map addAnnotation:end];
    [self zoomToFitMapAnnotations:map];
}

-(void)zoomToFitMapAnnotations:(MKMapView*)mapView
{
    if([mapView.annotations count] == 0)
        return;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(CLLocation* annotation in mapView.annotations)
    {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 2.1; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 2.1; // Add a little extra space on the sides
    
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
}

- (IBAction)requestRide:(id)sender {
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"email"] isEqualToString:_ride.phone]) {
        if (scroll.contentOffset.y == 0) {
            [References fadeButtonText:requestRide text:@"See Drive Info"];
            [scroll setContentOffset:CGPointMake(0, scroll.contentSize.height/2) animated:YES];
            [References moveDown:requestRide yChange:50];
        } else {
            [References fadeButtonText:requestRide text:@"See Your Drive Messages"];
            [References moveUp:requestRide yChange:50];
            [scroll setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    } else if (isRideConfirmed == YES) {
        if (scroll.contentOffset.y == 0) {
            [References fadeButtonText:requestRide text:@"See Ride Info"];
            [scroll setContentOffset:CGPointMake(0, scroll.contentSize.height/2) animated:YES];
            [References moveDown:requestRide yChange:50];
        } else {
            [References fadeButtonText:requestRide text:@"See Your Ride Messages"];
            [References moveUp:requestRide yChange:50];
            [scroll setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    } else {
        NSMutableArray *newRequests = [[NSMutableArray alloc] initWithArray:[_rideRecord objectForKey:@"requests"]];
        [newRequests addObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]];
        _rideRecord[@"requests"] = newRequests;
        CKModifyRecordsOperation *modifyRecords= [[CKModifyRecordsOperation alloc]
                                                  initWithRecordsToSave:[[NSArray alloc] initWithObjects:_rideRecord, nil] recordIDsToDelete:nil];
        modifyRecords.savePolicy=CKRecordSaveAllKeys;
        modifyRecords.qualityOfService=NSQualityOfServiceUserInitiated;
        modifyRecords.modifyRecordsCompletionBlock=
        ^(NSArray * savedRecords, NSArray * deletedRecordIDs, NSError * operationError){
            //   the completion block code here
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [self addToMyRides];
            });
        };
        CKContainer *defaultContainer = [CKContainer defaultContainer];
        [[defaultContainer publicCloudDatabase] addOperation:modifyRecords];
}
}

-(void)addToMyRides{
    NSString *string = [NSString stringWithFormat:@"email = '%@'",[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]];
    CKContainer *defaultContainer = [CKContainer defaultContainer];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:string];
    CKDatabase *publicDatabase = [defaultContainer publicCloudDatabase];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"People" predicate:predicate];
    [publicDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (!error) {
            CKRecord *record = results[0];
            NSMutableArray *newRequests = [[NSMutableArray alloc] initWithArray:[record objectForKey:@"myRides"]];
            [newRequests addObject:_ride.phone];
            record[@"myRides"] = newRequests;
            CKModifyRecordsOperation *modifyRecords= [[CKModifyRecordsOperation alloc]
                                                      initWithRecordsToSave:[[NSArray alloc] initWithObjects:record, nil] recordIDsToDelete:nil];
            modifyRecords.savePolicy=CKRecordSaveAllKeys;
            modifyRecords.qualityOfService=NSQualityOfServiceUserInitiated;
            modifyRecords.modifyRecordsCompletionBlock=
            ^(NSArray * savedRecords, NSArray * deletedRecordIDs, NSError * operationError){
                //   the completion block code here
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [References toastMessage:@"Ride Requested" andView:self];
                });
            };
            CKContainer *defaultContainer = [CKContainer defaultContainer];
            [[defaultContainer publicCloudDatabase] addOperation:modifyRecords];
        }
        else {
            NSLog(@"%@",error.localizedDescription);
        }
    }];
    
}

-(void)IsMyDrive {
    if ([_ride.phone isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]]) {
        isRideConfirmed = YES;
        [requestRide setTitleColor:[[self view] tintColor] forState:UIControlStateNormal];
        [requestRide setTitle:@"See Your Drive Messages" forState:UIControlStateNormal];
        scroll.contentSize = CGSizeMake([References screenWidth], scroll.frame.size.height);
        scroll.frame = CGRectMake(0, menuBar.frame.origin.y+menuBar.frame.size.height, [References screenWidth], [References screenHeight]-menuBar.frame.size.height);
        [References createLine:scroll xPos:0 yPos:ridePanelMessage.frame.origin.y inFront:TRUE];
        menuBarTitle.text = @"Drive Info";
        if (_ride.riders.count == 0) {
            rideTable.hidden = YES;
            noRiders.hidden = NO;
            noRiders.text = @"No Riders";
        } else if (_ride.messages.count < 1) {
            rideTable.hidden = YES;
            noRiders.hidden = NO;
            noRiders.text = @"No Messages";
        }
    }
}

-(void)isRidePending {
    for (int a = 0; a < _ride.requests.count; a++) {
        if ([_ride.requests[a] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]]) {
            [requestRide setTitle:@"Ride Request Pending" forState:UIControlStateNormal];
            [requestRide setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        }
    }
}

-(void)isRideConfirmed {
    for (int a = 0; a < _ride.riders.count; a++) {
        if ([_ride.riders[a] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]]) {
            [requestRide setTitleColor:[[self view] tintColor] forState:UIControlStateNormal];
            isRideConfirmed = YES;
            [requestRide setTitle:@"See Your Ride Messages" forState:UIControlStateNormal];
            scroll.contentSize = CGSizeMake([References screenWidth], scroll.frame.size.height);
            scroll.frame = CGRectMake(0, menuBar.frame.origin.y+menuBar.frame.size.height, [References screenWidth], [References screenHeight]-menuBar.frame.size.height);
            [References createLine:scroll xPos:0 yPos:ridePanelMessage.frame.origin.y inFront:TRUE];
        }
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (ridersButton.titleLabel.textColor == [UIColor blackColor]) {
        return _ride.riders.count;
    } else {
        return _ride.messages.count;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (ridersButton.titleLabel.textColor == [UIColor blackColor]) {
        return 57;
    } else {
        int multiples =ceil([_ride.messages[indexPath.row] length] / 30);
        if (multiples <= 1) {
            return 57;
        } else {
            int adddition = 10*multiples;
            return 57+adddition;
        }
        
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (ridersButton.titleLabel.textColor == [UIColor blackColor]) {
        static NSString *simpleTableIdentifier = @"driveRequestsCell";
        
        driveRequestsCell *cell = (driveRequestsCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"driveRequestsCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        [References cornerRadius:cell.picutre radius:cell.picutre.frame.size.width/2];
        cell.initial.text = [NSString stringWithFormat:@"%c",[_ride.riders[indexPath.row] characterAtIndex:0]];
        cell.initial.text = [cell.initial.text uppercaseString];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.name.text = _ride.riders[indexPath.row];
        if (isRideConfirmed == YES) {
            [cell.confirm setBackgroundImage:[UIImage imageNamed:@"phone.png"] forState:UIControlStateNormal];
            [References tintUIButton:cell.confirm color:[[self view] tintColor]];
            cell.tag = indexPath.row;
            [cell.confirm addTarget:self action:@selector(callPerson:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        return cell;
    } else {
        static NSString *simpleTableIdentifier = @"messageCell";
        
        messageCell *cell = (messageCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"messageCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        NSArray *messageBody = [_ride.messages[indexPath.row] componentsSeparatedByString:@"^&^"];
        cell.initial.text = [NSString stringWithFormat:@"%c",[messageBody[0] characterAtIndex:0]];
        cell.initial.text = [cell.initial.text uppercaseString];
        int multiples =ceil([messageBody[1] length] / 30);
        multiples++;
        cell.message.text = messageBody[1];
        [cell.message setNumberOfLines:multiples];
        cell.message.frame = CGRectMake(cell.message.frame.origin.x, cell.message.frame.origin.y, cell.message.frame.size.width, 22*multiples);
        [References cornerRadius:cell.picture radius:cell.picture.frame.size.width/2];
        
        [cell setBackgroundColor:[UIColor clearColor]];
        
        
        return cell;
    }
}

-(void)callPerson:(UIButton*)sender {
    NSLog(@"%@",_ride.riders[sender.tag]);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",_ride.riders[sender.tag]]]];
}
    
@end
