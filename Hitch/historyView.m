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
                                                           NSString *chargeAmount = [record valueForKey:@"chargeAmount"];
                                                           double betterCharge = chargeAmount.doubleValue * 0.01;
                                                           NSDate *date = [record valueForKey:@"createdAt"];
                                                           double betterAmount = amount.doubleValue * 0.01;
                                                           
                                                           transactionObject *transaction = [[transactionObject alloc] initWithType:[record valueForKey:@"rideID"] andAmount:betterAmount andIsIncome:YES andDate:date isFrom:[record valueForKey:@"from"] isTo:[record valueForKey:@"to"] andChargeAmount:betterCharge];
                                                           [transactions addObject:transaction];
                                                       }
                                                       dispatch_async(dispatch_get_main_queue(), ^(void){
                                                           [self calculateValue];
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
                                                           NSDate *date = [record objectForKey:@"createdAt"];
                                                           double betterAmount = amount.doubleValue * 0.01;
                                                           NSString *chargeAmount = [record valueForKey:@"chargeAmount"];
                                                           double betterCharge = chargeAmount.doubleValue * 0.01;
                                                           transactionObject *transaction = [[transactionObject alloc] initWithType:[record valueForKey:@"rideID"] andAmount:betterAmount andIsIncome:NO andDate:date isFrom:[record valueForKey:@"from"] isTo:[record valueForKey:@"to"] andChargeAmount:betterCharge];
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
    if (withdrawalBalance <= 0) {
        [References fullScreenToast:@"Insufficient Funds To Withdraw" inView:self withSuccess:FALSE andClose:FALSE];
    } else {
        [References fullScreenToast:@"Coming Soon" inView:self withSuccess:YES andClose:NO];
    }
}

- (IBAction)redeemCode:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Redeem Code" message:@"Codes give you money to spend in hitch, share your code to earn more money." preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"5 Character Code";
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Redeem" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        UITextField *code = alertController.textFields.firstObject;
        if (![code.text isEqualToString:@""]) {
            NSPredicate *predicate = [NSPredicate predicateWithValue:[NSString stringWithFormat:@"code = '%@'",code.text]];
            CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Codes" predicate:predicate];
            [[CKContainer defaultContainer].publicCloudDatabase performQuery:query
                                                                inZoneWithID:nil
                                                           completionHandler:^(NSArray *results, NSError *error) {
                                                               if (results.count > 0) {
                                                                   dispatch_async(dispatch_get_main_queue(), ^(void) {
                                                                       for (int a = 0; a < results.count; a++) {
                                                                           CKRecord *temp = results[a];
                                                                           if ([[temp valueForKey:@"code"] isEqualToString:code.text]) {
                                                                               if ([self haveUsedCode:code.text] == FALSE) {
                                                                                   redemptionCode = temp;
                                                                                   [References fullScreenToast:@"Code Redeemed" inView:self withSuccess:YES andClose:NO];
                                                                                   NSNumber *amount = [temp valueForKey:@"value"];
                                                                                   [self redeemCodeTransaction:amount.doubleValue andCode:code.text];
                                                                                   a = (int)results.count;
                                                                               } else {
                                                                                   [References fullScreenToast:@"You've Already Redeemed This Code" inView:self withSuccess:NO andClose:NO];
                                                                                   a = (int)results.count;
                                                                               }
                                                                           }
                                                                           if (a == results.count-1) {
                                                                               [References fullScreenToast:@"Code Not Available" inView:self withSuccess:NO andClose:NO];
                                                                           }
                                                                       }
                                                                   });
                                                                   
                                                               }
                                                           }];
        }
        
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated: YES completion: nil];
}

-(void)redeemCodeTransaction:(double)amount andCode:(NSString*)code{
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:[NSString stringWithFormat:@"%i",arc4random() %500]];
    CKRecord *record = [[CKRecord alloc] initWithRecordType:@"Invoices" recordID:recordID];
    int value = (int)amount;
    record[@"amount"] = [NSString stringWithFormat:@"%i",value*100];
    record[@"from"] = @"Hitch";
    record[@"to"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
    record[@"rideID"] = code;
    record[@"paymentID"] = code;
    CKDatabase *publicDatabase = [[CKContainer defaultContainer] publicCloudDatabase];
    [publicDatabase saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
        if(error) {
            NSLog(@"%@",error.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [References fullScreenToast:@"Something Isn't Right" inView:self withSuccess:NO andClose:NO];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [self getTransactions];
            });
            
            
        }
    }];
}

-(bool)haveUsedCode:(NSString*)code {
    for (int a = 0; a < transactions.count; a++) {
        transactionObject *object = transactions[a];
        if ([object.rideID isEqualToString:code]) {
            return TRUE;
        }
    }
    return FALSE;
}

-(void)calculateValue {
    currentBalance = 0;
    withdrawalBalance = 0;
    double value = 0;
    for (int a = 0; a < transactions.count; a++) {
        transactionObject *transaction = transactions[a];
        if (transaction.isIncome.boolValue == YES) {
            value = value + transaction.amount.doubleValue;
            if ([transaction.from isEqualToString:@"Hitch"]) {
                nil;
            } else {
                withdrawalBalance = withdrawalBalance + transaction.amount.doubleValue;
            }
        } else {
            if ([transaction.to isEqualToString:@"Hitch"]) {
                value = value - fabs(transaction.amount.doubleValue);
            }
        }
    }
    withdrawalBalancelabel.text = [NSString stringWithFormat:@"$%.2f",withdrawalBalance];
    accountValue.text = [NSString stringWithFormat:@"$%.2f",value];
    currentBalance = value;
    NSMutableArray *betterTransactions = [[NSMutableArray alloc] init];
    for (int a = 0; a < transactions.count; a++) {
        transactionObject *object = transactions[a];
        if ([object.from isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]] && [object.to isEqualToString:@"Hitch"]) {
            nil;
        } else {
            [betterTransactions addObject:object];
        }
    }
    [transactions removeAllObjects];
    [transactions addObjectsFromArray:betterTransactions];
    [table reloadData];
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
        cell.amount.text = [NSString stringWithFormat:@"$%.2f",transaction.amount.doubleValue];
        [cell.card setBackgroundColor:[References colorFromHexString:@"#1CE58D"]];
    } else {
        [cell.card setBackgroundColor:[References colorFromHexString:@"#FF3824"]];
        cell.amount.text = [NSString stringWithFormat:@"$%.2f",transaction.chargeAmount.doubleValue];
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
