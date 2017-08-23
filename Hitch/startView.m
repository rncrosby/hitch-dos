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
//    [References cornerRadius:card radius:8.0f];
//    [References cardshadow:shadow];
//    [References createLine:self.view xPos:0 yPos:menuBar.frame.origin.y+menuBar.frame.size.height inFront:TRUE];
    [super viewDidLoad];
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&sessionError];
    [[AVAudioSession sharedInstance] setActive:YES error:&sessionError];
    bgVideo = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [References screenWidth], [References screenHeight])];
    bgVideo.alpha = 0.7;
    //Set up player
    NSURL *movieURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"vid" ofType:@"mp4"]];
    AVAsset *avAsset = [AVAsset assetWithURL:movieURL];
    AVPlayerItem *avPlayerItem =[[AVPlayerItem alloc]initWithAsset:avAsset];
    avPlayerItem.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmVarispeed;
    self.avplayer = [[AVPlayer alloc]initWithPlayerItem:avPlayerItem];
    AVPlayerLayer *avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:self.avplayer];
    [avPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.avplayer setRate:0.1f];
    [avPlayerLayer setFrame:[[UIScreen mainScreen] bounds]];
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
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
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
    
    [textField resignFirstResponder];
    return YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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

- (IBAction)driver:(id)sender {
    [emailAddress setText:@"driver"];
    [name setText:@"driver"];
}

- (IBAction)rider:(id)sender {
    [emailAddress setText:@"rider"];
    [name setText:@"rider"];
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

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
@end
