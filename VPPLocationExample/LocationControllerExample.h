//
//  LocationControllerExample.h
//  VPPLibraries
//
//  Created by Víctor on 24/10/11.
//  Copyright 2011 Víctor Pena Placer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPPLocationControllerLocationDelegate.h"
#import "VPPLocationControllerGeocoderDelegate.h"

@interface LocationControllerExample : UITableViewController <VPPLocationControllerLocationDelegate,
VPPLocationControllerGeocoderDelegate> {
	
@private
	BOOL errorGPS;
    BOOL loadingGeocoder;
    BOOL errorGeocoder;
}

@property (nonatomic, retain) NSMutableArray *locations;
@property (nonatomic, retain) NSString *address;

@end
