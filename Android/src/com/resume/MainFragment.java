package com.resume;

import java.util.List;

import android.app.Dialog;
import android.app.Fragment;
import android.app.ProgressDialog;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebView;

import com.parse.FindCallback;
import com.parse.GetDataCallback;
import com.parse.ParseException;
import com.parse.ParseFile;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;

public class MainFragment extends Fragment{
	
	private Dialog progressDialog;
	
	public MainFragment() {
		
	}
	
	@Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState) {
		View rootView = inflater.inflate(R.layout.fragment_main, container, false);
		getActivity().setTitle("Home Page");
		
		getResume();
	    
		
		return rootView;
	}
	
	private void getResume() {
		MainFragment.this.progressDialog = ProgressDialog.show(getActivity(), "",
				"Fetching Resumes...", true);
		ParseQuery<ParseObject> query = ParseQuery.getQuery("Resume");
		query.whereEqualTo("user", ParseUser.getCurrentUser());
		query.findInBackground(new FindCallback<ParseObject>() {
		    public void done(List<ParseObject> resumeList, ParseException e) {
		        if (e == null) {
		        	openResume(resumeList);
		            Log.d("Debug", "Retrieved " + resumeList.size() + " resumes");
		            MainFragment.this.progressDialog.dismiss();
		        } else {
		            Log.d("Debug", "Error: " + e.getMessage());
		            MainFragment.this.progressDialog.dismiss();
		        }
		    }
		});
	}
	private void openResume(List<ParseObject> resumeList) {
		ParseFile applicantResume = (ParseFile)resumeList.get(0).get("applicantResumeFile");
		WebView mWebView = (WebView) getActivity().findViewById(R.id.wvPdfView);
	    mWebView.getSettings().setJavaScriptEnabled(true);
//	    mWebView.getSettings().setPluginsEnabled(true);
	    mWebView.loadUrl("https://docs.google.com/gview?embedded=true&url="+applicantResume.getUrl());
	}
	
}
