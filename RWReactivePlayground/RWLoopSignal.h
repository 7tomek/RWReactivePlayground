#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <AFNetworking/AFNetworking.h>

@interface RWLoopSignal : NSObject

+ (RACSignal *)networkingStatusSignal;

@end
