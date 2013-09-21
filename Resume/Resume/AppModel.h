//
//  AppModel.h
//  ARIS
//
//  Created by Ben Longoria on 2/17/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

@interface AppModel : NSObject


// CORE Data
//@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
//@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
//@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (AppModel *)sharedAppModel;

- (void) initUserDefaults;
- (void) saveUserDefaults;
- (void) loadUserDefaults;
//- (void) saveCOREData;

@end