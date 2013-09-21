//

@interface LoginViewController : UIViewController

typedef enum {
	AppLogIn,
    PointIOLogIn,
    DropboxLogIn,
    AwsLogIn,
    GoogleDriveLogIn
} LogInType;

@property (assign, readwrite) LogInType logInType;

@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *logInButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookLoginButton;

@property (weak, nonatomic) IBOutlet UITextView *titleTextView;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)signUpButtonPressed:(id)sender;
- (IBAction)logInButtonPressed:(id)sender;
- (IBAction)facebookLoginButtonPressed:(id)sender;

@end