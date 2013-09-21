//
//  JSONConnection.m
//  ARIS
//
//  Created by David J Gagnon on 8/28/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "JSONConnection.h"

#import "ServiceResult.h"

@interface JSONConnection() <NSURLConnectionDelegate>
{
    NSURLRequest *request;
    NSMutableDictionary *userInfo;
    NSURLConnection *connection;
    NSMutableData *asyncData;
    __weak id delegate;
    SEL handler;
}

@end

@implementation JSONConnection

- (JSONConnection*)initWithRequest:(NSURLRequest *) aRequest andUserInfo:(NSMutableDictionary *)aUserInfo
{
	self = [super init];
    if(self)
    {
        request = aRequest;
        userInfo = aUserInfo;
    }
	return self;
}

- (void)dealloc
{
    if (connection)
        [connection cancel];
}

- (ServiceResult *) performSynchronousRequest
{
    // Make synchronous request
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURLResponse *response = [[NSURLResponse alloc] init];
    NSError *error = [[NSError alloc] init];
    NSData* resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
#warning do more here
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	NSString *resultString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
	
	//Get the JSONResult here
	ServiceResult *jsonResult = [[ServiceResult alloc] initWithJSONString:resultString andUserData:userInfo];
	
	return jsonResult;
}

- (void) performAsynchronousRequestWithDelegate: (id) aDelegate Handler: (SEL)aHandler
{
    delegate = aDelegate;
    handler = aHandler;

    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[connection start];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData
{
    if (asyncData == nil)
    {
        NSMutableData *asyncDataAlloc = [[NSMutableData alloc] initWithCapacity:2048];
        asyncData = asyncDataAlloc;
    }
    
    [asyncData appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection
{
    //end the UI indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    //throw out the connection
    connection=nil;
    
    //Convert the data into a string
    NSString *jsonString = [[NSString alloc] initWithData:asyncData
												 encoding:NSUTF8StringEncoding];
    
    //throw out the data
    asyncData=nil;
	
	//Get the JSONResult here
	ServiceResult *jsonResult = [[ServiceResult alloc] initWithJSONString:jsonString andUserData:userInfo];
    
	if (delegate != nil && handler != nil && [delegate respondsToSelector:handler])
		[delegate performSelector:handler withObject:jsonResult];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"NSNotification: ConnectionLost");
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ConnectionLost" object:nil]];
	// inform the user
    NSLog(@"*** JSONConnection: requestFailed: %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

}
 
@end