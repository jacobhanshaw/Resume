package com.resume;

import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.concurrent.ExecutionException;

import utility.FontHelper;
import android.app.Activity;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.EditText;

import com.parse.FindCallback;
import com.parse.LogInCallback;
import com.parse.ParseException;
import com.parse.ParseFacebookUtils;
import com.parse.ParseFile;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.parse.SignUpCallback;

public class LoginActivity extends Activity {

	private Dialog progressDialog;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_INDETERMINATE_PROGRESS);
		setContentView(R.layout.activity_login);
		//Generate App Typeface
		FontHelper.makeTypeface(getAssets(), "Zag Regular.otf");
		//Set Activity Typeface
		ViewGroup view = (ViewGroup) findViewById(R.id.activity_login);
		FontHelper.setFont(view);
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.login, menu);
		return true;
	}

	public void login(View v) {
		
		//Pull Field Info
		EditText tEmail = (EditText) findViewById(R.id.loginEmail);
		EditText tPassword = (EditText) findViewById(R.id.loginPassword);
		String sEmail = tEmail.getText().toString();
		String sPassword = tPassword.getText().toString();		
		
		LoginActivity.this.progressDialog = ProgressDialog.show(LoginActivity.this, "",
				"Logging In...", true);
		ParseUser.logInInBackground(sEmail, sPassword, new LogInCallback() {
			  public void done(ParseUser user, ParseException e) {
			    if (user != null) {
			      success();
			    } else {
			    	Log.e("Debug", "Sign In Error: " + e.getMessage());
			    }
			    LoginActivity.this.progressDialog.dismiss();
			  }
			});
			
	}
	
	public void loginFacebook(View v) throws IOException {
		LoginActivity.this.progressDialog = ProgressDialog.show(LoginActivity.this, "",
				"Logging In With Facebook...", true);
		ParseFacebookUtils.logIn(this, new LogInCallback() {
			  @Override
			  public void done(ParseUser user, ParseException err) {
			    if (user == null) {
			      Log.d("Debug", "Uh oh. The user cancelled the Facebook login.");
			      LoginActivity.this.progressDialog.dismiss();
			    } else if (user.isNew()) {
			      Log.d("Debug", "User signed up and logged in through Facebook!");
			      LoginActivity.this.progressDialog.dismiss();
			      success();
			    } else {
			      Log.d("Debug", "User logged in through Facebook!");
			      LoginActivity.this.progressDialog.dismiss();
			      success();
			    }
			  }
			});
			
	}

	private void success() {
		Intent intent = new Intent(this, MainActivity.class);
		startActivity(intent);
	}

	public void register(View v) throws InterruptedException, ExecutionException {
		//Pull Field Info
		EditText tEmail = (EditText) findViewById(R.id.loginEmail);
		EditText tPassword = (EditText) findViewById(R.id.loginPassword);
		String sEmail = tEmail.getText().toString();
		String sPassword = tPassword.getText().toString();

		ParseUser user = new ParseUser();
		user.setUsername(sEmail);
		user.setPassword(sPassword);
		user.setEmail(sEmail);

		LoginActivity.this.progressDialog = ProgressDialog.show(LoginActivity.this, "",
				"Registering...", true);
		user.signUpInBackground(new SignUpCallback() {
			public void done(ParseException e) {
				if (e == null) {
					success();
				} else {
					Log.e("Debug", "Register Error: " + e.getMessage());
				}
				LoginActivity.this.progressDialog.dismiss();
			}
		});
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
	  super.onActivityResult(requestCode, resultCode, data);
	  ParseFacebookUtils.finishAuthentication(requestCode, resultCode, data);
	}
}


