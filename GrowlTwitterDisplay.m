//
//  GrowlTwitterDisplay.m
//  Growl Display Plugins
//
//  Created by Tyler Hall.
//  Code based on GrowlSMSDisplay by by Diggory Laycock.
//  Copyright 2005-2009 The Growl Project All rights reserved.
//

#import "GrowlTwitterDisplay.h"
#import "GrowlTwitterPrefs.h"
#import "NSStringAdditions.h"
#import "GrowlDefinesInternal.h"
#import "GrowlApplicationNotification.h"
#include <Security/SecKeychain.h>
#include <Security/SecKeychainItem.h>

#define keychainServiceName "GrowlTwitter"
#define keychainAccountName "TwitterWebServicePassword"

#define GrowlTwitterPrefDomain	@"com.Growl.Twitter"
#define usernameKey				@"Twitter - Username"
#define tweetPrefixKey          @"Twitter - Tweet Prefix"

@implementation GrowlTwitterDisplay

- (id) init {
    NSLog(@"GrowlTwitter init");
	if ((self = [super init])) {
        twitterEngine = [[MGTwitterEngine alloc] initWithDelegate:self];
	}
	return self;
}

- (void) dealloc {
	[preferencePane release];
	[super dealloc];
}

- (NSPreferencePane *) preferencePane {
	if (!preferencePane)
		preferencePane = [[GrowlTwitterPrefs alloc] initWithBundle:[NSBundle bundleWithIdentifier:@"com.Growl.Twitter"]];
	return preferencePane;
}

- (void) displayNotification:(GrowlApplicationNotification *)notification {
	NSString	*usernameValue = nil;
    NSString    *tweetPrefixValue = nil;

    NSLog(@"GrowlTwitter notification");

	READ_GROWL_PREF_VALUE(usernameKey, GrowlTwitterPrefDomain, NSString *, &usernameValue);
	[usernameValue autorelease];

	if (![usernameValue length]) {
		NSLog(@"Twitter display: Cannot send tweet - username required.");
		return;
	}
    
    READ_GROWL_PREF_VALUE(tweetPrefixKey, GrowlTwitterPrefDomain, NSString *, &tweetPrefixValue);
	[tweetPrefixValue autorelease];
    if (![tweetPrefixValue length]) {
        tweetPrefixValue = @"";
    }

	NSDictionary *noteDict = [notification dictionaryRepresentation];
	NSString *title = [noteDict objectForKey:GROWL_NOTIFICATION_TITLE];
	NSString *desc = [noteDict objectForKey:GROWL_NOTIFICATION_DESCRIPTION];

	//	Fetch the Twitter password from the keychain
	unsigned char *password;
	UInt32 passwordLength;
	OSStatus status;
	status = SecKeychainFindGenericPassword(NULL,
											strlen(keychainServiceName), keychainServiceName,
											strlen(keychainAccountName), keychainAccountName,
											&passwordLength, (void **)&password, NULL);

	CFStringRef passwordString;
	if (status == noErr) {
		passwordString = CFStringCreateWithBytes(kCFAllocatorDefault, password, passwordLength, kCFStringEncodingUTF8, false);
		SecKeychainItemFreeContent(NULL, password);
	} else {
		if (status != errSecItemNotFound)
			NSLog(@"Twitter display: Failed to retrieve Twitter password from keychain. Error: %d", status);
		passwordString = CFSTR("");
	}

	// Send tweet
	NSString *tweet = [[NSString alloc] initWithFormat:
		@"%@%@ %@",
		tweetPrefixValue,
		title,
		desc];

    NSLog(@"GrowlTwitter: %@", tweet);
    [twitterEngine setUsername:usernameValue password:(NSString *)passwordString];
    [twitterEngine sendUpdate:tweet];

	CFRelease(passwordString);

	id clickContext = [noteDict objectForKey:GROWL_NOTIFICATION_CLICK_CONTEXT];
	if (clickContext) {
		NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
			[noteDict objectForKey:@"ClickHandlerEnabled"], @"ClickHandlerEnabled",
			clickContext,                                   GROWL_KEY_CLICKED_CONTEXT,
			[noteDict objectForKey:GROWL_APP_PID],          GROWL_APP_PID,
			nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:GROWL_NOTIFICATION_TIMED_OUT
															object:[notification applicationName]
														  userInfo:userInfo];
		[userInfo release];
	}

}

- (BOOL) requiresPositioning {
	return NO;
}

#pragma mark MGTwitterEngineDelegate methods

- (void)requestSucceeded:(NSString *)requestIdentifier
{
//    NSLog(@"Request succeeded (%@)", requestIdentifier);
}


- (void)requestFailed:(NSString *)requestIdentifier withError:(NSError *)error
{
//    NSLog(@"Twitter request failed! (%@) Error: %@ (%@)", 
//          requestIdentifier, 
//          [error localizedDescription], 
//          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
}


- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)identifier
{
//    NSLog(@"Got statuses:\r%@", statuses);
}


- (void)directMessagesReceived:(NSArray *)messages forRequest:(NSString *)identifier
{
//    NSLog(@"Got direct messages:\r%@", messages);
}


- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)identifier
{
//    NSLog(@"Got user info:\r%@", userInfo);
}


- (void)miscInfoReceived:(NSArray *)miscInfo forRequest:(NSString *)identifier
{
//	NSLog(@"Got misc info:\r%@", miscInfo);
}


- (void)imageReceived:(NSImage *)image forRequest:(NSString *)identifier
{
//    NSLog(@"Got an image: %@", image);
//    
//    // Save image to the Desktop.
//    NSString *path = [[NSString stringWithFormat:@"~/Desktop/%@.tiff", identifier] 
//                      stringByExpandingTildeInPath];
//    [[image TIFFRepresentation] writeToFile:path atomically:NO];
}

@end
