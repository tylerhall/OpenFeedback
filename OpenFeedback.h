//
//  OpenFeedback.h
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

#import <Cocoa/Cocoa.h>
#import <AddressBook/AddressBook.h>
#import "OFUtilities.h"

@interface OpenFeedback : NSWindowController {
	BOOL previousIncludeMyEmailValue;
	BOOL previousWantPersonalReplyValue;

	IBOutlet NSTabView *tabView;
	
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
	IBOutlet NSButton *btnWantPersonalReply;
	IBOutlet NSComboBox *cboEmailAddress;
	IBOutlet NSProgressIndicator *piStatus;
	IBOutlet NSButton *btnSend;	
}

// IBActions
- (IBAction) presentFeedbackPanelForSupport:(id)sender;
- (IBAction) presentFeedbackPanelForFeature:(id)sender;
- (IBAction) presentFeedbackPanelForBug:(id)sender;

- (IBAction) includeEmailAction:(id)sender;
- (IBAction) wantReplyAction:(id)sender;
- (IBAction) sendFeedbackAction:(id)sender;

// UI Bindings

// Helper Functions
- (void) showFeedbackWindow;
- (void) populateEmailAddresses;
- (NSString *)getPostData;
- (BOOL) isSendEnabled;
NSString *urlEscape(NSString *str);

// Systen Info Functions
NSString *currentSystemVersionString();

@end