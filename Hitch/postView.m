//
//  postView.m
//  Hitch
//
//  Created by Robert Crosby on 8/7/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "postView.h"

@interface postView ()

@end

@implementation postView

- (void)viewDidLoad {
    [References createLine:self.view xPos:0 yPos:menuBar.frame.origin.y+menuBar.frame.size.height inFront:TRUE];
    [References cornerRadius:map radius:8.0f];
    [super viewDidLoad];
    location = [[CLLocation alloc] initWithLatitude:[[NSUserDefaults standardUserDefaults] doubleForKey:@"currentLatitude"] longitude:[[NSUserDefaults standardUserDefaults] doubleForKey:@"currentLongitude"]];
    [self loadMap];
    UIDatePicker *datePicker = [[UIDatePicker alloc]init];
    [datePicker setDate:[NSDate date]];
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    [datePicker addTarget:self action:@selector(updateDate:) forControlEvents:UIControlEventValueChanged];
    UIToolbar *toolbar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,-44,[References screenWidth],44)];
    toolbar.barStyle = UIBarStyleDefault;
    UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(donePicker:)];
    [toolbar setItems:[NSArray arrayWithObjects:flexibleSpaceLeft, doneButton, nil]];
    [date setInputAccessoryView:toolbar];
    [date setInputView:datePicker];
    UIDatePicker *timePicker = [[UIDatePicker alloc]init];
    [timePicker setDate:[NSDate date]];
    [timePicker setDatePickerMode:UIDatePickerModeTime];
    [timePicker addTarget:self action:@selector(updateTime:) forControlEvents:UIControlEventValueChanged];
    [time setInputView:timePicker];
    UIToolbar *toolbardos= [[UIToolbar alloc] initWithFrame:CGRectMake(0,-44,[References screenWidth],44)];
    toolbar.barStyle = UIBarStyleDefault;
    UIBarButtonItem *flexibleSpaceLeftdos = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* doneButtondos = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(donePicker:)];
    [toolbardos setItems:[NSArray arrayWithObjects:flexibleSpaceLeftdos, doneButtondos, nil]];
    [time setInputAccessoryView:toolbardos];
    UIToolbar *toolbartres= [[UIToolbar alloc] initWithFrame:CGRectMake(0,-44,[References screenWidth],44)];
    toolbar.barStyle = UIBarStyleDefault;
    UIBarButtonItem *flexibleSpaceLefttres = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* doneButtontres = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(donePicker:)];
    [toolbartres setItems:[NSArray arrayWithObjects:flexibleSpaceLefttres, doneButtontres, nil]];
    [seats setInputAccessoryView:toolbartres];
    UIToolbar *toolbarquatro= [[UIToolbar alloc] initWithFrame:CGRectMake(0,-44,[References screenWidth],44)];
    toolbar.barStyle = UIBarStyleDefault;
    UIBarButtonItem *flexibleSpaceLeftquatro = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* doneButtonquatro = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(donePicker:)];
    [toolbarquatro setItems:[NSArray arrayWithObjects:flexibleSpaceLeftquatro, doneButtonquatro, nil]];
    [price setInputAccessoryView:toolbarquatro];
    // Do any additional setup after loading the view.
}

-(void)donePicker:(id)sender {
    [date resignFirstResponder];
    [time resignFirstResponder];
    [seats resignFirstResponder];
    [price resignFirstResponder];
}

-(void)updateDate:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)date.inputView;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, MMMM d"]; //Choose the appropriate style for your case
    date.text = [dateFormatter stringFromDate:picker.date];
    actualDate = picker.date;
}

-(void)updateTime:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)time.inputView;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm a"]; //Choose the appropriate style for your case
    time.text = [dateFormatter stringFromDate:picker.date];
    actualTime = picker.date;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(bool)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 1) {
        // start
    } else if (textField.tag == 2) {
        // end
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
                                     MKCoordinateRegion region = map.region;
                                     region.center = placemark.region.center;
                                     region.span.longitudeDelta /= 8.0;
                                     region.span.latitudeDelta /= 8.0;
                                     
                                     [map setRegion:region animated:YES];
                                     [map addAnnotation:placemark];
                                     [to setText:placemark.locality];
                                     [self zoomToFitMapAnnotations:map];
                                     endPoint = placemark.location;
                                 }
                             }];
                             
                         }
                     }
         ];
    }
    else if (textField.tag == 3) {
        // date
    }
    else if (textField.tag == 4) {
        // time
    }
    else if (textField.tag == 5) {
        // seats
    }
    else if (textField.tag == 6) {
        // cost
    }
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)submit:(id)sender {
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:[NSString stringWithFormat:@"%i",arc4random() %500]];
    CKRecord *postRecord = [[CKRecord alloc] initWithRecordType:@"Rides" recordID:recordID];
    postRecord[@"date"] = actualDate;
    postRecord[@"time"] = actualTime;
    postRecord[@"end"] = endPoint;
    postRecord[@"start"] = location;
    postRecord[@"name"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    postRecord[@"phone"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"phone"];
    postRecord[@"seats"] = [NSNumber numberWithInt:seats.text.intValue];
    postRecord[@"price"] = [NSNumber numberWithInt:price.text.intValue];
    postRecord[@"plainStart"] = from.text;
    postRecord[@"plainEnd"] = to.text;
    postRecord[@"zipStart"] = [NSNumber numberWithInt:start.postalCode.intValue];
    postRecord[@"zipEnd"] = [NSNumber numberWithInt:end.postalCode.intValue];
    CKDatabase *publicDatabase = [[CKContainer defaultContainer] publicCloudDatabase];
    [publicDatabase saveRecord:postRecord completionHandler:^(CKRecord *record, NSError *error) {
        if(error) {
            NSLog(@"%@",error.localizedDescription);
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}


-(void)loadMap {
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks && placemarks.count > 0) {
            CLPlacemark *topResult = [placemarks objectAtIndex:0];
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
            start = placemark;
            MKCoordinateRegion region = map.region;
            region.center = placemark.region.center;
            region.span.longitudeDelta /= 8.0;
            region.span.latitudeDelta /= 8.0;
            
            [map setRegion:region animated:YES];
            [map addAnnotation:placemark];
            [from setText:placemark.locality];
        }
    }];
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

@end
