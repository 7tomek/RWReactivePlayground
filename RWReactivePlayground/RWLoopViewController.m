#import "RWLoopViewController.h"
#import "RWLoopSignal.h"

@interface RWLoopViewController()

@property (nonatomic, weak) IBOutlet UIButton *btnInvoke;
@property (nonatomic, weak) IBOutlet UIButton *btnCancel;
@property (nonatomic, weak) IBOutlet UIButton *btnChange;

@property (nonatomic, strong) RACDisposable *loopDisposable;

@end

@implementation RWLoopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initMainLoop:3.0];
    [self initInvoke];
    [self initChange];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.loopDisposable dispose];
    [super viewWillDisappear:animated];
}

- (void)initInvoke {
    [[[_btnInvoke rac_signalForControlEvents:UIControlEventTouchUpInside] flattenMap:^RACStream *(id value) {
        return [RWLoopSignal networkingStatusSignal];
    }] subscribeNext:^(RACTuple *result) {
        NSLog(@"invoke result, %@", [NSDate date]);
    }];
}

- (void)initChange {
    [[_btnChange rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSLog(@"change");
        [self.loopDisposable dispose];
        [self initMainLoop:1.0];
    }];
}

- (void)initMainLoop:(int)interval {
    
    RACSignal *singal = [[[RACSignal interval:interval
    onScheduler:[RACScheduler schedulerWithPriority:RACSchedulerPriorityBackground name:@"Loop"]]
    takeUntil:[_btnCancel rac_signalForControlEvents:UIControlEventTouchUpInside]]
    takeUntil:[_btnChange rac_signalForControlEvents:UIControlEventTouchUpInside]];
    
    self.loopDisposable = [[[singal flattenMap:^RACStream *(id value) {
        return [RWLoopSignal networkingStatusSignal];
    }]
    map:^id(RACTuple *result) {
        RACTupleUnpack(NSURLResponse *response,
                       id responseObject,
                       NSError *error) = result;
        // Parsing
        return @1;
        
    }]
    subscribeNext:^(id x) {
        NSLog(@"=> result %@, %@", x,[NSDate date]);
        NSLog(@"%@", [NSThread currentThread]);
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
}

@end
