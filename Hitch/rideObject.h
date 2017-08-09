//
//  rideObject.h
//  Hitch
//
//  Created by Robert Crosby on 8/7/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface rideObject : NSObject
@property (nonatomic,strong) NSString *plainStart;
@property (nonatomic,strong) NSString *plainEnd;
@property (nonatomic,strong) CLLocation *start;
@property (nonatomic,strong) CLLocation *end;
@property (nonatomic,strong) NSDate *date;
@property (nonatomic,strong) NSDate *time;
@property (nonatomic,strong) NSNumber *seats;
@property (nonatomic,strong) NSNumber *price;
@property (nonatomic,strong) NSMutableArray *messages;
@property (nonatomic,strong) NSMutableArray *riders;
@property (nonatomic,strong) NSMutableArray *requests;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *phone;
-(instancetype)initWithType:(CLLocation*)start andEnd:(CLLocation*)end andDate:(NSDate*)date andTime:(NSDate*)time andSeats:(NSNumber*)seats andPrice:(NSNumber*)price andMessages:(NSMutableArray*)messages andRiders:(NSMutableArray*)riders andName:(NSString*)name andPlainStart:(NSString*)plainStart andPlainEnd:(NSString*)plainEnd andPhone:(NSString*)phone andRequests:(NSMutableArray*)requests;

@end
