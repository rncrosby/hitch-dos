//
//  inboxView.m
//  Hitch
//
//  Created by Robert Crosby on 8/9/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "inboxView.h"

@interface inboxView ()

@end

@implementation inboxView

- (void)viewDidLoad {
    [References createLine:self.view xPos:0 yPos:menuBar.frame.origin.y+menuBar.frame.size.height inFront:TRUE];
    [References cardshadow:driveShadow];
    [References cornerRadius:driveCard radius:8.0f];
    [References cardshadow:driveRequestsShadow];
    [References cornerRadius:driveRequestsCard radius:8.0f];
    [super viewDidLoad];
    [self getMyDrive];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getMyDrive {
    NSString *string = [NSString stringWithFormat:@"phone = '%@'",[[NSUserDefaults standardUserDefaults] objectForKey:@"phone"]];
    CKContainer *defaultContainer = [CKContainer defaultContainer];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:string];
    CKDatabase *publicDatabase = [defaultContainer publicCloudDatabase];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Rides" predicate:predicate];
    [publicDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (!error) {
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
                myDrive = [[rideObject alloc] initWithType:start andEnd:end andDate:date andTime:time andSeats:seats andPrice:price andMessages:messages andRiders:riders andName:name andPlainStart:plainStart andPlainEnd:plainEnd andPhone:[record valueForKey:@"phone"] andRequests:requests];
            dispatch_async(dispatch_get_main_queue(), ^(void){
                driveFrom.text = myDrive.plainStart;
                driveTo.text = myDrive.plainEnd;
                driveSeats.text = [NSString stringWithFormat:@"%i",myDrive.seats.intValue];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"EEEE, MMMM d"];
                NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
                [timeFormatter setDateFormat:@"h a"];
                driveDate.text = [NSString stringWithFormat:@"%@ around %@",[dateFormatter stringFromDate:myDrive.date],[timeFormatter stringFromDate:myDrive.date]];
                [driveRequestsTable reloadData];
            });
        } else {
            NSLog(@"%@",error.localizedDescription);
        }
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!myDrive) {
        return 0;
    } else {
    return myDrive.requests.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 57;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"driveRequestsCell";
    
    driveRequestsCell *cell = (driveRequestsCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"driveRequestsCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.name = myDrive.requests[indexPath.row];
    [References tintUIButton:cell.confirm color:[References colorFromHexString:@"#1EE663"]];
    return cell;
}


- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
