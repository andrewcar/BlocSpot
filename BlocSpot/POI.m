//
//  POI.m
//  BlocSpot
//
//  Created by Andrew Carvajal on 7/27/15.
//  Copyright (c) 2015 Andrew Carvajal. All rights reserved.
//

#import "POI.h"

@implementation POI

- (instancetype)initWithCoord:(CLLocationCoordinate2D)coord title:(NSString *)title subtitle:(NSString *)subtitle {
    if (self = [super init]) {
        _coordinate = coord;
        _title = title;
        _subtitle = subtitle;
    }
    return self;
}

@end
