//
//  OpenFeedback.h
//  OpenFeedback
//
//  Created by Tyler Hall on 12/27/09.
//  Copyright 2009 Click On Tyler, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class OFController;
@class OpenFeedback;

@protocol OpenFeedbackDelegate
- (BOOL)openFeedback:(OpenFeedback *)feedback willSendData:(NSDictionary *)data;
@end

@interface OpenFeedback : NSObject {
	OFController *windowController;
	id delegate;
}

- (IBAction)presentFeedbackPanelForSupport:(id)sender;
- (IBAction)presentFeedbackPanelForFeature:(id)sender;
- (IBAction)presentFeedbackPanelForBug:(id)sender;
- (void)presentFeedbackPanelIfCrashed;
@property (assign) id<OpenFeedbackDelegate> delegate;

@end

