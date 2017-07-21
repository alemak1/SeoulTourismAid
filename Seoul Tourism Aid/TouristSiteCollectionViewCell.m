//
//  TouristSiteCollectionViewCell.m
//  GDJHostel
//
//  Created by Aleksander Makedonski on 6/25/17.
//  Copyright © 2017 AlexMakedonski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TouristSiteCollectionViewCell.h"
#import "UIView+HelperMethods.h"
#import "UserLocationManager.h"
#import "Constants.h"

@interface TouristSiteCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *siteImageView;


@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak,nonatomic) IBOutlet UILabel *isOpenStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

//Each tourist site cell has detail and directions buttons that perform segues whose string identifiers are configured to match tourist site names or ids; the view controllers that are presented modally can be configured in the storyboard and instantiated using the segue identifiers; tourist site detail and location information can be passed to the dstinationed view controller through the segue; in the prepare for segue method, set exposed properties (corresponding to site location and details) in the prepare for segue method

- (IBAction)getDirectionsForTouristSite:(id)sender;

- (IBAction)getDetailsForTouristSite:(id)sender;



@end



@implementation TouristSiteCollectionViewCell

static void *TouristConfigurationContext = &TouristConfigurationContext;

/** The TouristSiteCollectionViewCell can observe it's tourist configuration object; make sure that tourist configuration object's computed properties also are KVO compliant **/



/** Implement getters and setters for labels and image view **/



-(void)setTitleText:(NSString *)titleText{
    
    [self.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.titleLabel setMinimumScaleFactor:0.50];
    
    [self.titleLabel setText:titleText];
    [self layoutIfNeeded];
}

-(NSString *)titleText{
    return [self.titleLabel text];
}

-(void)setSiteImage:(UIImage *)siteImage{
    
    [self.siteImageView setImage:siteImage];
    [self layoutIfNeeded];
}

-(UIImage *)siteImage{
    
    return [self.siteImageView image];
}


-(void)setIsOpenStatusLabel:(UILabel*)isOpenStatusLabel{
    
    [self.isOpenStatusLabel setAdjustsFontSizeToFitWidth:YES];
    [self.isOpenStatusLabel setMinimumScaleFactor:0.50];
    
    [self.isOpenStatusLabel setText:self.isOpenStatusText];
}

-(NSString *)isOpenStatusText{
    return [self.isOpenStatusLabel text];
}

-(void)setDistanceToSiteText:(NSString *)distanceToSiteText{
    
    NSString* labelString;
    
    if(distanceToSiteText){
   
        labelString = [labelString stringByAppendingString:@"Distance Away: "];
        
        labelString = [labelString stringByAppendingString:distanceToSiteText];
    
        labelString = [labelString stringByAppendingString:@" km"];
    }
    
    if(!labelString){
        [self.distanceLabel setText:@"Getting distance..."];
    } else{
        [self.distanceLabel setText:labelString];

    }
    
    
}

-(NSString *)distanceToSiteText{
    return [self.distanceLabel text];
}


- (IBAction)getDirectionsForTouristSite:(id)sender {
    
    
    CLLocationDegrees toLatitude = self.touristSiteConfigurationObject.location.coordinate.latitude;
    CLLocationDegrees toLongitude = self.touristSiteConfigurationObject.location.coordinate.longitude;
    
    MKPlacemark* toPlacemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(toLatitude, toLongitude)];
    
    MKMapItem* toMapItem = [[MKMapItem alloc] initWithPlacemark:toPlacemark];
    
    CLLocation* userLocation = [[UserLocationManager sharedLocationManager] getLastUpdatedUserLocation];
    
    MKPlacemark* userLocationPlacemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude)];
    
    MKMapItem* fromMapItem = [[MKMapItem alloc] initWithPlacemark:userLocationPlacemark];
    
    // Create a region centered on the starting point with a 10km span
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(toPlacemark.coordinate, 10000, 10000);
    
    // Open the item in Maps, specifying the map region to display.
    [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:toMapItem,fromMapItem, nil]
                   launchOptions:[NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSValue valueWithMKCoordinate:region.center], MKLaunchOptionsMapCenterKey,
                                  [NSValue valueWithMKCoordinateSpan:region.span], MKLaunchOptionsMapSpanKey, nil]];
}

- (IBAction)getDetailsForTouristSite:(id)sender {
    
    /** Since this collection view cell is a subview of a collecion view that is being managed by a viewcontroller, which in turn is a child view controller for paret view contrller that is the root view of a navigation controller, posting notification is best option to  transfer data **/
    
    //Send notification and pass data so that the TouristCategorySelectionController's navigation controller can present the detail controller
    
    NSDictionary* userInfoDict = [NSDictionary dictionaryWithObjectsAndKeys:self.touristSiteConfigurationObject,@"touristSiteConfiguration", nil];
    
    
    NSLog(@"From tourist site collection view cell.  Name: %@, Lat/Long: %f,%f",[self.touristSiteConfigurationObject name],self.touristSiteConfigurationObject.midCoordinate.latitude,self.touristSiteConfigurationObject.midCoordinate.longitude);
    
    NSLog(@"Sending userInfoDict %@",[userInfoDict description]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DID_REQUEST_LOAD_TOURIST_SITE_DETAIL_CONTROLLER object:self userInfo:userInfoDict];
}



@end