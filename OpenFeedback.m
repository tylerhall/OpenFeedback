//
//  OpenFeedback.m
//  OpenFeedback
//
//  Created by Tyler Hall on 3/26/08.
//  Copyright 2008 ClickOnTyler.com
//  Original idea used with permission from Cultured Code (http://culturedcode.com/).
//
//  Released under the MIT License
// 
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
// 

#import "OpenFeedback.h"

@implementation OpenFeedback

- (id) init
{
	// Default checkbox values for Feature Request and Bug Report tabs
	previousIncludeMyEmailValue = YES;
	previousWantPersonalReplyValue = NO;
    
    return self;
}

- (void) awakeFromNib
{
	[self populateEmailAddresses];
	[[self window] setTitle:[NSString stringWithFormat:@"%@ Feedback", OFHostAppDisplayName()]];
}

#pragma mark -
#pragma mark IBActions

- (IBAction) presentFeedbackPanelForSupport:(id)sender
{
	[self showFeedbackWindow];
	[tabView selectTabViewItemAtIndex:0];
}

- (IBAction) presentFeedbackPanelForFeature:(id)sender
{
	[self showFeedbackWindow];
	[tabView selectTabViewItemAtIndex:1];
}

- (IBAction) presentFeedbackPanelForBug:(id)sender
{
	[self showFeedbackWindow];
	[tabView selectTabViewItemAtIndex:2];
}

- (IBAction) includeEmailAction:(id)sender
{
	// Enable "Want Reply" if "Include My Email" is checked
	[btnWantPersonalReply setEnabled:[btnIncludeMyEmail state]];
	
	// Remember our new choice
	previousIncludeMyEmailValue = [btnIncludeMyEmail state];
}

- (IBAction) wantReplyAction:(id)sender
{
	// Remember our new choice
	previousWantPersonalReplyValue = [btnWantPersonalReply state];
}

- (IBAction) sendFeedbackAction:(id)sender
{
	[piStatus startAnimation:self];
	
	NSString *post = [self getPostData];
	NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	
	NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
	NSString *submitFeedbackURL = [infoPlist objectForKey:@"OFSubmitFeedbackURL"];
	
	if (submitFeedbackURL == nil) {
		NSLog(@"OpenFeedback Error: You must set OFSubmitFeedbackURL in Info.plist");
		return;
	}
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:submitFeedbackURL]];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	
	[NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark -
#pragma mark UI Bindings

- (void) textDidChange:(NSNotification *)aNotification
{
	[btnSend setEnabled:[self isSendEnabled]];
}

- (void) comboBoxSelectionDidChange:(NSNotification *)notification
{
	[btnSend setEnabled:[self isSendEnabled]];
}

- (void) tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	// Manage email checkboxes...
	if([[tabViewItem identifier] intValue] == 1)
	{
		[btnIncludeMyEmail setState:YES];
		[btnIncludeMyEmail setEnabled:NO];
		
		[btnWantPersonalReply setState:YES];
		[btnWantPersonalReply setEnabled:NO];
	}
	else
	{
		[btnIncludeMyEmail setEnabled:YES];
		[btnIncludeMyEmail setState:previousIncludeMyEmailValue];
		
		[btnWantPersonalReply setState:previousWantPersonalReplyValue];
		[btnWantPersonalReply setEnabled:[btnIncludeMyEmail state]];
	}
	
	[btnSend setEnabled:[self isSendEnabled]];
}

#pragma mark -
#pragma mark URL Delegates

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[piStatus stopAnimation:self];
	
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:@"Feedback Sent"];
	[alert setInformativeText:@"Your feedback has been sent successfully. Thank you!"];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:@"feedbackSentSuccessfully"];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[piStatus stopAnimation:self];
	
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:@"Can't Send Feedback"];
	[alert setInformativeText:@"We were unable to send your feedback. Please check your internet connection and try again."];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:@"register"];
}

#pragma mark -
#pragma mark Helper Functions

- (void) showFeedbackWindow
{
 	NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"OpenFeedback" ofType:@"nib"];
	if (!path) // slight hack to resolve issues with running with in configurations
	{
		NSBundle *current = [NSBundle bundleForClass:[self class]];
		NSString *frameworkPath = [[[NSBundle mainBundle] sharedFrameworksPath] stringByAppendingFormat:@"/OpenFeedback.framework", [current bundleIdentifier]];
		NSBundle *framework = [NSBundle bundleWithPath:frameworkPath];
		path = [framework pathForResource:@"OpenFeedback" ofType:@"nib"];
	}

	[super initWithWindowNibPath:path owner:self];
	
    [self showWindow:self];
}

- (void) sheetDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if([(NSString *)contextInfo isEqualToString:@"feedbackSentSuccessfully"])
	{
		[[self window] close];
	}
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

- (NSString *)getPostData
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	
	[dict setValue:OFHostAppName() forKey:@"appname"];
	[dict setValue:OFHostAppVersion() forKey:@"appversion"];
	[dict setValue:OFCurrentSystemVersionString() forKey:@"systemversion"];
	
	if([btnIncludeMyEmail state] == YES)
		[dict setValue:[cboEmailAddress stringValue] forKey:@"email"];

	if([btnWantPersonalReply state] == YES)
		[dict setValue:@"1" forKey:@"reply"];
	
	switch([[[tabView selectedTabViewItem] identifier] intValue])
	{
		case 1: // Support
            [dict setValue:@"support" forKey:@"type"];
			[dict setValue:[txtQuestion string] forKey:@"message"];
			break;
			
		case 2: // Feature Request
            [dict setValue:@"feature" forKey:@"type"];
			[dict setValue:[txtFeature string] forKey:@"message"];
			[dict setValue:[btnImportance titleOfSelectedItem]  forKey:@"importance"];
			break;
			
		case 3: // Bug Report
            [dict setValue:@"bug" forKey:@"type"];
			[dict setValue:[NSString stringWithFormat:@"What did you expect to happen?\n%@\n\nWhat steps will reproduce the problem?\n%@",
							[txtWhatHappened string],
							[txtStepsToReproduce string]]
					forKey:@"message"];
			if([btnIsCritical state] == YES)
				[dict setValue:@"1" forKey:@"critical"];
			break;
	}
	
	// Flatten dict into a url query string
    // (This needs to be tested with special characters and other character enocdings.)
	NSMutableArray *info = [NSMutableArray array];
	NSEnumerator *e = [dict keyEnumerator];
	id key;
	while((key = [e nextObject]))
		[info addObject:[NSString stringWithFormat:@"%@=%@", key, urlEscape([dict valueForKey:key])]];
	
	return [info componentsJoinedByString:@"&"];
}

NSString *urlEscape(NSString *str)
{
	// I doubt this is super robust, but it works for now :-)
	NSMutableString *ret = [NSMutableString stringWithString:str];
	[ret replaceOccurrencesOfString:@"&" withString:@"%26" options:NSLiteralSearch range:NSMakeRange(0, [ret length])];
	[ret replaceOccurrencesOfString:@"=" withString:@"%3d" options:NSLiteralSearch range:NSMakeRange(0, [ret length])];
	return ret;
}

- (BOOL) isSendEnabled
{
	BOOL returnVal = YES;
	
	if([btnIncludeMyEmail state] == YES)
	{
        // We need to actually verify the email address is valid at some point (not today)
		if([[cboEmailAddress stringValue] isEqualToString:@""])
			returnVal = NO;
	}
	
	switch([[[tabView selectedTabViewItem] identifier] intValue])
	{
		case 1: // Support
			if([[txtQuestion string] isEqualToString:@""])
				returnVal = NO;
			break;
			
			case 2: // Feature Request
			if([[txtFeature string] isEqualToString:@""])
				returnVal = NO;
			break;
			
			case 3: // Bug Report
			if([[txtWhatHappened string] isEqualToString:@""])
				returnVal = NO;
			break;
	}
	
	return returnVal;
}

@end