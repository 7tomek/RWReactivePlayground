#import "RWViewController.h"
#import "RWDummySignInService.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface RWViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UILabel *signInFailureText;

@property (strong, nonatomic) RWDummySignInService *signInService;

@end

@implementation RWViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.signInService = [RWDummySignInService new];
  
  // initially hide the failure message
  self.signInFailureText.hidden = YES;
  
  
  RACSignal *validUsernameSignal =
    [self.usernameTextField.rac_textSignal
      map:^id(NSString *text) {
        return @([self isValidUsername:text]);
      }];
  
  RACSignal *validPasswordSignal =
    [self.passwordTextField.rac_textSignal
      map:^id(NSString *text) {
        return @([self isValidPassword:text]);
      }];
  
  RAC(self.passwordTextField, backgroundColor) =
    [validPasswordSignal
      map:^id(NSNumber *passwordValid) {
        return [passwordValid boolValue] ? [UIColor clearColor] : [UIColor yellowColor];
      }];

  RAC(self.usernameTextField, backgroundColor) =
    [validUsernameSignal
      map:^id(NSNumber *passwordValid) {
       return [passwordValid boolValue] ? [UIColor clearColor] : [UIColor yellowColor];
      }];

  
  RACSignal *signUpActiveSignal =
    [RACSignal combineLatest:@[validUsernameSignal, validPasswordSignal]
                      reduce:^id(NSNumber *usernameValid, NSNumber *passwordValid) {
                        return @([usernameValid boolValue] && [passwordValid boolValue]);
                      }];

  [signUpActiveSignal subscribeNext:^(NSNumber *signupActive) {
     self.signInButton.enabled = [signupActive boolValue];
   }];
  
  [[[[self.signInButton
    rac_signalForControlEvents:UIControlEventTouchUpInside]
    doNext:^(id x) {
      self.signInButton.enabled = NO;
      self.signInFailureText.hidden = YES;
    }]
    flattenMap:^id(id x) {
      return [self signInSignal];
    }]
   subscribeNext:^(id response) {
       self.signInButton.enabled = YES;
       self.signInFailureText.hidden = YES;
       [self performSegueWithIdentifier:@"signInSuccess" sender:self];
   }];
}

- (BOOL)isValidUsername:(NSString *)username {
  return username.length > 1;
}

- (BOOL)isValidPassword:(NSString *)password {
  return password.length > 1;
}

-(RACSignal *)signInSignal {
  return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    [self.signInService
     signNetInWithUsername:self.usernameTextField.text
     password:self.passwordTextField.text
     complete:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
         
       [subscriber sendNext:responseObject];
       [subscriber sendCompleted];
     }];
    return nil;
  }];
}


@end
