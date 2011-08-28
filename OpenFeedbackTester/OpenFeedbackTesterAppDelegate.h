//
//  OpenFeedbackTesterAppDelegate.h
//  OpenFeedbackTester
//
//  Created by Tyler Hall on 8/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OpenFeedbackTesterAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
