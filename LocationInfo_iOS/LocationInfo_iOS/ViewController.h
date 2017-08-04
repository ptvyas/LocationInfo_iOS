//
//  ViewController.h
//  LocationInfo_iOS
//
//  Copyright © 2017 Vyas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController
{
    __weak IBOutlet MKMapView *mapview;
    
    __weak IBOutlet UIView *viewLoading;
    __weak IBOutlet UILabel *lblLoading;
    
    __weak IBOutlet UIView *viewAddress;
    __weak IBOutlet NSLayoutConstraint *lc_ViewAddress_y;
    __weak IBOutlet UILabel *lblAddress;
}
@end

