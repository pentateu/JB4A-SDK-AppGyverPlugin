//
//  AppDelegate+ETPlugin.m
//  AppGyver
//
//  Created by Rafael Almeida on 18/04/15.
//  Copyright (c) 2015 AppGyver Inc. All rights reserved.
//

#import "AppDelegate+ETPlugin.h"
#import <objc/runtime.h>
@implementation AppDelegate (ETPlugin)

// its dangerous to override a method from within a category.
// Instead we will use method swizzling. we set this up in the load call.
+ (void)load {
    
    Method original, swizzled;
    
    //- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    original = class_getInstanceMethod(self, @selector(application:didFinishLaunchingWithOptions:));
    swizzled = class_getInstanceMethod(self, @selector(swizzled_application:didFinishLaunchingWithOptions:));
    method_exchangeImplementations(original, swizzled);
    
}


- (BOOL)swizzled_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSLog(@"[ETPlugin] - Calling AppDelegate's original implementation of -> application:didFinishLaunchingWithOptions: ");
    // This actually calls the original init method over in AppDelegate. Equivilent to calling super
    // on an overrided method, this is not recursive, although it appears that way. neat huh?
    BOOL result = [self swizzled_application:application didFinishLaunchingWithOptions:launchOptions];
    
    NSLog(@"[ETPlugin] - Trying to call the plugin's implementation of -> application:didFinishLaunchingWithOptions: ");
    @try {
        [self ET_application:application didFinishLaunchingWithOptions:launchOptions];
    }
    @catch (NSException *exception) {
        NSLog(@"[ETPlugin] - ERROR - Trying to execute the plugin's implementation of -> application:didFinishLaunchingWithOptions: - error description: %@ ", exception.description);
    }
    
    return result;
}

- (void)ET_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSDictionary* ETSettings = [mainBundle objectForInfoDictionaryKey:@"ETAppSettings"];
    BOOL useGeoLocation = [[ETSettings objectForKey:@"UseGeofences"] boolValue];
    BOOL useAnalytics = [[ETSettings objectForKey:@"UseAnalytics"] boolValue];
    
#ifdef DEBUG
    NSString* devAppID = [ETSettings objectForKey:@"ApplicationID-Dev"];
    NSString* devAccessToken = [ETSettings objectForKey:@"AccessToken-Dev"];
    //use your debug app id and token you setup in code.exacttarget.com here
    [[ETPush pushManager] configureSDKWithAppID:devAppID
                                 andAccessToken:devAccessToken
                                  withAnalytics:useAnalytics
                            andLocationServices:useGeoLocation
                                  andCloudPages:NO];
    
#else
    NSString* prodAppID = [ETSettings objectForKey:@"ApplicationID-Prod"];
    NSString* prodAccessToken = [ETSettings objectForKey:@"AccessToken-Prod"];
    //use your production app id and token you setup in code.exacttarget.com here
    
    [[ETPush pushManager] configureSDKWithAppID:prodAppID
                                 andAccessToken:prodAccessToken
                                  withAnalytics:useAnalytics
                            andLocationServices:useGeoLocation
                                  andCloudPages:NO];
    
#endif
    
    
    // IPHONEOS_DEPLOYMENT_TARGET = 6.X or 7.X
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    // Supports IOS SDK 8.X (i.e. XCode 6.X and up)
    // are we running on IOS8 and above?
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerForRemoteNotifications)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:
                                                UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert
                                                                                 categories:nil];
        [[ETPush pushManager] registerUserNotificationSettings:settings];
        [[ETPush pushManager] registerForRemoteNotifications];
    }
    else {
        [[ETPush pushManager] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];
    }
#else
    // Supports IOS SDKs < 8.X (i.e. XCode 5.X or less)
    [[ETPush pushManager] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];
#endif
#else
    // IPHONEOS_DEPLOYMENT_TARGET >= 8.X
    // Supports IOS SDK 8.X (i.e. XCode 6.X and up)
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:
                                            UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert
                                                                             categories:nil];
    [[ETPush pushManager] registerUserNotificationSettings:settings];
    [[ETPush pushManager] registerForRemoteNotifications];
#endif
    [[ETPush pushManager] shouldDisplayAlertViewIfPushReceived:YES];
    [[ETPush pushManager] applicationLaunchedWithOptions:launchOptions];
    NSString* token = [[ETPush pushManager] deviceToken];
    NSString* deviceID = [ETPush safeDeviceIdentifier]; NSLog(@"token %@", token);
    NSLog(@"Device ID %@", deviceID);
    if (useGeoLocation) {
        [[ETLocationManager locationManager] startWatchingLocation];
    }
    
}


-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[ETPush pushManager] handleNotification:userInfo forApplicationState:application.applicationState];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfo
                                                       options:0
                                                         error:&error];
    if (!jsonData) {
        
        NSLog(@"json error: %@", error);
        
    } else {
        
        [ETSdkWrapper.etPlugin notifyOfMessage:jsonData];
    }
}

- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[ETPush pushManager] registerDeviceToken:deviceToken];
    // re-post ( broadcast )
    NSString* token = [[[[deviceToken description]
                         stringByReplacingOccurrencesOfString: @"<" withString: @""]
                        stringByReplacingOccurrencesOfString: @">" withString: @""]
                       stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CDVRemoteNotification object:token];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    [[ETPush pushManager] applicationDidFailToRegisterForRemoteNotificationsWithError:error];
    // re-post ( broadcast )
    [[NSNotificationCenter defaultCenter] postNotificationName:CDVRemoteNotificationError object:error];
}

- (void)application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification*)notification
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:notification.userInfo
                                                       options:0
                                                         error:&error];
    if (!jsonData) {
        
        NSLog(@"jsn error: %@", error);
        
    } else {
        
        [ETSdkWrapper.etPlugin notifyOfMessage:jsonData];
    }
    // re-post ( broadcast )
    [[NSNotificationCenter defaultCenter] postNotificationName:CDVLocalNotification object:notification];
}


@end
