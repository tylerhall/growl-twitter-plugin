//
//  GrowlTwitterPrefs.h
//  Display Plugins
//
//  Created by Tyler Hall.
//  Code based on GrowlSMSDisplay by by Diggory Laycock.
//  Copyright 2005-2009 The Growl Project All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>

@interface GrowlTwitterPrefs: NSPreferencePane {
}

- (NSString *) getUsername;
- (void) setUsername:(NSString *)value;

- (NSString *) getPassword;
- (void) setPassword:(NSString *)value;

- (NSString *) getTweetPrefix;
- (void) setTweetPrefix:(NSString *)value;

@end
