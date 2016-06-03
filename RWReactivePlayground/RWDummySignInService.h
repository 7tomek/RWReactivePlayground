#import <Foundation/Foundation.h>

typedef void (^RWSignSimpleInResponse)(BOOL isValid);

typedef void (^RWSignInResponse)(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error);

@interface RWDummySignInService : NSObject

- (void)signInWithUsername:(NSString * _Nonnull)username password:(NSString * _Nonnull)password complete:(RWSignSimpleInResponse _Nonnull)completeBlock;

- (void)signNetInWithUsername:(NSString * _Nonnull)username password:(NSString * _Nonnull)password complete:(RWSignInResponse _Nonnull)completeBlock;

@end
