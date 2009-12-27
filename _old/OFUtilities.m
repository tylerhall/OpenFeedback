//
//  OFUtilities.m
//  Sparkle
//
//  Created by Andy Matuschak on 3/12/06.
//  Copyright 2006 Andy Matuschak. All rights reserved.
//
// Class and methods renamed from "SU" to "OF" by Tyler Hall 3/19/08
// The rest of Andy's awesome code has remained unchanged :-)

#import "OFUtilities.h"

@interface OFUtilities : NSObject
+(NSString *)localizedStringForKey:(NSString *)key withComment:(NSString *)comment;
@end

id OFUnlocalizedInfoValueForKey(NSString *key)
{
	// Okay, but if it isn't there, let's use the general one.
	id value = [[[NSBundle mainBundle] infoDictionary] valueForKey:key];
	if (!value)
		return OFInfoValueForKey(key);
	return value;
}

id OFInfoValueForKey(NSString *key)
{
	return [[NSBundle mainBundle] objectForInfoDictionaryKey:key];
}

NSString *OFHostAppName()
{
	if (OFInfoValueForKey(@"CFBundleName")) { return OFInfoValueForKey(@"CFBundleName"); }
	return [[[NSFileManager defaultManager] displayNameAtPath:[[NSBundle mainBundle] bundlePath]] stringByDeletingPathExtension];
}

NSString *OFHostAppDisplayName()
{
	if (OFInfoValueForKey(@"CFBundleDisplayName")) { return OFInfoValueForKey(@"CFBundleDisplayName"); }
	return OFHostAppName();
}

NSString *OFHostAppVersion()
{
	return OFInfoValueForKey(@"CFBundleVersion");
}

NSString *OFHostAppVersionString()
{
	NSString *shortVersionString = OFInfoValueForKey(@"CFBundleShortVersionString");
	if (shortVersionString)
	{
		if (![shortVersionString isEqualToString:OFHostAppVersion()])
			shortVersionString = [shortVersionString stringByAppendingFormat:@"/%@", OFHostAppVersion()];
		return shortVersionString;
	}
	else
		return OFHostAppVersion(); // fall back on CFBundleVersion
}

NSString *OFCurrentSystemVersionString()
{
	static NSString *currentSystemVersion = nil;
	if (!currentSystemVersion) {
		// OS version (Apple recommends using SystemVersion.plist instead of Gestalt() here, don't ask me why).
		// This code *should* use NSSearchPathForDirectoriesInDomains(NSCoreServiceDirectory, NSSystemDomainMask, YES)
		// but that returns /Library/CoreServices for some reason
		NSString *versionPlistPath = @"/System/Library/CoreServices/SystemVersion.plist";
		//gets a version string of the form X.Y.Z
		currentSystemVersion = [[[NSDictionary dictionaryWithContentsOfFile:versionPlistPath] objectForKey:@"ProductVersion"] retain];
	}
	
	return currentSystemVersion;
}



NSString *OFLocalizedString(NSString *key, NSString *comment) {
	return [OFUtilities localizedStringForKey:key withComment:comment];
}

enum {
    kNumberType,
    kStringType,
    kPeriodType
};

// The version comparison code here is courtesy of Kevin Ballard, adapted from MacPAD. Thanks, Kevin!

int OFGetCharType(NSString *character)
{
    if ([character isEqualToString:@"."]) {
        return kPeriodType;
    } else if ([character isEqualToString:@"0"] || [character intValue] != 0) {
        return kNumberType;
    } else {
        return kStringType;
    }	
}

NSArray *OFSplitVersionString(NSString *version)
{
    NSString *character;
    NSMutableString *s;
    int i, n, oldType, newType;
    NSMutableArray *parts = [NSMutableArray array];
    if ([version length] == 0) {
        // Nothing to do here
        return parts;
    }
    s = [[[version substringToIndex:1] mutableCopy] autorelease];
    oldType = OFGetCharType(s);
    n = [version length] - 1;
    for (i = 1; i <= n; ++i) {
        character = [version substringWithRange:NSMakeRange(i, 1)];
        newType = OFGetCharType(character);
        if (oldType != newType || oldType == kPeriodType) {
            // We've reached a new segment
			NSString *aPart = [[NSString alloc] initWithString:s];
            [parts addObject:aPart];
			[aPart release];
            [s setString:character];
        } else {
            // Add character to string and continue
            [s appendString:character];
        }
        oldType = newType;
    }
    
    // Add the last part onto the array
    [parts addObject:[NSString stringWithString:s]];
    return parts;
}

NSComparisonResult OFStandardVersionComparison(NSString *versionA, NSString *versionB)
{
	NSArray *partsA = OFSplitVersionString(versionA);
    NSArray *partsB = OFSplitVersionString(versionB);
    
    NSString *partA, *partB;
    int i, n, typeA, typeB, intA, intB;
    
    n = MIN([partsA count], [partsB count]);
    for (i = 0; i < n; ++i) {
        partA = [partsA objectAtIndex:i];
        partB = [partsB objectAtIndex:i];
        
        typeA = OFGetCharType(partA);
        typeB = OFGetCharType(partB);
        
        // Compare types
        if (typeA == typeB) {
            // Same type; we can compare
            if (typeA == kNumberType) {
                intA = [partA intValue];
                intB = [partB intValue];
                if (intA > intB) {
                    return NSOrderedDescending;
                } else if (intA < intB) {
                    return NSOrderedAscending;
                }
            } else if (typeA == kStringType) {
                NSComparisonResult result = [partB compare:partA];
				/* The strings aren't the same. Use the following logic:
				 * Release candidate (rc) > beta (b) > alpha (a)
				 * Note that if comparing two versions of differing lengths, we won't get here; for example,
				 *		"1.1b1" vs. "1.1" will ultimately favor 1.1 as being newer once we leave this loop,
				 *		but the code below won't execute since the latter version doesn't have the 'b1' part.
				 */
                if (result != NSOrderedSame) {
					if ([partB isEqualToString:@"rc"])
						return NSOrderedAscending;
					else if ([partA isEqualToString:@"rc"])
						return NSOrderedDescending;
					else if ([partB isEqualToString:@"b"])
						return NSOrderedAscending;
					else if ([partA isEqualToString:@"b"])
						return NSOrderedDescending;
					else if ([partB isEqualToString:@"a"])
						return NSOrderedAscending;
					else if ([partA isEqualToString:@"a"])
						return NSOrderedDescending;
                    else {
						// Simple alphabetical comparison. It's doubtful this is really what we wanted...
						return result;
					}
                }
            }
        } else {
            // Not the same type? Now we have to do some validity checking
            if (typeA != kStringType && typeB == kStringType) {
                // typeA wins
                return NSOrderedDescending;
            } else if (typeA == kStringType && typeB != kStringType) {
                // typeB wins
                return NSOrderedAscending;
            } else {
                // One is a number and the other is a period. The period is invalid
                if (typeA == kNumberType) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedAscending;
                }
            }
        }
    }
    // The versions are equal up to the point where they both still have parts
    // Lets check to see if one is larger than the other
    if ([partsA count] != [partsB count]) {
        // Yep. Lets get the next part of the larger
        // n holds the value we want
        NSString *missingPart;
        int missingType, shorterResult, largerResult;
        
        if ([partsA count] > [partsB count]) {
            missingPart = [partsA objectAtIndex:n];
            shorterResult = NSOrderedAscending;
            largerResult = NSOrderedDescending;
        } else {
            missingPart = [partsB objectAtIndex:n];
            shorterResult = NSOrderedDescending;
            largerResult = NSOrderedAscending;
        }
        
        missingType = OFGetCharType(missingPart);
        // Check the type
        if (missingType == kStringType) {
            // It's a string. Shorter version wins
            return shorterResult;
        } else {
            // It's a number/period. Larger version wins
            return largerResult;
        }
    }
    
    // The 2 strings are identical
    return NSOrderedSame;
}

@implementation OFUtilities

+ (NSString *)localizedStringForKey:(NSString *)key withComment:(NSString *)comment 
{
	return NSLocalizedStringFromTableInBundle(key, @"Sparkle", [NSBundle bundleForClass:[self class]], comment);
}

@end
