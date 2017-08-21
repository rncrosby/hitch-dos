//
//  historyView.m
//  Hitch
//
//  Created by Robert Crosby on 8/18/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "historyView.h"

@interface historyView ()

@end

@implementation historyView

- (void)viewDidLoad {
    [References createLine:self.view xPos:0 yPos:menuBar.frame.origin.y+menuBar.frame.size.height inFront:TRUE];
    [References createLine:self.view xPos:0 yPos:bottomBar.frame.origin.y inFront:TRUE];
    [super viewDidLoad];
    [self getTransactions];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getTransactions {
    [transactions removeAllObjects];
    transactions = [[NSMutableArray alloc] init];
    NSString *toPaymentString = [NSString stringWithFormat:@"to == '%@'",[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]];
    CKQuery *toPaymentQuery = [[CKQuery alloc] initWithRecordType:@"Invoices" predicate:[NSPredicate predicateWithFormat:toPaymentString]];
    [[CKContainer defaultContainer].publicCloudDatabase performQuery:toPaymentQuery
                                                        inZoneWithID:nil
                                                   completionHandler:^(NSArray *results, NSError *error) {
                                                       
                                                       for (int a = 0; a < results.count; a++) {
                                                           CKRecord *record = results[a];
                                                           NSString *amount = [record valueForKey:@"amount"];
                                                           NSDate *date = [record valueForKey:@"createdAt"];
                                                           double betterAmount = amount.doubleValue * 0.01;
                                                           transactionObject *transaction = [[transactionObject alloc] initWithType:[record valueForKey:@"rideID"] andAmount:betterAmount andIsIncome:YES andDate:date];
                                                           [transactions addObject:transaction];
                                                       }
                                                       dispatch_async(dispatch_get_main_queue(), ^(void){
                                                           [self calculateValue];
                                                           [table reloadData];
                                                       });
                                                   }];
    NSString *fromPaymentString = [NSString stringWithFormat:@"from == '%@'",[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]];
    CKQuery *fromPaymentQuery = [[CKQuery alloc] initWithRecordType:@"Invoices" predicate:[NSPredicate predicateWithFormat:fromPaymentString]];
    [[CKContainer defaultContainer].publicCloudDatabase performQuery:fromPaymentQuery
                                                        inZoneWithID:nil
                                                   completionHandler:^(NSArray *results, NSError *error) {
                                                       for (int a = 0; a < results.count; a++) {
                                                           CKRecord *record = results[a];
                                                           NSString *amount = [record valueForKey:@"amount"];
                                                           NSDate *date = [record valueForKey:@"createdAt"];
                                                           double betterAmount = amount.doubleValue * 0.01;
                                                           transactionObject *transaction = [[transactionObject alloc] initWithType:[record valueForKey:@"rideID"] andAmount:betterAmount andIsIncome:NO andDate:date];
                                                           [transactions addObject:transaction];
                                                       }
                                                       dispatch_async(dispatch_get_main_queue(), ^(void){
                                                           [self calculateValue];
                                                           [table reloadData];
                                                       });
                                                   }];
}

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)withdrawMoney:(id)sender {
    if (currentBalance < 0) {
        [References fullScreenToast:@"Insufficient Funds To Withdraw" inView:self withSuccess:FALSE andClose:FALSE];
    } else {
        [References fullScreenToast:@"Coming Soon" inView:self withSuccess:YES andClose:NO];
    }
}

- (IBAction)redeemCode:(id)sender {
    [References fullScreenToast:@"Coming Soon" inView:self withSuccess:YES andClose:NO];
}

-(void)calculateValue {
    double value = 0;
    for (int a = 0; a < transactions.count; a++) {
        transactionObject *transaction = transactions[a];
        if (transaction.isIncome.boolValue == YES) {
            value = value + transaction.amount.doubleValue;
        } else {
            value = value - transaction.amount.doubleValue;
        }

    }
    if (value < 0) {
        accountValue.text = [NSString stringWithFormat:@"-$%.2f",fabs(value)];
    } else {
        accountValue.text = [NSString stringWithFormat:@"$%.2f",value];
    }
    currentBalance = value;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return transactions.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 113;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"transactionCell";
    
    transactionCell *cell = (transactionCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"transactionCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    transactionObject *transaction = transactions[indexPath.row];
    if (transaction.isIncome.boolValue == YES) {
        [cell.card setBackgroundColor:[References colorFromHexString:@"#1CE58D"]];
    } else {
        [cell.card setBackgroundColor:[References colorFromHexString:@"#FF3824"]];
    }
    if (transaction.amount.doubleValue < 0) {
        cell.amount.text = [NSString stringWithFormat:@"-$%.2f",fabs(transaction.amount.doubleValue)];
    } else {
        cell.amount.text = [NSString stringWithFormat:@"$%.2f",transaction.amount.doubleValue];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, MMMM d"];
    cell.date.text = [dateFormatter stringFromDate:transaction.date];
    [cell setBackgroundColor:[UIColor clearColor]];
    [References cornerRadius:cell.card radius:8.0f];
    [References cardshadow:cell.shadow];
    return cell;
}
@end
