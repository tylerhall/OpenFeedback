//
//  OFUtilities.h
//  Sparkle
//
//  Created by Andy Matuschak on 3/12/06.
//  Copyright 2006 Andy Matuschak. All rights reserved.
//
// Class and methods renamed from "SU" to "OF" by Tyler Hall 3/19/08
// The rest of Andy's awesome code has remained unchanged :-)

#import <Cocoa/Cocoa.h>

id OFInfoValueForKey(NSString *key);
id OFUnlocalizedInfoValueForKey(NSString *key);
NSString *OFHostAppName();
NSString *OFHostAppDisplayName();
NSString *OFHostAppVersion();
NSString *OFHostAppVersionString();
NSString *OFCurrentSystemVersionString();

NSComparisonResult OFStandardVersionComparison(NSString * versionA, NSString * versionB);

// If running make localizable-strings for genstrings, ignore the error on this line.
NSString *OFLocalizedString(NSString *key, NSString *comment);
