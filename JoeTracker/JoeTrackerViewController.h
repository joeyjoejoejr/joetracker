//
//  JoeTrackerViewController.h
//  JoeTracker
//
//  Created by Joseph Jackson on 2/17/14.
//  Copyright (c) 2014 Joseph Jackson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface JoeTrackerViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *altitudeField;
@property (weak, nonatomic) IBOutlet UITextField *altitudeAccuracyField;
@property (weak, nonatomic) IBOutlet UITextField *latitudeField;
@property (weak, nonatomic) IBOutlet UITextField *longitudeField;
@property (weak, nonatomic) IBOutlet UITextField *hAccuracyField;
@property (weak, nonatomic) IBOutlet UITextField *updateField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *moodSegment;
@property (strong) UIImage *chosenImage;
- (IBAction)getCurrentLocation:(id)sender;
- (IBAction)saveInformation:(id)sender;
- (IBAction)takePhoto:(UIBarButtonItem *)sender;
- (IBAction)findPhoto:(UIBarButtonItem *)sender;
- (IBAction)uploadPhotos:(UIBarButtonItem *)sender;
@end
