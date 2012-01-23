//
//  VPPLocationControllerLocationDelegate.h
//  VPPLibraries
//
//  Created by Víctor on 19/10/11.
//  Copyright 2011 Víctor Pena Placer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/** This protocol defines a set of required methods that you must use to receive
 location update messages. */

@protocol VPPLocationControllerLocationDelegate

@required
/** Tells the delegate that new location information has been received. */
- (void)locationUpdate:(CLLocation *)location;

/** Tells the delegate that there has been an error with the location. */
- (void)locationError:(NSError *)error;

/** Notifies the delegate that access to location information is denied. */
- (void)locationDenied;

@end
