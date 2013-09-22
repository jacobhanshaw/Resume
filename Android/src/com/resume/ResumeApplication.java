package com.resume;

import com.parse.*;

import android.os.Bundle;
import android.app.Activity;
import android.app.Application;
import android.view.Menu;

public class ResumeApplication extends Application {

	@Override
	public void onCreate() {
		super.onCreate();
		
		Parse.initialize(this, "bxQ23QDg4BYEOwoG75eYyLePFkLJNUilfVT5NbQw", "XsYTDDQ87LpPwNrMsgEgyEhTwwtxZmtyZE8WmI8A");
		ParseUser.enableAutomaticUser();
		ParseACL defaultACL = new ParseACL();
		// Optionally enable public read access.
		// defaultACL.setPublicReadAccess(true);
		ParseACL.setDefaultACL(defaultACL, true);
		ParseFacebookUtils.initialize("706955959319048");
	}


}
