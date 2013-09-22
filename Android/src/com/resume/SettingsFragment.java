package com.resume;

import android.app.Activity;
import android.app.Fragment;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;

public class SettingsFragment extends Fragment{
	public SettingsFragment() {
		
	}
	
	@Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState) {
		View rootView = inflater.inflate(R.layout.fragment_settings, container, false);
		getActivity().setTitle("Settings");
		Button selectResumeButton = (Button) rootView.findViewById(R.id.bSelectResume);
		selectResumeButton.setOnClickListener(new View.OnClickListener() {
			public void onClick(View view) {
				Intent toResumeSelect = new Intent(getActivity(), SelectResumeActivity.class);
				startActivityForResult(toResumeSelect, 1);
			}

			
		});
		
		Button uploadResumeButton = (Button) rootView.findViewById(R.id.bUploadResume);
		uploadResumeButton.setOnClickListener(new View.OnClickListener() {
			public void onClick(View view) {
				Intent toResumeUpload = new Intent(getActivity(), UploadResumeFragment.class);
				startActivity(toResumeUpload);
			}			
		});
		return rootView;
	}
	
	public void uploadResume(View v) {
		
	}
	
	public void selectResume(View v) {
		Intent toResumeSelect = new Intent(getActivity(), SelectResumeActivity.class);
		startActivityForResult(toResumeSelect, 1);
	}
	
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (resultCode == Activity.RESULT_OK) {
            String sCurrentResumeName = data.getStringExtra("com.resume.SELECTEDRESUME");
            SharedPreferences settings = getActivity().getSharedPreferences("com.resume", 0);
    		SharedPreferences.Editor editor = settings.edit();
    		editor.putString("selectedResume", sCurrentResumeName);
    		editor.commit();
        }
    }
}
