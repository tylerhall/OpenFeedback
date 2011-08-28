//
//  COTOpenFeedbackWindowController.m
//  OpenFeedbackTester
//
//  Created by Tyler Hall on 8/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "COTOpenFeedbackWindowController.h"


@implementation COTOpenFeedbackWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    NSRect windowFrame = [[self window] frame];
    windowFrame.size.height = windowFrame.size.height - [_btnDiscloseOptional frame].origin.y + 10;
    [[self window] setFrame:windowFrame display:NO animate:NO];
}

- (IBAction)cancelButtonWasClicked:(id)sender {
}

- (IBAction)sendButtonWasClicked:(id)sender {
}

- (IBAction)disclosureButtonWasClicked:(id)sender {

    NSRect windowFrame = [[self window] frame];
    CGFloat currentHeight = windowFrame.size.height;
    
    if([_btnDiscloseOptional state] == NSOnState) {
        windowFrame.size.height = windowFrame.size.height - [_ikScreenShots frame].origin.y + 10;
    } else {
        windowFrame.size.height = windowFrame.size.height - [_btnDiscloseOptional frame].origin.y + 10;
    }

    windowFrame.origin.y += (currentHeight - windowFrame.size.height);

    [[self window] setFrame:windowFrame display:YES animate:YES];
}

@end
