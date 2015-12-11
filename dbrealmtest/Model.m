//
//  Model.m
//  dbrealmtest
//
//  Created by Jingshao Chen on 12/8/15.
//  Copyright © 2015 Jingshao Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"

@implementation Dog
+ (NSString *)primaryKey
{
    return @"id";
}

+ (NSArray *)indexedProperties
{
    return @[@"id", @"name"];
}

@end


@implementation Person
+ (NSString *)primaryKey
{
    return @"id";
}

+ (NSArray *)indexedProperties
{
    return @[@"id", @"name"];
}

+ (NSDictionary *)defaultPropertyValues
{
    return @{@"walkDistance": @0};
}

@end


@implementation SRDB

+ (RLMRealm *)sharedDB
{
    BOOL encrypt = YES;
    if (encrypt) {
        NSString *keystring = @"encrypt key 143413413 43 413 4 1324 13 243 24 123 4 34 13 241 324 13413 2413241324312431241324321 41324 1341341324141341341324134 13 41 34 134 31 24132424132412341241343 124 134 13 413 4 134 32 41 34 132 43 24 1341 34 13 41 34 134 13 413 4 134 13 4 134 31 4 13 431 4 3124 43546535647 746878o243u5oi4u5iojiuoij voi2oi5oif2oi5oi2foioinof2o";
        const char *c = [keystring UTF8String];
        
        //NSMutableData *key = [NSMutableData dataWithLength:64];
        NSData *key = [NSData dataWithBytes:c length:64];
        
        //SecRandomCopyBytes(kSecRandomDefault, key.length, (uint8_t *)key.mutableBytes);
        
        // Open the encrypted Realm file
        RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
        config.encryptionKey = key;
        NSError *error;
        RLMRealm *realm = [RLMRealm realmWithConfiguration:config error:&error];
        assert(realm != nil);
        
        return realm;
        
    } else {
        return [RLMRealm defaultRealm];
    }
}

@end