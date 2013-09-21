//
//  PointIOController.h
//  Resume
//
//  Created by Jacob Hanshaw on 9/21/13.
//  Copyright (c) 2013 Jacob Hanshaw. All rights reserved.
//

@interface PointIOController : NSObject

typedef void (^PointIOLogInResultBlock)(BOOL succeeded, NSError *error);

@property (nonatomic) NSString *sessionKey;

+ (id) sharedPoint;
- (NSString *) getAppKey: (NSString *)keyToFind;
- (void) attemptLogInWithDefaultsAndCompletionBlock:(PointIOLogInResultBlock) completionBlock;
- (void) attemptLogInWithUsername:(NSString *) username password:(NSString *) password andCompletionBlock:(PointIOLogInResultBlock) completionBlock;
- (BOOL) loggedIn;
- (void) logOut;

@end