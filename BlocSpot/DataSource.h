//
//  DataSource.h
//  BlocSpot
//
//  Created by Andrew Carvajal on 7/27/15.
//  Copyright (c) 2015 Andrew Carvajal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef void (^NewItemCompletionBlock)(NSError *error);

@interface DataSource : NSObject

@property (nonatomic, strong) NSMutableArray *placemarks;
@property (nonatomic, strong) MKPlacemark *tappedPlacemarkOnCell;

+ (instancetype)sharedInstance;

@end
