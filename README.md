VPPLocation Library for iOS simplifies the task of retrieving the user 
location and geocoder info about it. 

Library is in [VPPLocation/Libraries/VPPLocation](https://github.com/vicpenap/VPPLocation/tree/master/VPPLocation/Libraries/VPPLocation). Also a copy of 
SynthesizeSingleton is included.
 
In order to use it you should implement:
 
- VPPLocationControllerLocationDelegate to receive updates of the user
location.
- VPPLocationControllerGeocoderDelegate to receive updates of information
about user location.

Once implemented just add your class as delegate, using the methods 
addLocationDelegate: and addGeocoderDelegate:. Now your class will be 
happily working :)

This project contains a sample application using it. Just open the project in 
XCode, build it and run it. 


For full documentation check out 
http://vicpenap.github.com/VPPLocation
