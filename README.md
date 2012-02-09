# VPPLocation v3.0.0b

VPPLocation Library for iOS simplifies the task of retrieving the user 
location and reverse geocoder info about it. 

In order to use it you should implement:
 
- VPPLocationControllerLocationDelegate to receive updates of the user
location.
- VPPLocationControllerGeocoderDelegate to receive updates of information
about user location, such as city name or address (`MKPlacemark` object).

Once implemented just add your class as delegate, using the methods 
addLocationDelegate: and addGeocoderDelegate:. Now your class will be 
happily working :)

Geocoding feature is adapted to both iOS 4 and 5. If device is running iOS 
4, MKReverseGeocoder class will be used. If device is running iOS 5, CLGeocoder
new class will be used. In any case the placemark object will be instance of
MKPlacemark.

This project contains a sample application using it. Just open the project in 
XCode, build it and run it. 

For full documentation check out 
http://vicpenap.github.com/VPPLocation

## Changelog 
- 2012/02/09 (v3.0.0)
    - Library geocoding adapted to both iOS 4 and 5. If device is running iOS 
4, MKReverseGeocoder class will be used. If device is running iOS 5, CLGeocoder
new class will be used. In any case the placemark will be a MKPlacemark.
- 2012/02/08 (v2.0.0)
    - Removed all references to MKReverseGeocoder and MKPlacemark
and updated all code to use new CLGeocoder instead. This class 
appeared in iOS 5.
    - Also included a tiny CLPlacemark category to add a new property,
address, which will return a formatted address string.

- 2012/01/31 (v1.0.0): resumeUpdatingLocation will start the location manager if it hasn't been previously started.

## License 

Copyright (c) 2012 Víctor Pena Placer ([@vicpenap](http://www.twitter.com/vicpenap))
http://www.victorpena.es/


Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

