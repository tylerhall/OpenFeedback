//
//  OFController.m
//  OpenFeedback
//
//  Created by Tyler Hall on 12/26/09.
//  Copyright 2009 Click On Tyler, LLC. All rights reserved.
//

#import "OFController.h"

@interface OFController ()

- (void)presentFeedbackPanelForBugOrCrash;

@end

#pragma mark -

@implementation OFController

- (void)awakeFromNib
{	
	[self populateEmailAddresses];
	[[self window] setTitle:[NSString stringWithFormat:@"%@ Feedback", OFHostAppDisplayName()]];
	[txtCrashTitle setStringValue:[NSString stringWithFormat:[txtCrashTitle stringValue], OFHostAppDisplayName()]];
}

- (IBAction)presentFeedbackPanelForSupport:(id)sender
{
	[self showFeedbackWindow];
	[tabs selectSegmentWithTag:0];
	[tabView setContentView:viewSupport];
	[btnSend setEnabled:[self sendButtonIsEnabled]];
	[[self window] makeFirstResponder:txtQuestion];
}

- (IBAction)presentFeedbackPanelForFeature:(id)sender
{
	[self showFeedbackWindow];
	[tabs selectSegmentWithTag:1];
	[tabView setContentView:viewFeature];
	[btnSend setEnabled:[self sendButtonIsEnabled]];
	[[self window] makeFirstResponder:txtFeature];
}

- (IBAction)presentFeedbackPanelForBug:(id)sender
{
	_crashReportMode = NO;
	[tabs setLabel:NSLocalizedString(@"Bug Report", nil) forSegment:2];
	[self presentFeedbackPanelForBugOrCrash];
}

- (void)presentFeedbackPanelForCrash:(NSString *)report 
{
	_crashReportMode = YES;
	[self loadWindow];	// need to load otherwise IB links are not initalized
	[tabs setLabel:NSLocalizedString(@"Crash Report", nil) forSegment:2];
	NSString *crashDescription = NSLocalizedString(@"\n\n\n\nThe text below is application's crash log, please leave it unchanged to help us determine possible cause!\n\n%@", nil);
	[txtCrashDescription setString:[NSString stringWithFormat:crashDescription, report]];
	[self presentFeedbackPanelForBugOrCrash];
}

- (void)presentFeedbackPanelForBugOrCrash 
{
	[self showFeedbackWindow];
	[tabs selectSegmentWithTag:2];
	[tabView setContentView:_crashReportMode ? viewCrash : viewBug];
	[btnSend setEnabled:[self sendButtonIsEnabled]];
	[[self window] makeFirstResponder:_crashReportMode ? txtCrashDescription : txtWhatHappened];
}

- (void)showFeedbackWindow
{	
	[[self window] makeKeyAndOrderFront:self];
}

- (IBAction)selectedTabDidChange:(id)sender
{
	if([tabs selectedSegment] == 0)
		[self presentFeedbackPanelForSupport:self];
	else if([tabs selectedSegment]== 1)
		[self presentFeedbackPanelForFeature:self];
	else if([tabs selectedSegment] == 2)
		[self presentFeedbackPanelForBugOrCrash];
}

- (IBAction)chkIncludeEmail:(id)sender
{
	[btnSend setEnabled:[self sendButtonIsEnabled]];
	[cboEmailAddress setEnabled:[btnIncludeMyEmail state]];
}

- (void)textDidChange:(NSNotification *)aNotification
{
	[btnSend setEnabled:[self sendButtonIsEnabled]];
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
	[btnSend setEnabled:[self sendButtonIsEnabled]];
}

- (BOOL)sendButtonIsEnabled
{
	BOOL isEnabled = YES;

	// Support Question
	if([tabs selectedSegment] == 0)
	{
		if([[txtQuestion string] length] == 0)
			isEnabled = NO;
	}

	// Feature Request
	if([tabs selectedSegment] == 1)
	{
		if([[txtFeature string] length] == 0)
			isEnabled = NO;

	}

	// Bug or Crash Report
	if([tabs selectedSegment] == 2)
	{
		if (_crashReportMode) 
		{
			if ([[txtCrashDescription string] length] == 0) 
				isEnabled = NO;
		}
		else 
		{
			if([[txtWhatHappened string] length] == 0) 
				isEnabled = NO;
		}
	}
	
	if([btnIncludeMyEmail state] == YES)
	{
		if([[cboEmailAddress stringValue] length] == 0)
			isEnabled = NO;
	}

	return isEnabled;
}

- (void) populateEmailAddresses
{
	// Retrieve the user's email addresses...
	ABPerson *aPerson = [[ABAddressBook sharedAddressBook] me];
	ABMultiValue *emails = [aPerson valueForProperty:kABEmailProperty];
	if([emails count] > 0)
	{
		int i;
		for(i = 0; i < [emails count]; i++)
			[cboEmailAddress addItemWithObjectValue:[emails valueAtIndex:i]];
		[cboEmailAddress selectItemAtIndex:0];
	}		
}

- (IBAction)sendFeedback:(id)sender
{
	// Grab the URL to submit to...
	NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
	NSString *submitFeedbackURL = [infoPlist objectForKey:@"OFSubmitFeedbackURL"];
	if(submitFeedbackURL == nil) {
		NSLog(@"OpenFeedback Error: You must set OFSubmitFeedbackURL in Info.plist");
		return;
	}

	[piStatus startAnimation:self];

	// Build our POST data dictionary
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

	[dict setValue:OFHostAppName() forKey:@"appname"];
	[dict setValue:OFHostAppVersion() forKey:@"appversion"];
	[dict setValue:OFCurrentSystemVersionString() forKey:@"systemversion"];
	
	if([btnIncludeMyEmail state] == YES)
		[dict setValue:[cboEmailAddress stringValue] forKey:@"email"];
	
	switch([tabs selectedSegment])
	{
		case 0: // Support
            [dict setValue:@"support" forKey:@"type"];
			[dict setValue:[txtQuestion string] forKey:@"message"];
			break;
			
		case 1: // Feature Request
            [dict setValue:@"feature" forKey:@"type"];
			[dict setValue:[txtFeature string] forKey:@"message"];
			[dict setValue:[btnImportance titleOfSelectedItem]  forKey:@"importance"];
			break;
			
		case 2: // Bug or Crash Report
			if (_crashReportMode) 
			{
				[dict setValue:@"bug" forKey:@"type"];
				[dict setValue:[NSString stringWithFormat:@"Crash description:\n%@\n\nWhat steps will reproduce the problem?\n%@", [txtCrashDescription string], [txtCrashStepsToReproduce string]] forKey:@"message"];
				[dict setValue:@"1" forKey:@"critical"];
			}
			else 
			{
				[dict setValue:@"bug" forKey:@"type"];
				[dict setValue:[NSString stringWithFormat:@"What did you expect to happen?\n%@\n\nWhat steps will reproduce the problem?\n%@", [txtWhatHappened string], [txtStepsToReproduce string]] forKey:@"message"];
				if([btnIsCritical state] == YES) [dict setValue:@"1" forKey:@"critical"];
			}
			break;
	}

	// Flatten dict into a url query string (this needs to be tested with special characters and other character enocdings)
	NSMutableArray *info = [NSMutableArray array];
	NSEnumerator *e = [dict keyEnumerator];
	id key;
	while(key = [e nextObject]) {
		[info addObject:[NSString stringWithFormat:@"%@=%@", key, urlEscape([dict valueForKey:key])]];
	}

	NSString *post = [info componentsJoinedByString:@"&"];
	NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:submitFeedbackURL]];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	
	[NSURLConnection connectionWithRequest:request delegate:self];
}

NSString *urlEscape(NSString *str)
{
	// I doubt this is super robust, but it works for now :-)
	NSMutableString *ret = [NSMutableString stringWithString:str];
	[ret replaceOccurrencesOfString:@"&" withString:@"%26" options:NSLiteralSearch range:NSMakeRange(0, [ret length])];
	[ret replaceOccurrencesOfString:@"=" withString:@"%3d" options:NSLiteralSearch range:NSMakeRange(0, [ret length])];
	return ret;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[piStatus stopAnimation:self];
	
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:@"Feedback Sent"];
	[alert setInformativeText:@"Your feedback has been sent successfully. Thank you!"];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:@"feedbackSentSuccessfully"];

	[txtQuestion setString:@""];
	[txtFeature setString:@""];
	[txtWhatHappened setString:@""];
	[txtStepsToReproduce setString:@""];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[piStatus stopAnimation:self];
	
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:@"Can't Send Feedback"];
	[alert setInformativeText:@"We were unable to send your feedback. Please check your internet connection and try again."];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:@"feedbackNotSentSuccessfully"];
}

- (void)sheetDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if([(NSString *)contextInfo isEqualToString:@"feedbackSentSuccessfully"])
	{
		[[self window] close];
	}
}

@end
