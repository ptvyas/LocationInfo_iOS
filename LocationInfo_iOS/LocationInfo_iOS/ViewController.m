//
//  ViewController.m
//  LocationInfo_iOS
//
//  Copyright © 2017 Vyas. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

#define durationAnimation   0.30f
#define _keyAddress                         @"Address"
#define _keyCity                            @"City"
#define _keyZip                             @"Zip"
#define _keyState                           @"State"
#define _keyCountry                         @"Country"
#define _keyLatitude                        @"Latitude"
#define _keyLongitude                       @"Longitude"

@interface ViewController ()
{
    CLLocation *location;
    NSMutableDictionary *dicLocationInfo;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //-------------------------------->
    dicLocationInfo = [[NSMutableDictionary alloc] init];
    
    
    //-------------------------------->
    //MapView
    mapview.showsUserLocation = YES;
    
    //-------------------------------->
    //Loading-View
    viewLoading.layer.cornerRadius = 5;
    viewLoading.layer.borderColor = [UIColor lightGrayColor].CGColor;
    viewLoading.layer.borderWidth = 1.0f;
    viewLoading.layer.masksToBounds = YES;
    
    lblLoading.text = @"Loading...";
    lblLoading.numberOfLines = 0;
    
    //-------------------------------->
    //Address-View
    viewAddress.layer.cornerRadius = 5;
    viewAddress.layer.borderColor = [UIColor lightGrayColor].CGColor;
    viewAddress.layer.borderWidth = 1.0f;
    viewAddress.layer.masksToBounds = YES;
    
    lblAddress.text = @"";
    lblAddress.numberOfLines = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void) manage_loader_GeetingAddress_isShow:(BOOL)isShow
{
    viewLoading.hidden = YES;
    
    if (isShow == YES) {
        viewLoading.hidden = NO;
    }
}

- (void) manage_Animation_AddressView_Show:(BOOL)show
{
    if (show == NO)
    {
        //Hide Button With Animation
        [UIView animateWithDuration:0.30f
                         animations:^{
                             lc_ViewAddress_y.constant = -(30 + viewAddress.frame.size.height);
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL finished)
        {
            //Code
        }];
    }
    else
    {
        if (dicLocationInfo.count == 0)
        {
            [self manage_Animation_AddressView_Show:NO];
            return;
        }
        
        //Set Button Title
        NSString *strAddress = [NSString stringWithFormat:@"%@",[dicLocationInfo valueForKeyPath:_keyAddress]];
        lblAddress.text = strAddress;
        lblAddress.numberOfLines = 4;
        
        //Show Button With Animation
        [UIView animateWithDuration:0.30f
                         animations:^{
                             lc_ViewAddress_y.constant = 30;
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL finished)
         {
             //Code
         }];
    }
}

- (BOOL) string_isEmpty:(NSString *)str {
    if(str.length==0
       || [str isKindOfClass:[NSNull class]]
       || [str isEqualToString:@""]
       || [str isEqualToString:NULL]
       || [str isEqualToString:@"(null)"]
       || [str isEqualToString:[@"(null)" uppercaseString]]
       || str==nil
       || [str isEqualToString:@"<null>"]
       || [str isEqualToString:[@"<null>" uppercaseString]]) {
        return YES;
    }
    return NO;
}

- (void) showAlertMessage:(NSString *)strMess autoHide:(BOOL)autoHide
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[@"Location Info" uppercaseString] message:strMess preferredStyle:UIAlertControllerStyleAlert];
    
    //Auto Dismiss
    if (autoHide == YES) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alertController dismissViewControllerAnimated:YES completion:^{ //Set Completion Code
            }];
        });
    }
    else {
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                    {
                                        //Set Completion Code
                                    }]];
    }
    //Show Alert
    //[view presentViewController:alertController animated:YES completion:nil]; //set VC object for show alert
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];
}

- (NSString *) keyExisteOnDictionary:(NSMutableDictionary *)dic key:(NSString *)strKey
{
    if([dic valueForKey:@"strKey"] != nil) {
        // The key existed...
        //return YES;
        return @" ";
    }
    else {
        // No joy...
        //return NO;
        return [dic valueForKey:strKey];
    }
    //return NO;
    return @" ";
}

#pragma mark - MapView Delegate Method
-(void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    //return;
    NSLog(@"%f %f",mapview.centerCoordinate.latitude,mapview.centerCoordinate.longitude);
    
    CLLocation *locationCenter = [[CLLocation alloc] initWithLatitude:mapView.centerCoordinate.latitude longitude:mapView.centerCoordinate.longitude];
    if (locationCenter == location) {
        NSLog(@"same Location");
        return;
    }
    
    
    [self manage_loader_GeetingAddress_isShow:YES];
    
    lblAddress.text = @"";
    dicLocationInfo = [[NSMutableDictionary alloc] init];
    
    location = [[CLLocation alloc] initWithLatitude:mapView.centerCoordinate.latitude longitude:mapView.centerCoordinate.longitude];
    [self getAddressOnAddPinLocation:location];
}

#pragma mark MapView related method
-(void) getAddressOnAddPinLocation:(CLLocation *)locations
{
    dicLocationInfo = [[NSMutableDictionary alloc] init];
    lblAddress.text = @"";
    [self manage_Animation_AddressView_Show:NO];
    
    [self manage_loader_GeetingAddress_isShow:YES];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:locations completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!(error)) {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             //NSLog(@"\nCurrent Location Detected\n");
             //NSLog(@"placemark: %@",placemark);
             NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@","];
             
             if ([self string_isEmpty:locatedAt] == YES) {
                 [self showAlertMessage:@"Unable to get place name \nPlease try again." autoHide:NO];
                 return;
             }
             
             NSString *Address = @"";
             NSString *City = @"";
             NSString *ZipCode = @"";
             NSString *State = @"";
             NSString *Country = @"";
             NSString *Latitude = @"";
             NSString *Longitude = @"";
             
             NSMutableDictionary *placeInfo = [[NSMutableDictionary alloc] init];
             placeInfo = [placemark.addressDictionary mutableCopy];
             //NSLog(@"placeInfo: %@",placeInfo);
             
             Address = [[NSString alloc]initWithString:locatedAt];
             City = [self keyExisteOnDictionary:placeInfo key:@"SubLocality"];
             ZipCode = [self keyExisteOnDictionary:placeInfo key:@"ZIP"];
             State = [self keyExisteOnDictionary:placeInfo key:@"State"];
             Country = [self keyExisteOnDictionary:placeInfo key:@"Country"];
             Latitude = [NSString stringWithFormat:@"%f",placemark.location.coordinate.latitude];
             Longitude = [NSString stringWithFormat:@"%f",placemark.location.coordinate.longitude];
             
             dicLocationInfo = [[NSMutableDictionary alloc] init];
             [dicLocationInfo setValue:Address forKey:_keyAddress];
             [dicLocationInfo setValue:City forKey:_keyCity];
             [dicLocationInfo setValue:ZipCode forKey:_keyZip];
             [dicLocationInfo setValue:State forKey:_keyState];
             [dicLocationInfo setValue:Country forKey:_keyCountry];
             [dicLocationInfo setValue:Latitude forKey:_keyLatitude];
             [dicLocationInfo setValue:Longitude forKey:_keyLongitude];
             
             lblAddress.text = Address;
             
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 if (Address.length==0 || City.length==0 || ZipCode.length==0 || State.length==0 || Country.length==0) {
                     [self manage_Animation_AddressView_Show:YES];
                 }
                 else {
                     [self manage_Animation_AddressView_Show:YES];
                 }
             });
             NSLog(@"address: %@",lblAddress.text);
         }
         else {
             //NSLog(@"Geocode failed with error %@", error);
             //NSLog(@"\nCurrent Location Not Detected\n");
             //return;
             
             lblAddress.text = @"";
             [self showAlertMessage:@"Failed to Get Location address" autoHide:NO];
         }
         /*---- For more results
          placemark.region);
          placemark.country);
          placemark.locality);
          placemark.name);
          placemark.ocean);
          placemark.postalCode);
          placemark.subLocality);
          placemark.location);
          ------*/
         
         //[self loaderOnTitlebar_isShow:NO];
         [self manage_loader_GeetingAddress_isShow:NO];
     }];
}


@end
