//
//  VPPLocationController.h
//  VPPLibraries
//
//  Created by Víctor on 19/10/11.
//  Copyright 2011 Víctor Pena Placer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "VPPLocationControllerLocationDelegate.h"
#import "VPPLocationControllerGeocoderDelegate.h"
#import <MapKit/MapKit.h>

/**
 VPPLocation Library simplifies the task of retrieving the user location and
 geocoder info about it. 
 
 In order to use it you should implement:
 
 - VPPLocationControllerLocationDelegate to receive updates of the user
 location.
 - VPPLocationControllerGeocoderDelegate to receive updates of information
 about user location.

Once implemented just add your class as delegate, using the methods 
addLocationDelegate: and addGeocoderDelegate:.
 
 @warning **Important** This library depends on CoreLocation framework, 
 MapKit framework and SynthesizeSingleton library (by Matt Gallagher).
 
 @warning **Important** MKReverseGeocoder has been deprecated with the new
 CLGeocoder class included in iOS 5. Check out
 http://developer.apple.com/library/ios/#documentation/MapKit/Reference/MKReverseGeocoder_Class/Reference/Reference.html
 and http://developer.apple.com/library/ios/#documentation/CoreLocation/Reference/CLGeocoder_class/Reference/Reference.html#//apple_ref/occ/cl/CLGeocoder
 for further information. Take into account that this library still uses
 MKReverseGeocoder to give support to iOS 4.
*/ 
 


@interface VPPLocationController : NSObject <CLLocationManagerDelegate, MKReverseGeocoderDelegate> {
@private
	CLLocationManager* manager_;
	CLLocation* currentLocation_;
	NSMutableArray *locationDelegates_;
	BOOL locationDelegatesLocked;	
	NSDate *startDate_;
	NSError *gpsError_;

	NSMutableArray *geocoderDelegates_;	
	MKReverseGeocoder *geoCoder_;
	BOOL geocoderDelegatesLocked;
	NSError *geocoderError_;
	MKPlacemark *currentPlacemark_;
}


/** ---
 @name Accessing to VPPLocationController 
 */

/** Returns singleton instance of VPPLocationController */
+ (VPPLocationController*) sharedInstance;


/** ---
 @name General configuration
 */

/** Indicates the desired location accuracy. 
 
 CLLocationAccuracy values are:
 
 - kCLLocationAccuracyBestForNavigation
 - kCLLocationAccuracyBest
 - kCLLocationAccuracyNearestTenMeters
 - kCLLocationAccuracyHundredMeters
 - kCLLocationAccuracyKilometer
 - kCLLocationAccuracyThreeKilometers 
 
 @warning **Important** Note that this accuracy is not guaranteed, and that the better the accurary, 
 the faster the battery gets drained. */
@property (nonatomic, assign) CLLocationAccuracy desiredLocationAccuracy;

/** Indicates if repeated location updates should be ignored. */
@property (nonatomic, assign) BOOL shouldRejectRepeatedLocations;


/** Indicates if location updates must be strict. 
 
 In a nutshell, strict mode checks if points are:
 
 - invalid accuracy
 - out of order
 - before the manager was initialized
 
 Check out http://troybrant.net/blog/2010/02/detecting-bad-corelocation-data/ 
 for further information.
 */
@property (nonatomic, assign) BOOL strictMode;


/** ---
 @name Current location state
 */

/** Holds current location. `nil` if no valid location has been received yet. */
@property (nonatomic, readonly) CLLocation *currentLocation;
/** Holds current placemark. `nil` if no valid placemark has been received yet. */
@property (nonatomic, readonly) MKPlacemark *currentPlacemark;




/** ---
 @name Managing delegates
 */

/** Adds a new location delegate. Each time a new location arrives, all delegates
 are notified. 
 
 Furthermore, if a valid location exists when the delegate is added, it is 
 instantly notified.
 */
- (void) addLocationDelegate:(id<VPPLocationControllerLocationDelegate>)delegate;

/** Removes, if exists, a location delegate. */
- (void) removeLocationDelegate:(id<VPPLocationControllerLocationDelegate>)delegate;


/** Adds a new geocoder delegate. Each time a new placemark arrives, all delegates
 are notified. 
 
 Furthermore, if a valid placemark exists when the delegate is added, it is 
 instantly notified.
 */- (void) addGeocoderDelegate:(id<VPPLocationControllerGeocoderDelegate>)delegate;

/** Removes, if exists, a geocoder delegate. */
- (void) removeGeocoderDelegate:(id<VPPLocationControllerGeocoderDelegate>)delegate;


/** ---
 @name Pausing and resuming Location Controller 
 */

/** Pauses listening to location updates. */
- (void) pauseUpdatingLocation;

/** Resumes (or starts) listening to location updates. */
- (void) resumeUpdatingLocation;
	
	
@end
