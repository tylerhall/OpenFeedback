//
//  COTOpenFeedbackWindowController.h
//  OpenFeedbackTester
//
//  Created by Tyler Hall on 8/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface COTOpenFeedbackWindowController : NSWindowController {
@private
    // Window
    IBOutlet NSSegmentedControl *_segTabs;
    IBOutlet NSBox *_boxContent;
    IBOutlet NSButton *_btnIncludeEmail;
    IBOutlet NSComboBox *_cboEmailAddress;
    IBOutlet NSButton *_btnDiscloseOptional;
    IBOutlet NSButton *_btnCancel;
    IBOutlet NSButton *_btnSend;
    IBOutlet NSButton *_btnCrashLogs;
    IBOutlet NSButton *_btnScreenshot;
    IBOutlet IKImageBrowserView *_ikScreenShots;
    
    // Support Question
    IBOutlet NSTextField *_txtSupportQuestion;
    
    // Feature Request
    IBOutlet NSTextField *_txtFeatureRequest;
    IBOutlet NSPopUpButton *_btnFeatureImportance;
    
    // Bug Report
    IBOutlet NSTextField *_txtBugDescription;
    IBOutlet NSTextField *_txtBugReproduce;
    IBOutlet NSButton *_btnBugIsCritical;
}

- (IBAction)cancelButtonWasClicked:(id)sender;
- (IBAction)sendButtonWasClicked:(id)sender;
- (IBAction)disclosureButtonWasClicked:(id)sender;

@end
