//
//  OpenFeedbackTesterAppDelegate.m
//  OpenFeedbackTester
//
//  Created by Tyler Hall on 8/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OpenFeedbackTesterAppDelegate.h"
#import "COTOpenFeedbackWindowController.h"

@implementation OpenFeedbackTesterAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    COTOpenFeedbackWindowController *of = [[[COTOpenFeedbackWindowController alloc] initWithWindowNibName:@"COTOpenFeedbackWindow"] retain];
    [of showWindow:nil];
}

@end
