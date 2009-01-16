//
//  GrowlTwitterPrefs.m
//  Display Plugins
//
//  Created by Tyler Hall.
//  Code based on GrowlSMSDisplay by by Diggory Laycock.
//  Copyright 2005-2009 The Growl Project All rights reserved.
//

#import "GrowlTwitterPrefs.h"
#import "GrowlDefinesInternal.h"
#import "NSStringAdditions.h"
#import <Security/SecKeychain.h>
#import <Security/SecKeychainItem.h>

#define GrowlTwitterPrefDomain	@"com.Growl.Twitter"
#define usernameKey				@"Twitter - Username"
#define tweetPrefixKey          @"Twitter - Tweet Prefix"

#define keychainServiceName "GrowlTwitter"
#define keychainAccountName "TwitterWebServicePassword"


@implementation GrowlTwitterPrefs

- (NSString *) mainNibName {
	return @"GrowlTwitterPrefs";
}

- (void) didSelect {
	SYNCHRONIZE_GROWL_PREFS();
}

#pragma mark -

- (NSString *) getUsername {
	NSString *value = nil;
	READ_GROWL_PREF_VALUE(usernameKey, GrowlTwitterPrefDomain, NSString *, &value);
	return [value autorelease];
}

- (void) setUsername:(NSString *)value {
	if (!value)
		value = @"";
	WRITE_GROWL_PREF_VALUE(usernameKey, value, GrowlTwitterPrefDomain);
	UPDATE_GROWL_PREFS();
}

- (NSString *) getPassword {
	unsigned char *password;
	UInt32 passwordLength;
	OSStatus status;
	status = SecKeychainFindGenericPassword( NULL,
											 strlen(keychainServiceName), keychainServiceName,
											 strlen(keychainAccountName), keychainAccountName,
											 &passwordLength, (void **)&password, NULL );

	NSString *passwordString;
	if (status == noErr) {
		passwordString = (NSString *)CFStringCreateWithBytes(kCFAllocatorDefault, password, passwordLength, kCFStringEncodingUTF8, false);
		[passwordString autorelease];
		SecKeychainItemFreeContent(NULL, password);
	} else {
		if (status != errSecItemNotFound)
			NSLog(@"Failed to retrieve Twitter Account password from keychain. Error: %d", status);
		passwordString = @"";
	}

	return passwordString;
}

- (void) setPassword:(NSString *)value {
	const char *password = value ? [value UTF8String] : "";
	unsigned length = strlen(password);
	OSStatus status;
	SecKeychainItemRef itemRef = nil;
	status = SecKeychainFindGenericPassword( NULL,
											 strlen(keychainServiceName), keychainServiceName,
											 strlen(keychainAccountName), keychainAccountName,
											 NULL, NULL, &itemRef );
	if (status == errSecItemNotFound) {
		// add new item
		status = SecKeychainAddGenericPassword( NULL,
												strlen(keychainServiceName), keychainServiceName,
												strlen(keychainAccountName), keychainAccountName,
												length, password, NULL );
		if (status)
			NSLog(@"Failed to add Twitter password to keychain.");
	} else {
		// change existing password
		SecKeychainAttribute attrs[] = {
			{ kSecAccountItemAttr, strlen(keychainAccountName), (char *)keychainAccountName },
			{ kSecServiceItemAttr, strlen(keychainServiceName), (char *)keychainServiceName }
		};
		const SecKeychainAttributeList attributes = { sizeof(attrs) / sizeof(attrs[0]), attrs };
		status = SecKeychainItemModifyAttributesAndData( itemRef,		// the item reference
														 &attributes,	// no change to attributes
														 length,		// length of password
														 password		// pointer to password data
														 );
		if (itemRef)
			CFRelease(itemRef);
		if (status)
			NSLog(@"Failed to change Twitter password in keychain.");
	}
}

- (NSString *) getTweetPrefix {
	NSString *value = nil;
	READ_GROWL_PREF_VALUE(tweetPrefixKey, GrowlTwitterPrefDomain, NSString *, &value);
	return [value autorelease];
}

- (void) setTweetPrefix:(NSString *)value {
	if (!value)
		value = @"";
	WRITE_GROWL_PREF_VALUE(tweetPrefixKey, value, GrowlTwitterPrefDomain);
	UPDATE_GROWL_PREFS();
}

@end
