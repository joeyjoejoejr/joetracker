//
//  JoeTrackerViewController.m
//  JoeTracker
//
//  Created by Joseph Jackson on 2/17/14.
//  Copyright (c) 2014 Joseph Jackson. All rights reserved.
//

#import "JoeTrackerViewController.h"
#import <Parse/Parse.h>

@interface JoeTrackerViewController ()

@end

@implementation JoeTrackerViewController

CLLocationManager *locationManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    locationManager = [[CLLocationManager alloc] init];
    self.updateField.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getCurrentLocation:(id)sender {
    locationManager.delegate = (id)self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to get your loaction" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocation *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentlocation = newLocation;
    
    if (currentlocation) {
        _altitudeField.text = [NSString stringWithFormat:@"%.8f", currentlocation.altitude];
        _altitudeAccuracyField.text = [NSString stringWithFormat:@"%.0f", currentlocation.verticalAccuracy];
        _latitudeField.text = [NSString stringWithFormat:@"%.8f", currentlocation.coordinate.latitude];
        _longitudeField.text = [NSString stringWithFormat:@"%.8f", currentlocation.coordinate.longitude];
        _hAccuracyField.text = [NSString stringWithFormat:@"%.0f", currentlocation.horizontalAccuracy];
    }
    
    NSLog(@"Selected Segment: %ld", (long)_moodSegment.selectedSegmentIndex);
    [locationManager stopUpdatingLocation];
}

- (IBAction)saveInformation:(id)sender {
    // Create geopoint object
    PFGeoPoint *joecation = [PFGeoPoint geoPointWithLatitude:[_latitudeField.text doubleValue]
                                                   longitude:[_longitudeField.text doubleValue]];
    // Set up photo
    UIImage *imageData = [self compressForUpload:self.chosenImage: .5];
    NSString *uid = [self fileizeString:self.updateField.text];
    
    // Create new JoeTrack object
    PFObject *joeTrack = [PFObject objectWithClassName:@"Joetrack"];
    joeTrack[@"altitude"] = @([_altitudeField.text doubleValue]);
    joeTrack[@"altitude_accuracy"] = @([_altitudeAccuracyField.text intValue]);
    joeTrack[@"joecation"] = joecation;
    joeTrack[@"joecation_accuracy"] = @([_hAccuracyField.text intValue]);
    joeTrack[@"update"] = _updateField.text;
    joeTrack[@"mood"] = @(_moodSegment.selectedSegmentIndex);
    joeTrack[@"saved_at"] = [NSDate date];
    if (imageData) {
        joeTrack[@"imageWaiting"] = @(YES);
    }
    //joeTrack[@"photo"] = imageFile;
    [self saveImage:imageData forUID:uid];
    [self clearInputs];
    [self setNotification];
    
    [joeTrack saveEventually];
}

- (NSString *)fileizeString: (NSString *)original
{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\W+" options:
                                  NSRegularExpressionCaseInsensitive error:&error];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:original
                                                               options:0 range:NSMakeRange(0, [original length])
                                                          withTemplate:@""];
    NSLog(@"%@", modifiedString);
    return modifiedString;
}

- (IBAction)takePhoto:(UIBarButtonItem *)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = (id)self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)findPhoto:(UIBarButtonItem *)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = (id)self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.chosenImage  = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void) setNotification
{
    NSDate *currentDate = [NSDate date];
    int twoHours = 60 * 120;
    int randomTime = arc4random_uniform(60 * 120);
    int timeToAdd = twoHours + randomTime;
    NSDate *datePlusTime = [currentDate dateByAddingTimeInterval:timeToAdd];
    
    //Schedule the notification
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = datePlusTime;
    localNotification.alertBody = @"Time to track Joe.";
    localNotification.alertAction = @"Track that Joe";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (UIImage *)compressForUpload:(UIImage *)original :(CGFloat)scale
{
    // Calculate new size given scale factor.
    CGSize originalSize = original.size;
    CGSize newSize = CGSizeMake(originalSize.width * scale, originalSize.height * scale);
    
    // Scale the original image to match the new size.
    UIGraphicsBeginImageContext(newSize);
    [original drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* compressedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return compressedImage;
}


- (void)saveImage: (UIImage*)image forUID: (NSString *)uid
{
    if (image != nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:
                          [uid stringByAppendingString:@".png"]];
        NSLog(@"File Path: %@", path);
        NSData* data = UIImagePNGRepresentation(image);
        [data writeToFile:path atomically:YES];
    }
}

- (void)clearInputs
{
    _altitudeField.text = nil;
    _altitudeAccuracyField.text = nil;
    _latitudeField.text = nil;
    _longitudeField.text = nil;
    _hAccuracyField.text = nil;
    _updateField.text = nil;
    _moodSegment.selectedSegmentIndex = 2;
    _chosenImage = NULL;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}



@end
