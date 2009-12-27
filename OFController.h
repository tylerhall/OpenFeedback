//
//  OFController.h
//  OpenFeedback
//
//  Created by Tyler Hall on 12/26/09.
//  Copyright 2009 Click On Tyler, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AddressBook/AddressBook.h>
#import "OFUtilities.h"

@interface OFController : NSWindowController {
	// Fake Tab Control
	IBOutlet NSSegmentedControl *tabs;
	IBOutlet NSBox *tabView;
	IBOutlet NSView *viewSupport;
	IBOutlet NSView *viewFeature;
	IBOutlet NSView *viewBug;

	// Support Tab
	IBOutlet NSTextView *txtQuestion;
	
	// Feature Request Tab
	IBOutlet NSTextView *txtFeature;
	IBOutlet NSPopUpButton *btnImportance;
	
	// Bug Report Tab
	IBOutlet NSTextView *txtWhatHappened;
	IBOutlet NSTextView *txtStepsToReproduce;
	IBOutlet NSButton *btnIsCritical;
	
	// All Tabs
	IBOutlet NSButton *btnIncludeMyEmail;
	IBOutlet NSComboBox *cboEmailAddress;
	IBOutlet NSProgressIndicator *piStatus;
	IBOutlet NSButton *btnSend;
}

- (IBAction)presentFeedbackPanelForSupport:(id)sender;
- (IBAction)presentFeedbackPanelForFeature:(id)sender;
- (IBAction)presentFeedbackPanelForBug:(id)sender;

- (void)showFeedbackWindow;
- (void) populateEmailAddresses;
- (IBAction)selectedTabDidChange:(id)sender;
- (IBAction)chkIncludeEmail:(id)sender;
- (BOOL)sendButtonIsEnabled;
- (IBAction)sendFeedback:(id)sender;
NSString *urlEscape(NSString *str);

@end
