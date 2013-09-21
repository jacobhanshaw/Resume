//
//  AppModel.m
//  ARIS
//
//  Created by Ben Longoria on 2/17/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "AppModel.h"

#import <CoreData/CoreData.h>

@interface AppModel()
{
	NSUserDefaults *defaults;
    
    //CORE Data
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

@end

@implementation AppModel

+ (id) sharedAppModel
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

#pragma mark Init/dealloc
- (id) init
{
    if(self = [super init])
    {
		//Init UserDefaults
		defaults      = [NSUserDefaults standardUserDefaults];
	}
    return self;
}

- (void) dealloc
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark User Defaults

- (void) initUserDefaults
{
    /*
	//Load the settings bundle data into an array
	NSDictionary *settingsDict  = [NSDictionary dictionaryWithContentsOfFile:[[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Settings.bundle"] stringByAppendingPathComponent:@"Root.plist"]];
	NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];
	
	//Find the Defaults
	NSString *baseAppURLDefault             = @"Unknown Default";
    NSNumber *showGamesInDevelopmentDefault = [NSNumber numberWithInt:0];
    NSNumber *showPlayerOnMapDefault        = [NSNumber numberWithInt:1];
	NSDictionary *prefItem;
	for(prefItem in prefSpecifierArray)
	{
		if([[prefItem objectForKey:@"Key"] isEqualToString:@"baseServerString"])       baseAppURLDefault             = [prefItem objectForKey:@"DefaultValue"];
        if([[prefItem objectForKey:@"Key"] isEqualToString:@"showGamesInDevelopment"]) showGamesInDevelopmentDefault = [prefItem objectForKey:@"DefaultValue"];
        if([[prefItem objectForKey:@"Key"] isEqualToString:@"showPlayerOnMap"])        showPlayerOnMapDefault        = [prefItem objectForKey:@"DefaultValue"];
    }
	
	// since no default values have been set (i.e. no preferences file created), create it here
	NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
								 baseAppURLDefault,             @"baseServerString",
                                 showGamesInDevelopmentDefault, @"showGamesInDevelopment",
                                 showPlayerOnMapDefault,        @"showPlayerOnMap",
								 nil];
	
	[defaults registerDefaults:appDefaults];
	[defaults synchronize];
    */
}

- (void) loadUserDefaults
{
	/*NSLog(@"Model: Loading User Defaults");
    NSURL *currServ = [NSURL URLWithString:[defaults stringForKey:@"baseServerString"]];
    if([[currServ absoluteString] isEqual:@""])
    {
        currServ = [NSURL URLWithString:@"http://arisgames.org/server"];
        [defaults setObject:[currServ absoluteString] forKey:@"baseServerString"];
        [defaults synchronize];
    }
    if(![[defaults stringForKey:@"appVersion"] isEqualToString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]] ||
       (self.serverURL && ![currServ isEqual:self.serverURL]) ||
       [defaults boolForKey:@"clearCache"])
    {
        [[AppModel sharedAppModel].mediaCache clearCache];
        if([AppModel sharedAppModel].player)
        {
            NSLog(@"NSNotification: LogoutRequested");
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LogoutRequested" object:self]];
        }
        self.serverURL = currServ;
        [defaults setBool:NO forKey:@"clearCache"];
        [defaults synchronize];
        return;
    }
    self.serverURL = currServ;
    self.showGamesInDevelopment = [defaults boolForKey:@"showGamesInDevelopment"];
    
    //Safe to load defaults
    if(!self.player)
    {
        self.player               = [[Player alloc] init];
        self.showPlayerOnMap      = [defaults  boolForKey:@"showPlayerOnMap"];
        self.player.playerId      = [defaults  integerForKey:@"playerId"];
        self.player.playerMediaId = [defaults  integerForKey:@"playerMediaId"];
        self.player.username      = [defaults  objectForKey:@"userName"];
        self.player.displayname   = [defaults  objectForKey:@"displayName"];
        self.player.groupname     = [defaults  objectForKey:@"groupName"];
        self.player.groupGameId   = [[defaults objectForKey:@"groupName"] intValue];
    }
    
    self.fallbackGameId = [defaults integerForKey:@"gameId"]; */
}

-(void)saveUserDefaults
{
/*	NSLog(@"Model: Saving User Defaults");
    [defaults setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"appVersion"];
    [defaults setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBuildNumber"]   forKey:@"buildNum"];
    [defaults setInteger:fallbackGameId           forKey:@"gameId"];
    if(player)
    {
        [defaults setInteger:player.playerId          forKey:@"playerId"];
        [defaults setInteger:player.playerMediaId     forKey:@"playerMediaId"];
        [defaults setObject:player.username           forKey:@"userName"];
        [defaults setObject:player.displayname        forKey:@"displayName"];
    }
    else
    {
        [defaults setInteger:0  forKey:@"playerId"];
        [defaults setInteger:0  forKey:@"playerMediaId"];
        [defaults setObject:@"" forKey:@"userName"];
        [defaults setObject:@"" forKey:@"displayName"];
    } */
    [defaults synchronize];
}

#pragma mark Core Data
/*
- (void) saveCOREData
{
    NSError *error = nil;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:@"Error saving to disk" message:[NSString stringWithFormat:@"%@",[error userInfo]]];
        }
    }
}

- (NSManagedObjectContext *) managedObjectContext
{
    if(!managedObjectContext)
    {
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if(coordinator)
        {
            managedObjectContext = [[NSManagedObjectContext alloc] init];
            [managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
    }
    return managedObjectContext;
}

- (NSManagedObjectModel *) managedObjectModel
{
    if(!managedObjectModel) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"UploadContent" withExtension:@"momd"];
        managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return managedObjectModel;
}

- (NSString *) applicationDocumentsDirectory
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator
{
    if(!persistentStoreCoordinator)
    {
        NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"UploadContent.sqlite"]];
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        NSError *error;
        if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error])
            NSLog(@"AppModel: Error getting the persistentStoreCoordinator");
	}
    return persistentStoreCoordinator;
}
*/

@end