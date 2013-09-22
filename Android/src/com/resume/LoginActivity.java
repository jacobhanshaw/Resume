package com.resume;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import utility.FontHelper;
import android.os.Bundle;
import android.app.Activity;
import android.content.Intent;
import android.view.Menu;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;

public class LoginActivity extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
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


		Intent intent = new Intent(this, MainActivity.class);
		startActivity(intent);

	}
}

