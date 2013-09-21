//
//  PointIOController.m
//  Resume
//
//  Created by Jacob Hanshaw on 9/21/13.
//  Copyright (c) 2013 Jacob Hanshaw. All rights reserved.
//

#import "PointIOController.h"

#define POINT_IO_USERNAME_KEY @"point_io_username"
#define POINT_IO_PASSWORD_KEY @"point_io_password"

@implementation PointIOController

@synthesize sessionKey = _sessionKey;

+ (id) sharedPoint
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
    self = [super init];
    if(self)
    {
		
	}
    return self;
}

- (void) dealloc
{
    
}

#pragma mark Access

-(NSString *)getAppKey: (NSString *)keyToFind
{
    // Query appKeys.plist Dictionary for value of provided key
    NSString *path                  = [[NSBundle mainBundle] pathForResource:@"AppKeys" ofType:@"plist"];
    NSMutableDictionary* tmpDict    = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSString *returnValue           = [tmpDict valueForKey:keyToFind];
    
    return returnValue;
    
}

- (void) attemptLogInWithDefaultsAndCompletionBlock:(PointIOLogInResultBlock) completionBlock
{
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:POINT_IO_USERNAME_KEY];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:POINT_IO_PASSWORD_KEY];
    
    if([username length] > 0 && [password length] > 0)
        [self attemptLogInWithUsername:username password:password andCompletionBlock:completionBlock];
}

- (void) attemptLogInWithUsername:(NSString *) username password:(NSString *) password andCompletionBlock:(PointIOLogInResultBlock) completionBlock
{
    
    BOOL success = NO;
    NSError *error;
    
    NSString *postString = [self getAppKey:@"AppKeyPostString"];
    
    NSLog(@"Inside LoginViewController.signIn EMAIL = %@, PASSWORD = %@",username,password);
    postString = [postString stringByAppendingFormat:@"&email=%@&password=%@", username, password];
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://api.point.io/v2/auth.json"]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURLResponse* urlResponseList;
    NSError* requestErrorList;
    NSData* response = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&urlResponseList
                                                         error:&requestErrorList];
    if(!response)
    {   NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"There was not a valid response from the server." forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:@"Connection" code:200 userInfo: details];
    }
    else
    {
        NSArray *JSONArrayAuth = [NSJSONSerialization JSONObjectWithData:response
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
        if([[JSONArrayAuth valueForKey:@"ERROR"] intValue] == 1)
        {
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:@"Incorrect username or password." forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"Log In" code:1 userInfo: details];
        }
        else
        {
            success = YES;
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:username forKey:POINT_IO_USERNAME_KEY];
            [defaults setObject:password forKey:POINT_IO_PASSWORD_KEY];
            [defaults synchronize];
            
            NSDictionary* result = [JSONArrayAuth valueForKey:@"RESULT"];
            _sessionKey = [result valueForKey:@"SESSIONKEY"];
        }
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    completionBlock(success, error);
}

- (BOOL) loggedIn
{
    return [_sessionKey length] > 0;
}

- (void) logOut
{
    _sessionKey = nil;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:POINT_IO_USERNAME_KEY];
    [defaults setObject:nil forKey:POINT_IO_PASSWORD_KEY];
    [defaults synchronize];
}

@end