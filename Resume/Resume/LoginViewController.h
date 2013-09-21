//

@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)signUpButtonPressed:(id)sender;
- (IBAction)logInButtonPressed:(id)sender;
- (IBAction)facebookLoginButtonPressed:(id)sender;
@end