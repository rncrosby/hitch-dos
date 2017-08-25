//
//  startView.m
//  Hitch
//
//  Created by Robert Crosby on 8/8/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "startView.h"

@interface startView ()

@end

@implementation startView

- (void)viewDidLoad {
    ogTitle = titleLabel.frame;
    ogTitleInstruct = titleInstruction.frame;
    ogMainInput = mainInput.frame;
    schoolEmails = [[NSArray alloc] initWithObjects:@"@uoregon.edu",@"@ucsc.edu",@"@me.com", nil];
    blurBack = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [References screenWidth], [References screenHeight])];
    blurBack.backgroundColor = [UIColor clearColor];
    [References lightblurView:blurBack];
    blurBack.hidden = YES;
    [self.view addSubview:blurBack];
    [self.view sendSubviewToBack:blurBack];
    currentPage = 0;
//    [References cornerRadius:card radius:8.0f];
//    [References cardshadow:shadow];
//    [References createLine:self.view xPos:0 yPos:menuBar.frame.origin.y+menuBar.frame.size.height inFront:TRUE];
    [super viewDidLoad];
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&sessionError];
    [[AVAudioSession sharedInstance] setActive:YES error:&sessionError];
    bgVideo = [[UIView alloc] initWithFrame:CGRectMake(-100, 0, [References screenWidth]+200, [References screenHeight])];
    bgVideo.alpha = 0.7;
    //Set up player
    NSURL *movieURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"dog" ofType:@"mp4"]];
    AVAsset *avAsset = [AVAsset assetWithURL:movieURL];
    AVPlayerItem *avPlayerItem =[[AVPlayerItem alloc]initWithAsset:avAsset];
    avPlayerItem.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmVarispeed;
    self.avplayer = [[AVPlayer alloc]initWithPlayerItem:avPlayerItem];
    AVPlayerLayer *avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:self.avplayer];
    [avPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [avPlayerLayer setFrame:bgVideo.frame];
    [bgVideo.layer addSublayer:avPlayerLayer];
    [self.view addSubview:bgVideo];
    [self.view sendSubviewToBack:bgVideo];
    //Config player
    [self.avplayer seekToTime:kCMTimeZero];
    [self.avplayer setVolume:0.0f];
    [self.avplayer setActionAtItemEnd:AVPlayerActionAtItemEndNone];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.avplayer currentItem]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerStartPlaying)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    // Do any additional setup after loading the view.
    numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, [References screenWidth], 44)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(toolbarCancel)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(toolbarEmter)],
                           nil];
    [numberToolbar sizeToFit];
    mainInput.inputAccessoryView = numberToolbar;
    
}

-(void)viewDidAppear:(BOOL)animated {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [References fadeIn:titleLabel];
        [References fadeIn:titleInstruction];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [References fadeIn:blurBack];
            [References moveUp:titleLabel yChange:250];
            [References moveUp:titleInstruction yChange:250];
            [References fadeIn:toggleDogButton];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [References fadeLabelText:titleInstruction newText:@"Enter your phone number to get started"];
                [References fadeIn:mainInput];
            });
        });
    });
}

-(void)toolbarCancel {
    [mainInput resignFirstResponder];
}

-(void)toolbarEmter {
    [self continueOnboarding];
    [mainInput resignFirstResponder];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
    [self.avplayer play];
}

- (void)playerStartPlaying
{
    [self.avplayer play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self continueOnboarding];
    [textField resignFirstResponder];
    return YES;
}

-(void)continueOnboarding {
    if (currentPage == 0) {
        phone = mainInput.text;
        NSString *string = [NSString stringWithFormat:@"phone BEGINSWITH %@",phone];
        NSPredicate *predicate = [NSPredicate predicateWithValue:string];
        CKQuery *query = [[CKQuery alloc] initWithRecordType:@"People" predicate:predicate];
        
        [[CKContainer defaultContainer].publicCloudDatabase performQuery:query
                                                            inZoneWithID:nil
                                                       completionHandler:^(NSArray *results, NSError *error) {
                                                           dispatch_async(dispatch_get_main_queue(), ^(void){
                                                               bool foundAccount = false;;
                                                               for (int a = 0; a < results.count; a++) {
                                                                   CKRecord *record = results[a];
                                                                   if ([phone isEqualToString:[record valueForKey:@"phone"]]) {
                                                                       phone = [record valueForKey:@"phone"];
                                                                       name = [record valueForKey:@"name"];
                                                                       email = [record valueForKey:@"email"];
                                                                       foundAccount = true;
                                                                       a = (int)results.count;
                                                                   }
                                                               }
                                                               if (foundAccount == true) {
                                                                   if (autoCreate == TRUE) {
                                                                       [References fadePlaceholderText:mainInput newText:@""];
                                                                       [mainInput setText:@""];
                                                                       [References fadeLabelText:titleLabel newText:@"Nice!"];
                                                                       [References fadeLabelText:titleInstruction newText:@"Finding rides around you..."];
                                                                       [References fadeOut:mainInput];
                                                                       [References moveDown:titleLabel yChange:250];
                                                                       [References moveDown:titleInstruction yChange:240];
                                                                       [References fadeOut:blurBack];
                                                                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                                                           [mainInput setFont:[UIFont fontWithName:mainInput.font.fontName size:37]];
                                                                           [mainInput setKeyboardType:UIKeyboardTypeNumberPad];
                                                                           currentPage = 4;
                                                                           [[NSUserDefaults standardUserDefaults] setObject:phone forKey:@"email"];
                                                                           [[NSUserDefaults standardUserDefaults] setObject:phone forKey:@"name"];
                                                                           [[NSUserDefaults standardUserDefaults] setObject:phone forKey:@"phone"];
                                                                           [[NSUserDefaults standardUserDefaults] synchronize];
                                                                           
                                                                           feedView *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"feedView"];
                                                                           [self presentViewController:viewController animated:YES completion:^(){
                                                                               titleLabel.frame = ogTitle;
                                                                               titleInstruction.frame = ogTitleInstruct;
                                                                               mainInput.frame = ogMainInput;
                                                                           }];
                                                                       });
                                                                   } else {
                                                                       isSignIn = true;
                                                                       [self textCode];
                                                                       [mainInput setText:@""];
                                                                       [References moveDown:titleInstruction yChange:10];
                                                                       [References moveDown:mainInput yChange:10];
                                                                       [References fadeLabelText:titleLabel newText:[NSString stringWithFormat:@"Hey, %@!",name]];
                                                                       [References fadeLabelText:titleInstruction newText:@"You'll be texted a code to sign in"];
                                                                       [References fadePlaceholderText:mainInput newText:@"1234"];
                                                                       currentPage = 3;
                                                                   }
                                                               } else {
                                                                   if (autoCreate == TRUE) {
                                                                       UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Redeem Code" message:@"Enter a referral thing" preferredStyle:UIAlertControllerStyleAlert];
                                                                       [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                                                                           textField.placeholder = @"5 Character Code";
                                                                       }];
                                                                       UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                                                                       }];
                                                                       UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Redeem" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                           UITextField *code = alertController.textFields.firstObject;
                                                                           referralCode = code.text;
                                                                           [References fadePlaceholderText:mainInput newText:@""];
                                                                           [mainInput setText:@""];
                                                                           [References fadeLabelText:titleLabel newText:@"Nice!"];
                                                                           [References fadeLabelText:titleInstruction newText:@"Finding rides around you..."];
                                                                           [References fadeOut:mainInput];
                                                                           [References moveDown:titleLabel yChange:250];
                                                                           [References moveDown:titleInstruction yChange:240];
                                                                           [References fadeOut:blurBack];
                                                                           CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:[NSString stringWithFormat:@"%i",arc4random() %500]];
                                                                           CKRecord *postRecord = [[CKRecord alloc] initWithRecordType:@"People" recordID:recordID];
                                                                           postRecord[@"email"] = [NSString stringWithFormat:@"%@",phone];
                                                                           postRecord[@"name"] = [NSString stringWithFormat:@"%@",phone];
                                                                           postRecord[@"phone"] = [NSString stringWithFormat:@"%@",phone];
                                                                           postRecord[@"referredBy"] = [NSString stringWithFormat:@"%@",referralCode];
                                                                           CKDatabase *publicDatabase = [[CKContainer defaultContainer] publicCloudDatabase];
                                                                           [publicDatabase saveRecord:postRecord completionHandler:^(CKRecord *record, NSError *error) {
                                                                               if(error) {
                                                                                   NSLog(@"%@",error.localizedDescription);
                                                                               } else {
                                                                                   dispatch_async(dispatch_get_main_queue(), ^(void){
                                                                                       [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"email"];
                                                                                       [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"name"];
                                                                                       [[NSUserDefaults standardUserDefaults] setObject:phone forKey:@"phone"];
                                                                                       [[NSUserDefaults standardUserDefaults] synchronize];
                                                                                       
                                                                                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                                                                           feedView *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"feedView"];
                                                                                           [self presentViewController:viewController animated:YES completion:^(){
                                                                                               titleLabel.frame = ogTitle;
                                                                                               titleInstruction.frame = ogTitleInstruct;
                                                                                               mainInput.frame = ogMainInput;
                                                                                           }];
                                                                                       });
                                                                                   });
                                                                                   
                                                                               }
                                                                           }];
                                                                       }];
                                                                       
                                                                       [alertController addAction:cancelAction];
                                                                       [alertController addAction:okAction];
                                                                       [self presentViewController:alertController animated: YES completion: nil];
                                                                   } else {
                                                                       [mainInput setFont:[UIFont fontWithName:mainInput.font.fontName size:30]];
                                                                       [mainInput setText:@""];
                                                                       [References fadeLabelText:titleLabel newText:@"Welcome"];
                                                                       [References fadeLabelText:titleInstruction newText:@"Enter your school email to continue"];
                                                                       [References fadePlaceholderText:mainInput newText:@"useraccount@ucsc.edu"];
                                                                       [mainInput setKeyboardType:UIKeyboardTypeEmailAddress];
                                                                       isSignIn = false;
                                                                       currentPage = 1;
                                                                   }
                                                                   
                                                               }
                                                           });
                                                           
                                                           
                                                       }];
    } else if (currentPage == 1) {
        bool isSchoolEmail = false;
        for (int a = 0; a < schoolEmails.count; a++) {
            if ([mainInput.text containsString:schoolEmails[a]]) {
                isSchoolEmail = true;
                break;
            }
        }
        if (isSchoolEmail == true) {
            email = mainInput.text;
            [mainInput setFont:[UIFont fontWithName:mainInput.font.fontName size:37]];
            [mainInput setText:@""];
            [References moveDown:titleInstruction yChange:5];
            [References moveDown:mainInput yChange:5];
            [References fadeLabelText:titleLabel newText:@"Hi _____!"];
            [References fadeLabelText:titleInstruction newText:@"Now we just need a name to call you."];
            [References fadePlaceholderText:mainInput newText:@"Ron"];
            [mainInput setKeyboardType:UIKeyboardTypeAlphabet];
            currentPage = 2;
        } else {
            [References fullScreenToast:@"Sorry, your school isnt currently supported." inView:self withSuccess:NO andClose:NO];
        }
    } else if (currentPage == 2) {
        if (mainInput.text.length > 0) {
            [mainInput setFont:[UIFont fontWithName:mainInput.font.fontName size:37]];
            name = mainInput.text;
            [mainInput setText:@""];
            [References moveUp:titleInstruction yChange:5];
            [References moveUp:mainInput yChange:5];
            [References fadeLabelText:titleLabel newText:[NSString stringWithFormat:@"Hi %@!",name]];
            [References fadeLabelText:titleInstruction newText:@"We're emailing you a code to verify your school"];
            [References fadePlaceholderText:mainInput newText:@"1234"];
            [mainInput setKeyboardType:UIKeyboardTypeNumberPad];
            currentPage = 3;
            [self emailCode];
        } else {
             [References fullScreenToast:@"Something's not right with your name" inView:self withSuccess:NO andClose:NO];
        }
    } else if (currentPage == 3) {
        if ([mainInput.text isEqualToString:code]) {
            if (isSignIn == false) {
                [mainInput setFont:[UIFont fontWithName:mainInput.font.fontName size:37]];
                [mainInput setText:@""];
                [References fadeLabelText:titleLabel newText:@"Referral Code"];
                [References fadeLabelText:titleInstruction newText:@"Enter someones referral code and when you join a ride you save $5!"];
                [References fadePlaceholderText:mainInput newText:@"1234"];
                [mainInput setKeyboardType:UIKeyboardTypeNumberPad];
                currentPage = 5;
            } else {
                [References fadePlaceholderText:mainInput newText:@""];
                [mainInput setText:@""];
                [References fadeLabelText:titleLabel newText:@"Nice!"];
                [References fadeLabelText:titleInstruction newText:@"Finding rides around you..."];
                [References fadeOut:mainInput];
                [References moveDown:titleLabel yChange:250];
                [References moveDown:titleInstruction yChange:240];
                [References fadeOut:blurBack];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [mainInput setFont:[UIFont fontWithName:mainInput.font.fontName size:37]];
                    [mainInput setKeyboardType:UIKeyboardTypeNumberPad];
                    currentPage = 4;
                    [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"email"];
                    [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"name"];
                    [[NSUserDefaults standardUserDefaults] setObject:phone forKey:@"phone"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    feedView *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"feedView"];
                    [self presentViewController:viewController animated:YES completion:^(){
                        titleLabel.frame = ogTitle;
                        titleInstruction.frame = ogTitleInstruct;
                        mainInput.frame = ogMainInput;
                    }];
                });
            }
        } else {
            [References fullScreenToast:@"Something's not right with your code" inView:self withSuccess:NO andClose:NO];
        }
    } else if (currentPage == 5) {
            referralCode = mainInput.text;
            [References fadePlaceholderText:mainInput newText:@""];
            [mainInput setText:@""];
            [References fadeLabelText:titleLabel newText:@"Nice!"];
            [References fadeLabelText:titleInstruction newText:@"Finding rides around you..."];
            [References fadeOut:mainInput];
            [References moveDown:titleLabel yChange:250];
            [References moveDown:titleInstruction yChange:240];
            [References fadeOut:blurBack];
            CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:[NSString stringWithFormat:@"%i",arc4random() %500]];
            CKRecord *postRecord = [[CKRecord alloc] initWithRecordType:@"People" recordID:recordID];
            postRecord[@"email"] = [NSString stringWithFormat:@"%@",email];
            postRecord[@"name"] = [NSString stringWithFormat:@"%@",name];
            postRecord[@"phone"] = [NSString stringWithFormat:@"%@",phone];
            postRecord[@"referredBy"] = [NSString stringWithFormat:@"%@",referralCode];
            CKDatabase *publicDatabase = [[CKContainer defaultContainer] publicCloudDatabase];
            [publicDatabase saveRecord:postRecord completionHandler:^(CKRecord *record, NSError *error) {
                if(error) {
                    NSLog(@"%@",error.localizedDescription);
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"email"];
                        [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"name"];
                        [[NSUserDefaults standardUserDefaults] setObject:phone forKey:@"phone"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            feedView *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"feedView"];
                            [self presentViewController:viewController animated:YES completion:^(){
                                titleLabel.frame = ogTitle;
                                titleInstruction.frame = ogTitleInstruct;
                                mainInput.frame = ogMainInput;
                            }];
                        });
                    });
                    
                }
            }];
        }
}

/*
 {
 CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:[NSString stringWithFormat:@"%i",arc4random() %500]];
 CKRecord *postRecord = [[CKRecord alloc] initWithRecordType:@"People" recordID:recordID];
 postRecord[@"email"] = [NSString stringWithFormat:@"%@",email];
 postRecord[@"name"] = [NSString stringWithFormat:@"%@",name];
 postRecord[@"phone"] = [NSString stringWithFormat:@"%@",phone];
 CKDatabase *publicDatabase = [[CKContainer defaultContainer] publicCloudDatabase];
 [publicDatabase saveRecord:postRecord completionHandler:^(CKRecord *record, NSError *error) {
 if(error) {
 NSLog(@"%@",error.localizedDescription);
 } else {
 dispatch_async(dispatch_get_main_queue(), ^(void){
 [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"email"];
 [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"name"];
 [[NSUserDefaults standardUserDefaults] setObject:phone forKey:@"phone"];
 [[NSUserDefaults standardUserDefaults] synchronize];
 
 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
 feedView *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"feedView"];
 [self presentViewController:viewController animated:YES completion:^(){
 titleLabel.frame = ogTitle;
 titleInstruction.frame = ogTitleInstruct;
 mainInput.frame = ogMainInput;
 }];
 });
 });
 
 }
 }];
 }
 */

-(void)emailCode {
    code = [References randomIntWithLength:4];
    NSURL *url = [NSURL URLWithString:@"http://104.236.94.16:5000/email"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    // NSError *actualerror = [[NSError alloc] init];
    // Parameters
    NSDictionary *tmp = [[NSDictionary alloc] init];
    tmp = @{
            @"code"     : code,
            @"email"    : email,
            @"name"     : name
            };
    
    NSError *error;
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];
    [request setHTTPBody:postdata];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                               if (error) {
                                   // Returned Error
                                   NSLog(@"Unknown Error Occured");
                               } else {
                                   nil;
                               }
                           }];
    
}

-(void)textCode {
    code = [References randomIntWithLength:4];
    NSURL *url = [NSURL URLWithString:@"http://104.236.94.16:5000/sms"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    // NSError *actualerror = [[NSError alloc] init];
    // Parameters
    NSDictionary *tmp = [[NSDictionary alloc] init];
    tmp = @{
            @"code"     : code,
            @"phone"    : phone,
            };
    
    NSError *error;
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];
    [request setHTTPBody:postdata];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                               if (error) {
                                   // Returned Error
                                   NSLog(@"Unknown Error Occured");
                               } else {
                                   NSLog(@"Success");
                               }
                           }];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
/*
- (IBAction)continueButton:(id)sender {
    CKContainer *defaultContainer = [CKContainer defaultContainer];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"email = '%@'",[NSString stringWithFormat:@"%@",emailAddress.text]]];
    CKDatabase *publicDatabase = [defaultContainer publicCloudDatabase];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"People" predicate:predicate];
    [publicDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (!error) {
            if (results.count == 0) {
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:[NSString stringWithFormat:@"%i",arc4random() %500]];
                    CKRecord *postRecord = [[CKRecord alloc] initWithRecordType:@"People" recordID:recordID];
                    postRecord[@"email"] = [NSString stringWithFormat:@"%@",emailAddress.text];
                    postRecord[@"name"] = [NSString stringWithFormat:@"%@",name.text];
                    CKDatabase *publicDatabase = [[CKContainer defaultContainer] publicCloudDatabase];
                    [publicDatabase saveRecord:postRecord completionHandler:^(CKRecord *record, NSError *error) {
                        if(error) {
                            NSLog(@"%@",error.localizedDescription);
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^(void){
                                [[NSUserDefaults standardUserDefaults] setObject:emailAddress.text forKey:@"email"];
                                [[NSUserDefaults standardUserDefaults] setObject:name.text forKey:@"name"];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                                feedView *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"feedView"];
                                [self presentViewController:viewController animated:YES completion:nil];
                            });
                            
                        }
                    }];
                });
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [[NSUserDefaults standardUserDefaults] setObject:emailAddress.text forKey:@"email"];
                    [[NSUserDefaults standardUserDefaults] setObject:name.text forKey:@"name"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    feedView *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"feedView"];
                    [self presentViewController:viewController animated:YES completion:nil];
                });
            }
        } else {
            NSLog(@"%@",error.localizedDescription);
        }
    }];
}



- (IBAction)email:(id)sender {
    NSString *code = [References randomStringWithLength:5];
    NSURL *url = [NSURL URLWithString:@"http://104.236.94.16:5000/email"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    // NSError *actualerror = [[NSError alloc] init];
    // Parameters
    NSDictionary *tmp = [[NSDictionary alloc] init];
    tmp = @{
            @"code"     : code,
            @"email"    : @"rcros97@me.com",
            @"name"     : @"Rob"
            };
    
    NSError *error;
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];
    [request setHTTPBody:postdata];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                               if (error) {
                                   // Returned Error
                                   NSLog(@"Unknown Error Occured");
                               } else {
                                   nil;
                               }
                           }];
    
}

 */
-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
- (IBAction)toggleDog:(id)sender {
    if (blurBack.hidden == true) {
        [References fadeButtonText:toggleDogButton text:@"show the dog"];
        [References fadeIn:blurBack];
    } else {
        [References fadeOut:blurBack];
        [References fadeButtonText:toggleDogButton text:@"blur the dog"];
    }
}
- (IBAction)testAccount:(id)sender {
    if ([testAccount.titleLabel.text isEqualToString:@"Auto-Create Account"]) {
        autoCreate = TRUE;
        [testAccount setTitle:@"Manually Create Account" forState:UIControlStateNormal];
    } else {
        autoCreate = FALSE;
        [testAccount setTitle:@"Auto-Create Account" forState:UIControlStateNormal];
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (UIEventSubtypeMotionShake) {
        feedback = [[UINotificationFeedbackGenerator alloc] init];
        [feedback prepare];
        [feedback notificationOccurred:UINotificationFeedbackTypeSuccess];
        [References fadeIn:testAccount];
    }
}
@end
