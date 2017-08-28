//
//  feedView.h
//  Hitch
//
//  Created by Robert Crosby on 8/6/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "feedCell.h"
#import "References.h"
#import <CoreLocation/CoreLocation.h>
#import "rideObject.h"
#import <CloudKit/CloudKit.h>
#import "rideView.h"
#import "feedView.h"
#import "postView.h"
#import "historyView.h"
#import "startView.h"

@interface feedView : UIViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,CLLocationManagerDelegate> {
    CLLocationManager *location;
    bool canMakeDrive;
    CLPlacemark *start,*end;
    NSMutableArray *rides,*rideRecords;
    UINotificationFeedbackGenerator *feedback;
    float movement;
    CGRect ogPostRideFrame,ogNotification;
    bool isRestrictedSearch,menuShowing;
    UISelectionFeedbackGenerator *selectionFeedback;
    // SEARCH PANEL
    __weak IBOutlet UITextField *startPoint;
    __weak IBOutlet UITextField *endPoint;
    __weak IBOutlet UILabel *searchCard;
    __weak IBOutlet UILabel *noRides;
    // MENU BAR
    __weak IBOutlet UILabel *menuCard;
    __weak IBOutlet UIButton *postRide;
    
    __weak IBOutlet UIButton *currentLocation;
    __weak IBOutlet UIButton *refreshButton;
    __weak IBOutlet UIButton *menuButton;
    __weak IBOutlet UIButton *forYou;
    __weak IBOutlet UIButton *transactionHistory;
    __weak IBOutlet UIButton *signOut;
    __weak IBOutlet UILabel *menuBarLine;
    __weak IBOutlet UIButton *postRideDestinationFrame;
    __weak IBOutlet UILabel *menuBlur;
    __weak IBOutlet UIButton *profileButton;
    __weak IBOutlet UILabel *profileLabel;
    __weak IBOutlet UILabel *notifications;
    
    // OTHER VIEWS
    UIRefreshControl *refreshControl;
    __weak IBOutlet UITableView *table;
}
@property (nonatomic, retain) NSString *rideToOpen;
- (IBAction)inbox:(id)sender;
- (IBAction)postDrive:(id)sender;
- (IBAction)more:(id)sender;
- (IBAction)refreshButton:(id)sender;
- (IBAction)currentLocation:(id)sender;
- (IBAction)transactionHistory:(id)sender;
- (IBAction)signOut:(id)sender;

@end
