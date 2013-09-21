//

#import "LoginViewController.h"

#import <Parse/Parse.h>
#import "PointIOController.h"

@interface LoginViewController() <UITextFieldDelegate>
{
    
}

@end

@implementation LoginViewController

@synthesize logInType = _logInType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
        self.title = @"Log In";
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _signUpButton.hidden = (_logInType != AppLogIn);
    _facebookLoginButton.hidden = (_logInType != AppLogIn);
    
    switch (_logInType) {
        case AppLogIn:
            _titleTextView.text = @"Resume Log In";
            break;
        case PointIOLogIn:
            _titleTextView.text = @"Point IO Log In";
            break;
        case DropboxLogIn:
            _titleTextView.text = @"Dropbox Log In";
            break;
        case AwsLogIn:
            _titleTextView.text = @"AWS Log In";
            break;
        case GoogleDriveLogIn:
            _titleTextView.text = @"Google Drive Log In";
            break;
        default:
            break;
    }
        
}

//Makes keyboard disappear on touch outside of keyboard or textfield
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_emailTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}

#pragma mark - UITextField Delegate Methods

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if(textField == _emailTextField)
    { [_passwordTextField becomeFirstResponder]; }
    if(textField == _passwordTextField)
    { [self logInButtonPressed:nil]; }
    return YES;
}

#pragma mark - Login mehtods

- (IBAction)signUpButtonPressed:(id)sender
{
    [_emailTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    
    if (![self NSStringIsValidEmail:_emailTextField.text])
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Error" message:@"Please Enter a Valid Email Address" delegate:self
                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else if ([_passwordTextField.text length] < 6)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Error" message:@"Please Enter a Password of 6 Characters or More" delegate:self
                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    PFUser *user = [PFUser user];
    user.username = _emailTextField.text;
    user.password = _passwordTextField.text;
    user.email = _emailTextField.text;
    
    __weak id weakSelfForBlock = self;
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [_activityIndicator stopAnimating];
        
        if (!error) {
            NSLog(@"User Created");
            [weakSelfForBlock logInSuccess];
        } else {
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Error" message:errorString delegate:self
                                  cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
    
    [_activityIndicator startAnimating];
}

- (IBAction)logInButtonPressed:(id)sender
{
    [_emailTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    
    __weak id weakSelfForBlock = self;
    
    if(_logInType == AppLogIn)
    {
        [PFUser logInWithUsernameInBackground:_emailTextField.text password:_passwordTextField.text
                                        block:^(PFUser *user, NSError *error) {
                                            [_activityIndicator stopAnimating];
                                            
                                            if (user) {
                                                NSLog(@"User Logged In");
                                                [weakSelfForBlock logInSuccess];
                                            } else {
                                                NSString *errorString = [[error userInfo] objectForKey:@"error"];
                                                UIAlertView *alert = [[UIAlertView alloc]
                                                                      initWithTitle:@"Error" message:errorString delegate:self
                                                                      cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                [alert show];
                                            }
                                        }];
    }
    else if (_logInType == PointIOLogIn)
    {
        [[PointIOController sharedPoint] attemptLogInWithUsername:_emailTextField.text password:_passwordTextField.text andCompletionBlock:^(BOOL success, NSError *error) {
            [_activityIndicator stopAnimating];
            
            if (success) {
                NSLog(@"User Logged In");
                [weakSelfForBlock logInSuccess];
            } else {
                NSString *errorString = [[error userInfo] objectForKey:@"error"];
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Error" message:errorString delegate:self
                                      cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
    
    [_activityIndicator startAnimating];
}

- (IBAction)facebookLoginButtonPressed:(id)sender
{
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using facebook
    __weak id weakSelfForBlock = self;
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [_activityIndicator stopAnimating]; // Hide loading indicator
        
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Uh oh. The user cancelled the Facebook login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        } else if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
            [weakSelfForBlock logInSuccess];
        } else {
            NSLog(@"User with facebook logged in!");
            [weakSelfForBlock logInSuccess];
        }
    }];
    
    [_activityIndicator startAnimating];
}

-(void) logInSuccess
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Email Validation

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

@end