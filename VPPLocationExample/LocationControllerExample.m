//
//  LocationControllerExample.m
//  VPPLibraries
//
//  Created by Víctor on 24/10/11.
//  Copyright 2011 Víctor Pena Placer. All rights reserved.
//

#import "LocationControllerExample.h"
#import "VPPLocationController.h"

@implementation LocationControllerExample
@synthesize locations;
@synthesize address;
#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	self.locations = [NSMutableArray array];
	errorGPS = NO;
	[[VPPLocationController sharedInstance] addLocationDelegate:self];
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[VPPLocationController sharedInstance] removeLocationDelegate:self];    
    [[VPPLocationController sharedInstance] removeGeocoderDelegate:self];    
}

/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	switch (section) {
		case 1:
			return [self.locations count];
		case 0:
			return 1;
			break;

		default:
			break;
	}
	
	return 0;

}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	switch (section) {
		case 0:
            if (loadingGeocoder) {
                return @"Loading...";
            }
            if (errorGeocoder) {
                return @"Error with geocoder";
            }
			return address;
		
		case 1:
			if (errorGPS) {
				return @"Whooops, an error has been received.";
			}
			
			return @"Each time a location is received, it will be added here.";
			

		default:
			break;
	}
	
	return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	switch (indexPath.section) {
		case 1:
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			CLLocation *loc = [self.locations objectAtIndex:indexPath.row];
			cell.textLabel.text = [NSString stringWithFormat:@"%f,%f",loc.coordinate.latitude,loc.coordinate.longitude];
			cell.detailTextLabel.text = [loc.timestamp description];
			
			break;
		case 0:
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.textLabel.text = @"Tell me where I am";
            cell.detailTextLabel.text = nil;
			break;

		default:
			break;
	}
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
	switch (indexPath.section) {
		case 0:
			[[VPPLocationController sharedInstance] addGeocoderDelegate:self];
            loadingGeocoder = YES;
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
			
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			break;
		default:
			break;
	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


#pragma mark -
#pragma mark VPPLocationControllerDelegate implementation
- (void) locationUpdate:(CLLocation *)location {
	// resets error information
	errorGPS = NO;
	[self.locations addObject:location];
	NSIndexPath *iP = [NSIndexPath indexPathForRow:[self.locations count]-1 inSection:1];
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:iP] withRowAnimation:UITableViewRowAnimationFade];
}

- (void) locationError:(NSError *)error {
	errorGPS = YES;
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
}

- (void) locationDenied {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@":(" message:@"I would really love to know where you are" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
    [av release];
}

#pragma mark -
#pragma mark VPPLocationControllerGeocoderDelegate implementation
- (void)geocoderUpdate:(MKPlacemark *)placemark {
    loadingGeocoder = NO;
    errorGeocoder = NO;    
	self.address = placemark.address;
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)geocoderError:(NSError *)error {
    loadingGeocoder = NO;
    errorGeocoder = YES;
}

@end

