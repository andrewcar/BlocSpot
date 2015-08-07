//
//  POI.h
//  BlocSpot
//
//  Created by Andrew Carvajal on 7/27/15.
//  Copyright (c) 2015 Andrew Carvajal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface POI : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

- (instancetype)initWithCoord:(CLLocationCoordinate2D)coord title:(NSString *)title subtitle:(NSString *)subtitle;

@end
