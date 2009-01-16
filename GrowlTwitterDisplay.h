//
//  GrowlTwitterDisplay.h
//  Growl Display Plugins
//
//  Created by Tyler Hall.
//  Code based on GrowlSMSDisplay by by Diggory Laycock.
//  Copyright 2005-2009 The Growl Project All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GrowlDisplayPlugin.h"
#import "MGTwitterEngine.h"

@interface GrowlTwitterDisplay: GrowlDisplayPlugin <MGTwitterEngineDelegate> {
    MGTwitterEngine *twitterEngine;
}

- (void) displayNotification:(GrowlApplicationNotification *)notification;

@end
