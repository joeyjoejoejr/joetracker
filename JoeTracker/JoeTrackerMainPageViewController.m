//
//  JoeTrackerMainPageViewController.m
//  JoeTracker
//
//  Created by Joseph Jackson on 2/28/14.
//  Copyright (c) 2014 Joseph Jackson. All rights reserved.
//

#import "JoeTrackerMainPageViewController.h"
#import <Parse/Parse.h>

@interface JoeTrackerMainPageViewController ()

@end

@implementation JoeTrackerMainPageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.numberPhotosToUpload.layer.cornerRadius = 8;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"Joetrack"];
    [query whereKey:@"imageWaiting" equalTo:[NSNumber numberWithBool:YES]];
    [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if(!error) {
            NSLog(@"Leaded %d objects", count);
            self.numberPhotosToUpload.text = [@(count) description];
        } else {
            NSLog(@"Error loading objects: %@", error);
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row == 1  && [self.numberPhotosToUpload.text intValue] >= 1) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Photo Upload" message:@"Upload photos now?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        PFQuery *query = [PFQuery queryWithClassName:@"Joetrack"];
        [query whereKey:@"imageWaiting" equalTo:@(YES)];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %lu joetrack.", objects.count);
                int i = 1;
                // Do something with the found objects
                for (PFObject *object in objects) {
                    NSString *uid = [self fileizeString: object[@"update"]];
                    UIImage *imageFile = [self loadImageforUID:uid];
                    NSData *imageData = UIImagePNGRepresentation(imageFile);
                    PFFile *image = [PFFile fileWithName:[uid stringByAppendingPathExtension:@"png"] data:imageData];
                    NSLog(@"%@", object.objectId);
                    object[@"imageWaiting"] = @NO;
                    object[@"photo"] = image;
                    [object saveInBackground];
                    [self removeImage:uid];
                    self.numberPhotosToUpload.text = [@([objects count] - i) description];
                    i++;
                }
            } else {
                UIAlertView *unreachableNetwork=[[UIAlertView alloc]initWithTitle:@"Unreachable:"
                                                                          message:@"Try your upload again later"
                                                                         delegate:self
                                                                cancelButtonTitle:@"Close"
                                                                otherButtonTitles:nil];
                [unreachableNetwork show];
            }
        }];
    }
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

- (UIImage*)loadImageforUID: (NSString *)uid
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:
                      [uid stringByAppendingString:@".png"]];
    NSLog(@"File Path: %@", path);
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}

- (void)removeImage:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                   NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:[fileName stringByAppendingString:@".png"]];
    NSLog(@"File Path: %@", filePath);
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (!success) {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}

@end
