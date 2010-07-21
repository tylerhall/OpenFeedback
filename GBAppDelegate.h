//
//  GBAppDelegate.h
//  OpenFeedback
//
//  Created by Tomaz Kragelj on 21.7.10.
//  Copyright (C) 2010, Tomaz Kragelj. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class OpenFeedback;

@interface GBAppDelegate : NSObject {
	IBOutlet OpenFeedback *openFeedback;
}

- (IBAction)crash:(id)sender;

@end
