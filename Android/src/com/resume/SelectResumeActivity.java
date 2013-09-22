package com.resume;

import java.util.ArrayList;
import java.util.List;

import Adapters.ResumeAdapter;
import android.app.Activity;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ArrayAdapter;
import android.widget.ListView;

import com.parse.FindCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;



public class SelectResumeActivity extends Activity {
	
	private Dialog progressDialog;
	private ListView lvResumes;
	static ResumeAdapter adapter;
	private ArrayList<String> alResumeList = new ArrayList<String>();

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_select_resume);
		
		//Fetch currently uploaded resumes
		//TODO
		SelectResumeActivity.this.progressDialog = ProgressDialog.show(SelectResumeActivity.this, "",
				"Fetching Resumes...", true);
		ParseQuery<ParseObject> query = ParseQuery.getQuery("Resume");
		query.whereEqualTo("user", ParseUser.getCurrentUser());
		query.findInBackground(new FindCallback<ParseObject>() {
		    public void done(List<ParseObject> resumeList, ParseException e) {
		        if (e == null) {
		        	saveResumes(resumeList);
		        	updateListView();
		            Log.d("Debug", "Retrieved " + resumeList.size() + " resumes");
		            SelectResumeActivity.this.progressDialog.dismiss();
		        } else {
		        	finish();
		            Log.d("Debug", "Error: " + e.getMessage());
		            SelectResumeActivity.this.progressDialog.dismiss();
		        }
		    }
		});
		
		lvResumes = (ListView) findViewById(R.id.lvUploadedResumes);		
		

		//List Click Listener
		lvResumes.setOnItemClickListener(new OnItemClickListener() {
			public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
				Intent resultIntent = new Intent();
				resultIntent.putExtra("com.resume.SELECTEDRESUME", alResumeList.get(position));
				setResult(RESULT_OK, resultIntent);
				finish();
			}
		});
	}
	
	private void updateListView() {
		adapter = new ResumeAdapter(this, R.id.tvResume, alResumeList);				
		lvResumes.setAdapter(adapter);
		lvResumes.invalidate();
	}
	
	private void saveResumes(List<ParseObject> resumeList) {
		for(int i = 0; i < resumeList.size(); i++) {
			alResumeList.add(resumeList.get(i).getString("title"));
			/*
			resumeList.get(i).fetchIfNeededInBackground(new GetCallback<ParseObject>() {
				public void done(ParseObject object, ParseException e) {
				     if (e == null) {
				    	 alResumeList.add(object.get("title").toString());
				     } else {
				    	 Log.v("Debug", "Error in saveResumes: " + e.getMessage());
				     }
				   }
			});			
			*/
		}
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.select_resume, menu);
		return true;
	}

}
