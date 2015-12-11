//
//  Model.h
//  dbrealmtest
//
//  Created by Jingshao Chen on 12/8/15.
//  Copyright © 2015 Jingshao Chen. All rights reserved.
//

#ifndef Model_h
#define Model_h

#import <Realm/Realm.h>

@class Person;

@interface Dog : RLMObject
@property NSString  *id;
@property NSString  *name;
@property Person    *owner;
@end
RLM_ARRAY_TYPE(Dog)

@interface Person : RLMObject
@property NSString  *id;
@property NSString  *name;
@property NSDate    *birthdate;
@property NSNumber<RLMDouble>  *walkDistance;
@property RLMArray<Dog *><Dog> *dogs;
@end
RLM_ARRAY_TYPE(Person)

@interface SRDB : NSObject

+ (RLMRealm *)sharedDB;

@end


#endif /* Model_h */
