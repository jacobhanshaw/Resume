//
//  JSONConnection.h
//  ARIS
//
//  Created by David J Gagnon on 8/28/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ServiceResult;

@interface JSONConnection : NSObject



- (JSONConnection*)initWithRequest:(NSURLRequest *) request
                      andUserInfo:(NSMutableDictionary *)userInfo;

- (ServiceResult *) performSynchronousRequest;
- (void) performAsynchronousRequestWithDelegate: (id) aDelegate Handler: (SEL)aHandler;

@end