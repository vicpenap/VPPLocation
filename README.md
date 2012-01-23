VPPLocation Library simplifies the task of retrieving the user location and
 geocoder info about it. 
 
 In order to use it you should implement:
 
 - VPPLocationControllerLocationDelegate to receive updates of the user
 location.
 - VPPLocationControllerGeocoderDelegate to receive updates of information
 about user location.

Once implemented just add your class as delegate, using the methods 
addLocationDelegate: and addGeocoderDelegate:. Now your class will be 
happily working :)

For further information check out 
http://vicpenap.github.com/VPPLocation
