//
//  OpenFeedback.m
//  OpenFeedback
//
//  Created by Tyler Hall on 12/27/09.
//  Copyright 2009 Click On Tyler, LLC. All rights reserved.
//

#import "OFController.h"
#import "OpenFeedback.h"

static NSString *kGBLastCrashCheckTimeDefaultsKey = @"GBLastCrashCheckTime";

#pragma mark -

@interface OpenFeedback (CrashReporter)

- (NSString *)latestCrashLogContents:(NSArray *)logs;
- (NSArray *)crashLogsSince:(NSDate *)time;
- (BOOL)file:(NSString *)filename isNewerThan:(NSDate *)time;
- (NSDate *)modificationTimeOfFile:(NSString *)filename;
@property (assign) NSDate *lastCrashCheckTime;

@end

#pragma mark -

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
	windowController.openFeedback = self;
}

- (IBAction)presentFeedbackPanelForSupport:(id)sender
{
	windowController.delegate = self.delegate;
	[windowController presentFeedbackPanelForSupport:self];
}

- (IBAction)presentFeedbackPanelForFeature:(id)sender
{
	windowController.delegate = self.delegate;
	[windowController presentFeedbackPanelForFeature:self];
}

- (IBAction)presentFeedbackPanelForBug:(id)sender
{
	windowController.delegate = self.delegate;
	[windowController presentFeedbackPanelForBug:self];
}

- (void)presentFeedbackPanelIfCrashed 
{
	NSArray *logs = [self crashLogsSince:self.lastCrashCheckTime];
	if ([logs count] > 0)
	{
		NSString *report = [self latestCrashLogContents:logs];
		windowController.openFeedback = self;
		[windowController presentFeedbackPanelForCrash:report];
	}
	self.lastCrashCheckTime = [NSDate date];
}

@synthesize delegate;

@end

#pragma mark -

@implementation OpenFeedback (CrashReporter)

- (NSString *)latestCrashLogContents:(NSArray *)logs 
{
	NSParameterAssert(logs != nil && [logs count] > 0);
	
	NSString *latestFile = nil;
	NSDate *latestTime = [NSDate distantPast];
	for (NSString *filename in logs) {
		if ([self file:filename isNewerThan:latestTime]) 
		{
			latestFile = filename;
			latestTime = [self modificationTimeOfFile:filename];
		}
	}
	
	if (latestFile) return [NSString stringWithContentsOfFile:latestFile encoding:NSUTF8StringEncoding error:nil];
	return nil;
}

- (NSArray *)crashLogsSince:(NSDate *)time 
{
	NSString *appName = OFHostAppName();
	NSFileManager *manager = [NSFileManager defaultManager];
	NSMutableArray *reports = [NSMutableArray array];

	NSArray *directories = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSLocalDomainMask|NSUserDomainMask, YES);	
	for (NSString *directory in directories) 
	{
		// Search all crash reports.
		NSString *crashPath = [directory stringByAppendingPathComponent:@"Logs/CrashReporter"];
		if ([manager fileExistsAtPath:crashPath]) 
		{
			NSString *filename;
			NSDirectoryEnumerator *enumerator = [manager enumeratorAtPath:crashPath];
			NSString *prefix = [NSString stringWithFormat:@"%@_", appName];
			while ((filename = [enumerator nextObject])) 
			{
				if (![filename hasPrefix:prefix]) continue;
				if (![[filename pathExtension] isEqualToString:@"crash"]) continue;
				
				filename = [crashPath stringByAppendingPathComponent:filename];
				if ([self file:filename isNewerThan:time]) [reports addObject:filename];
			}
		}
		
		// Search all hang reports.
		NSString *hangPath = [directory stringByAppendingPathComponent:[NSString stringWithFormat:@"Logs/HangReporter/%@", appName]];
		if ([manager fileExistsAtPath:hangPath]) 
		{
			NSString *filename;
			NSDirectoryEnumerator *enumerator = [manager enumeratorAtPath:hangPath];
			while ((filename = [enumerator nextObject])) 
			{
				if (![[filename pathExtension] isEqualToString:@"hang"]) continue;
				
				filename = [hangPath stringByAppendingPathComponent:filename];
				if ([self file:filename isNewerThan:time]) [reports addObject:filename];
			}
		}
	}
	
	return reports;
}

- (BOOL)file:(NSString *)filename isNewerThan:(NSDate *)time 
{
	if(!time) return YES;
	NSDate *modificationDate = [self modificationTimeOfFile:filename];
	if (!modificationDate) return YES;
	if ([time compare:modificationDate] == NSOrderedDescending) return NO;
	return YES;
}

- (NSDate *)modificationTimeOfFile:(NSString *)filename 
{
	return [[[NSFileManager defaultManager] attributesOfItemAtPath:filename error:nil] fileModificationDate];
}

- (NSDate *)lastCrashCheckTime { return [[NSUserDefaults standardUserDefaults] valueForKey:kGBLastCrashCheckTimeDefaultsKey]; }
- (void)setLastCrashCheckTime:(NSDate *)value { [[NSUserDefaults standardUserDefaults] setValue:value forKey:kGBLastCrashCheckTimeDefaultsKey]; }

@end

