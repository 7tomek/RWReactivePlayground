#import "RWDummySignInService.h"
#import <AFNetworking/AFNetworking.h>

@implementation RWDummySignInService


- (void)signInWithUsername:(NSString *)username password:(NSString *)password complete:(RWSignSimpleInResponse)completeBlock {

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        BOOL success = [username isEqualToString:@"user"] && [password isEqualToString:@"password"];
        completeBlock(success);
    });
}

- (void)signNetInWithUsername:(NSString *)username password:(NSString *)password complete:(RWSignInResponse)completeBlock {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
    [cfg setTimeoutIntervalForRequest:1.0];

    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration: cfg];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];

    NSError *err;
    NSURLRequest *req = [serializer requestWithMethod:@"GET" URLString:@"https://raw.githubusercontent.com/7tomek/Service/master/success.json" parameters:nil error:&err];
    
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        NSLog(@"%@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        completeBlock(response, responseObject, error);
    }];
    
    [dataTask resume];
}


@end
