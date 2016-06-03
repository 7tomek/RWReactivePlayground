#import "RWLoopSignal.h"

typedef void (^RWLoopResponse)(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error);

@implementation RWLoopSignal

+ (RACSignal *)networkingStatusSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *task = [self sessionDataTaskStatus:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            [subscriber sendNext:RACTuplePack(response, responseObject, error)];
        }];
        return nil;
        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }];
}

+ (NSURLSessionDataTask *)sessionDataTaskStatus:(RWLoopResponse)responseBlock {
    NSURLSessionConfiguration *cfg = [RWLoopSignal initConfig];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration: cfg];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    
    NSError *err;
    NSURLRequest *req = [serializer requestWithMethod:@"GET" URLString:@"https://raw.githubusercontent.com/7tomek/Service/master/success.json" parameters:nil error:&err];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        //NSLog(@"%@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        responseBlock(response, responseObject, error);
    }];
    
    [dataTask resume];
    return dataTask;

}

+ (NSURLSessionConfiguration *)initConfig {
    
    NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
    [cfg setTimeoutIntervalForRequest:1.0];
    
    return cfg;
}

@end
