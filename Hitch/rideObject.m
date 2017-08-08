//
//  rideObject.m
//  Hitch
//
//  Created by Robert Crosby on 8/7/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "rideObject.h"

@implementation rideObject
-(instancetype)initWithType:(CLLocation*)start andEnd:(CLLocation*)end andDate:(NSDate*)date andTime:(NSDate*)time andSeats:(NSNumber*)seats andPrice:(NSNumber*)price andMessages:(NSMutableArray*)messages andRiders:(NSMutableArray*)riders andName:(NSString*)name andPlainStart:(NSString*)plainStart andPlainEnd:(NSString*)plainEnd andPhone:(NSString*)phone{
    self = [super init];
    if(self)
    {
        self.start = start;
        self.end = end;
        self.date = date;
        self.time = time;
        self.seats = seats;
        self.price = price;
        self.messages = messages;
        self.riders = riders;
        self.name = name;
        self.plainStart = plainStart;
        self.plainEnd = plainEnd;
        self.phone = phone;
    }
    return self;
}

@end
