//
// VPPLocationController.m
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


#import "VPPLocationController.h"
#import "SynthesizeSingleton.h"




/*
 indicates if location validation should be strict or not
 0: non strict
 1: strict
 
 in a nutshell, strict mode checks if points are:
 - invalid accuracy
 - out of order
 - before the manager was initialized
 
 check out http://troybrant.net/blog/2010/02/detecting-bad-corelocation-data/ 
 for further information.
 
 */
#define kVPPLocationControllerStrictMode 0


/* Defines desired accuracy. Valid options are:
 
 - kCLLocationAccuracyBestForNavigation
 - kCLLocationAccuracyBest
 - kCLLocationAccuracyNearestTenMeters
 - kCLLocationAccuracyHundredMeters
 - kCLLocationAccuracyKilometer
 - kCLLocationAccuracyThreeKilometers
 */
#define kVPPLocationControllerDesiredAccuracy kCLLocationAccuracyKilometer


/* indicates if repeated locations should be rejected or not */
#define kVPPLocationShouldRejectRepeatedLocations 0






#pragma mark - private notification methods

// holds declaration of notification methods
@interface VPPLocationController (Notification)

- (void) notifyAllLocationListenersNewLocation:(CLLocation*)location;
- (void) notifyAllLocationListenersError:(NSError*)error;
- (void) notifyLocationListener:(id<VPPLocationControllerLocationDelegate>)listener newLocation:(CLLocation*)location;
- (void) notifyLocationListener:(id<VPPLocationControllerLocationDelegate>)listener error:(NSError*)error;

- (void) notifyAllGeocoderListenersNewPlacemark:(CLPlacemark*)placemark;
- (void) notifyAllGeocoderListenersError:(NSError*)error;
- (void) notifyGeocoderListener:(id<VPPLocationControllerGeocoderDelegate>)listener newPlacemark:(CLPlacemark*)placemark;
- (void) notifyGeocoderListener:(id<VPPLocationControllerGeocoderDelegate>)listener error:(NSError*)error;

@end

@implementation VPPLocationController (Notification)

- (void) notifyAllLocationListenersLocationAccessDenied {
	locationDelegatesLocked = YES;	
	[locationDelegates_ makeObjectsPerformSelector:@selector(locationDenied) withObject:nil];
	locationDelegatesLocked = NO;	
}

- (void) notifyLocationListenerLocationAccessDenied:(id<VPPLocationControllerLocationDelegate>)listener {
	[listener locationDenied];
}

- (void) notifyAllLocationListenersNewLocation:(CLLocation*)location {
	locationDelegatesLocked = YES;
	[locationDelegates_ makeObjectsPerformSelector:@selector(locationUpdate:) withObject:location];
	locationDelegatesLocked = NO;
}

- (void) notifyAllLocationListenersError:(NSError*)error {
	locationDelegatesLocked = YES;	
	[locationDelegates_ makeObjectsPerformSelector:@selector(locationError:) withObject:error];
    
    if (error.code == kCLErrorDenied) {
        [self notifyAllLocationListenersLocationAccessDenied];
    }
    
	locationDelegatesLocked = NO;	
}

- (void) notifyLocationListener:(id<VPPLocationControllerLocationDelegate>)listener newLocation:(CLLocation*)location {
	[listener locationUpdate:location];
}
- (void) notifyLocationListener:(id<VPPLocationControllerLocationDelegate>)listener error:(NSError*)error {
	[listener locationError:error];
    if (error.code == kCLErrorDenied) {
        [self notifyLocationListenerLocationAccessDenied:listener];
    }
}



- (void) notifyAllGeocoderListenersNewPlacemark:(CLPlacemark*)placemark {
	geocoderDelegatesLocked = YES;
	[geocoderDelegates_ makeObjectsPerformSelector:@selector(geocoderUpdate:) withObject:placemark];
	geocoderDelegatesLocked = NO;
}

- (void) notifyAllGeocoderListenersError:(NSError*)error {
	geocoderDelegatesLocked = YES;	
	[geocoderDelegates_ makeObjectsPerformSelector:@selector(geocoderError:) withObject:error];
	geocoderDelegatesLocked = NO;	
}

- (void) notifyGeocoderListener:(id<VPPLocationControllerGeocoderDelegate>)listener newPlacemark:(CLPlacemark*)placemark {
	[listener geocoderUpdate:placemark];
}
- (void) notifyGeocoderListener:(id<VPPLocationControllerGeocoderDelegate>)listener error:(NSError*)error {
	[listener geocoderError:error];
}

@end

@interface VPPLocationController (Geocoder)

- (void) startSearchingPlacemarkForCoordinate:(CLLocation *)location;
- (void)reverseGeocoder:(CLGeocoder *)geocoder didFailWithError:(NSError *)error;
- (void)reverseGeocoder:(CLGeocoder *)geocoder didFindPlacemark:(CLPlacemark *)placemark;
- (void) startSearchingPlacemarkForCoordinate:(CLLocation *)location;
- (BOOL) isGeocoderEnabled;

@end



@implementation VPPLocationController (Geocoder)


#pragma mark -
#pragma mark CLGeocoderDelegate

- (void)reverseGeocoder:(CLGeocoder *)geocoder didFailWithError:(NSError *)error {
    if (geocoderError_ != nil) {
        [geocoderError_ release];
    }
	geocoderError_ = [error retain];
	
	[self notifyAllGeocoderListenersError:geocoderError_];
	
    if (error.code != kCLErrorGeocodeFoundNoResult && error.code != kCLErrorGeocodeFoundPartialResult) {
        [self startSearchingPlacemarkForCoordinate:self.currentLocation];
    }
}


- (void)reverseGeocoder:(CLGeocoder *)geocoder didFindPlacemark:(CLPlacemark *)placemark {
	[currentPlacemark_ release];
	currentPlacemark_ = [placemark retain];
	
	[self notifyAllGeocoderListenersNewPlacemark:self.currentPlacemark];
}

- (void) startSearchingPlacemarkForCoordinate:(CLLocation *)location {
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks == nil) { // error
            [self reverseGeocoder:geoCoder didFailWithError:error];
        }
        else {
            [self reverseGeocoder:geoCoder didFindPlacemark:[placemarks objectAtIndex:0]];
        }
    }];
    [geoCoder release];
}


- (BOOL) isGeocoderEnabled {
    return [geocoderDelegates_ count] != 0;
}


@end





#pragma mark - VPPLocationController impl


@implementation VPPLocationController
@synthesize currentLocation=currentLocation_;
@synthesize currentPlacemark=currentPlacemark_;
@synthesize desiredLocationAccuracy, strictMode, shouldRejectRepeatedLocations;


#pragma mark - Accesing to the singleton instance

SYNTHESIZE_SINGLETON_FOR_CLASS(VPPLocationController);

+ (VPPLocationController *) sharedInstance {
    BOOL mustInitialize = !sharedVPPLocationController;
    
    VPPLocationController *lc = [VPPLocationController sharedVPPLocationController];
    if (mustInitialize) {
        lc.desiredLocationAccuracy = kVPPLocationControllerDesiredAccuracy;
        lc.shouldRejectRepeatedLocations = kVPPLocationShouldRejectRepeatedLocations;
        lc.strictMode = kVPPLocationControllerStrictMode==1 ? YES : NO;
    }
    
    return lc;
}

#pragma mark - Auxiliar location methods

- (BOOL) isValidLocation:(CLLocation*)location {
	
	// Filter out nil locations
    if (location == nil) {
        return NO;
    }
	
	if (self.strictMode) {
		// Filter out points by invalid accuracy
		if (location.horizontalAccuracy < 0) {
			return NO;
		}
		
		// Filter out points that are out of order
		NSTimeInterval secondsSinceLastPoint =
		[location.timestamp timeIntervalSinceDate:self.currentLocation.timestamp];
		
		if (secondsSinceLastPoint < 0) {
			return NO;
		}
		
		// Filter out points created before the manager was initialized
		NSTimeInterval secondsSinceManagerStarted =
		[location.timestamp timeIntervalSinceDate:startDate_];
		
		if (secondsSinceManagerStarted < 0) {
			return NO;
		}
    }
    
    // The newLocation is good to use
    return YES;
}


#pragma mark -
#pragma mark Managing Location Controller
- (void) startListening {
	if (manager_ == nil) {
		// initializes
		currentLocation_ = nil;
		locationDelegates_ = nil;		
		gpsError_ = nil;
		locationDelegatesLocked = NO;
		startDate_ = [[NSDate alloc] init];
		
		manager_ = [[CLLocationManager alloc] init];
		manager_.delegate = [self retain]; // send loc updates to myself
		manager_.desiredAccuracy = self.desiredLocationAccuracy;
		[manager_ startUpdatingLocation];
	}
}

- (void) stopListening {
	if (manager_ != nil) {
		[manager_ stopUpdatingLocation];	
		[manager_ release];
		manager_ = nil;
	}
	
	// resets
	if (locationDelegates_ != nil) {
		[locationDelegates_ release];
		locationDelegates_ = nil;
	}
	if (gpsError_ != nil) {
		[gpsError_ release];
		gpsError_ = nil;
	}
	if (startDate_ != nil) {
		[startDate_ release];
		startDate_ = nil;
	}
	locationDelegatesLocked = NO;		
}


#pragma mark -
#pragma mark Starting & Stopping

- (void) resumeUpdatingLocation {
    if (manager_ == nil) {
        [self startListening];
    }
	[manager_ startUpdatingLocation];
}

- (void) pauseUpdatingLocation {
	[manager_ stopUpdatingLocation];
}

#pragma mark -
#pragma mark Managing listeners
- (void) addLocationDelegate:(id<VPPLocationControllerLocationDelegate>)delegate {
	if (locationDelegates_ == nil) {
		[self startListening];
		locationDelegates_ = [[NSMutableArray alloc] init];
	}
	if (![locationDelegates_ containsObject:delegate]) {
		[locationDelegates_ addObject:delegate];
	}
	
	if ([self isValidLocation:self.currentLocation]) {
		[self notifyLocationListener:delegate newLocation:self.currentLocation];
	}
	else if (gpsError_ != nil) {
		[self notifyLocationListener:delegate error:gpsError_];
	}
	
}

- (void) removeLocationDelegate:(id<VPPLocationControllerLocationDelegate>)delegate {
	if (locationDelegatesLocked) {
		// delays the operation half a second, and luckyly the delegates 
		// are no longer locked.
		[self performSelector:@selector(removeLocationDelegate:) withObject:delegate afterDelay:0.5];
		return;
	}
	if (locationDelegates_ == nil) {
		return;
	}
	[locationDelegates_ removeObject:delegate];
	if ([locationDelegates_ count] == 0) {
		[self stopListening];
	}
}


- (void) addGeocoderDelegate:(id<VPPLocationControllerGeocoderDelegate>)delegate {
    BOOL mustStart = geocoderDelegates_ == nil;
    
	if (mustStart) {
		geocoderDelegates_ = [[NSMutableArray alloc] init];
	}
	
	if (![geocoderDelegates_ containsObject:delegate]) {
		[geocoderDelegates_ addObject:delegate];
	}
	
	if (self.currentPlacemark) {
		[self notifyGeocoderListener:delegate newPlacemark:self.currentPlacemark];
	}
	else if (geocoderError_ != nil) {
		[self notifyGeocoderListener:delegate error:geocoderError_];
	}
    
	
	if (mustStart && self.currentLocation != nil) {
        [self startSearchingPlacemarkForCoordinate:self.currentLocation];
	}
}

- (void) removeGeocoderDelegate:(id<VPPLocationControllerGeocoderDelegate>)delegate {
	if (geocoderDelegatesLocked) {
		// delays the operation half a second, and luckyly the delegates 
		// are no longer locked.
		[self performSelector:@selector(removeGeocoderDelegate:) withObject:delegate afterDelay:0.5];
		return;
	}
	if (geocoderDelegates_ == nil) {
		return;
	}
	[geocoderDelegates_ removeObject:delegate];
}



#pragma mark -
#pragma mark Location Manager Delegate
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
	// discards possible bad positions
	if ([self isValidLocation:newLocation]) {
        
        /* if location hasn't change, lets omit it */
        if (self.shouldRejectRepeatedLocations && self.currentLocation != nil
            && [self.currentLocation distanceFromLocation:newLocation] == 0) {
            return;
        }
        
        if (gpsError_ != nil) {
            [gpsError_ release];
            gpsError_ = nil;
        }
        if (currentLocation_ != nil) {
            [currentLocation_ release];
        }
        currentLocation_ = [newLocation retain];
        [self notifyAllLocationListenersNewLocation:newLocation];
        
        
        if ([self isGeocoderEnabled]) {
            [self startSearchingPlacemarkForCoordinate:self.currentLocation];
        }
    }
    
}

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error {
	NSLog(@"Location Controller Error: %@", [error description]);
	if (gpsError_ != nil) {
		[gpsError_ release];
	}
	gpsError_ = [error retain];
	[self notifyAllLocationListenersError:error];
}




@end




@implementation CLPlacemark (VPPLocation)

- (NSString *) address {
    NSString *adr = self.thoroughfare;
    if (self.subThoroughfare) {
        adr = [adr stringByAppendingFormat:@", %@",self.subThoroughfare];
    }

    return adr;
}

@end
