//
//  OpenFeedback.m
//  OpenFeedback
//
//  Created by Tyler Hall on 12/27/09.
//  Copyright 2009 Click On Tyler, LLC. All rights reserved.
//

#import "OpenFeedback.h"


@implementation OpenFeedback

- (void)awakeFromNib
{
	NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"OpenFeedback" ofType:@"nib"];
	if(!path)
	{
		NSBundle *current = [NSBundle bundleForClass:[self class]];
		NSString *frameworkPath = [[[NSBundle mainBundle] sharedFrameworksPath] stringByAppendingFormat:@"/OpenFeedback.framework", [current bundleIdentifier]];
		NSBundle *framework = [NSBundle bundleWithPath:frameworkPath];
		path = [framework pathForResource:@"OpenFeedback" ofType:@"nib"];
	}	
	windowController = [[OFController alloc] initWithWindowNibName:@"OpenFeedback"];
}

- (IBAction)presentFeedbackPanelForSupport:(id)sender
{
	[windowController presentFeedbackPanelForSupport:self];
}

- (IBAction)presentFeedbackPanelForFeature:(id)sender
{
	[windowController presentFeedbackPanelForFeature:self];
}

- (IBAction)presentFeedbackPanelForBug:(id)sender
{
	[windowController presentFeedbackPanelForBug:self];
}

@end
