//
//  GBAppDelegate.m
//  OpenFeedback
//
//  Created by Tomaz Kragelj on 21.7.10.
//  Copyright (C) 2010, Tomaz Kragelj. All rights reserved.
//

#import <OpenFeedback/OpenFeedback.h>
#import "GBAppDelegate.h"

@implementation GBAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	[openFeedback presentFeedbackPanelIfCrashed];
}

@end
