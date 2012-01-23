//
//  VPPLocationControllerGeocoderDelegate.h
//  VPPLibraries
//
//  Created by Víctor on 31/10/11.
//  Copyright 2011 Víctor Pena Placer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


/** This protocol defines a set of required methods that you must use to receive
 geocoder update messages. */

@protocol VPPLocationControllerGeocoderDelegate

@required
/** Tells the delegate that new geocoder information has been received. */
- (void)geocoderUpdate:(MKPlacemark *)placemark;
/** Tells the delegate that there has been an error with geocoder. */
- (void)geocoderError:(NSError *)error;

@end
