//
//  VPPLocationController.h
//  VPPLibraries
//
//  Created by Víctor on 19/10/11.

// 	Copyright (c) 2012 Víctor Pena Placer (@vicpenap)
// 	http://www.victorpena.es/
// 	
// 	
// 	Permission is hereby granted, free of charge, to any person obtaining a copy 
// 	of this software and associated documentation files (the "Software"), to deal
// 	in the Software without restriction, including without limitation the rights 
// 	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
// 	copies of the Software, and to permit persons to whom the Software is furnished
// 	to do so, subject to the following conditions:
// 	
// 	The above copyright notice and this permission notice shall be included in
// 	all copies or substantial portions of the Software.
// 	
// 	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// 	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// 	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// 	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// 	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
// 	IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "VPPLocationControllerLocationDelegate.h"
#import "VPPLocationControllerGeocoderDelegate.h"


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
 
 */ 
 


@interface VPPLocationController : NSObject <CLLocationManagerDelegate> {
@private
	CLLocationManager *manager_;
	CLLocation* currentLocation_;
	NSMutableArray *locationDelegates_;
	BOOL locationDelegatesLocked;	
	NSDate *startDate_;
	NSError *gpsError_;

	NSMutableArray *geocoderDelegates_;	
	BOOL geocoderDelegatesLocked;
	NSError *geocoderError_;
	CLPlacemark *currentPlacemark_;
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
@property (nonatomic, readonly) CLPlacemark *currentPlacemark;




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



/** This CLPlacemark category adds some useful accesory methods. */

@interface CLPlacemark (VPPLocation)

/** Returns a smart address formatted string, based on `thoroughfare` and 
 `subThoroughfare` properties.
 
 If both are different than `nil`, the returned string will be 
 `thoroughfare, subThoroughfare`. In case `subThoroughfare` is `nil`, the 
 returned string will be `thoroughfare`.
 */
@property (nonatomic, readonly) NSString *address;

@end
