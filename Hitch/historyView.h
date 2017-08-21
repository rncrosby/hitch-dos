//
//  historyView.h
//  Hitch
//
//  Created by Robert Crosby on 8/18/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "References.h"
#import <CloudKit/CloudKit.h>
#import "transactionObject.h"
#import "transactionCell.h"

@interface historyView : UIViewController <UITableViewDelegate,UITableViewDataSource> {
    NSMutableArray *transactions;
    __weak IBOutlet UILabel *menuBar;
    __weak IBOutlet UILabel *accountValue;
    __weak IBOutlet UITableView *table;
    __weak IBOutlet UILabel *bottomBar;
    double currentBalance;
}
- (IBAction)backButton:(id)sender;
- (IBAction)withdrawMoney:(id)sender;
- (IBAction)redeemCode:(id)sender;

@end
