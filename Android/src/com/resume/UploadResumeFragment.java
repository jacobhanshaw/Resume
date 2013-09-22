package com.resume;

import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URISyntaxException;

import android.app.Activity;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

import com.parse.ParseFile;
import com.parse.ParseObject;
import com.parse.ParseUser;

public class UploadResumeFragment extends Activity{
	
	private static final int FILE_SELECT_CODE = 0;
	private Dialog progressDialog;
	private String sResumePath = null;
	
	@Override
    public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);		
		
		//Prompt User to browse for resume
		exploreForResume();	    
		
	}
	
	private void exploreForResume() {
		Intent intent = new Intent(Intent.ACTION_GET_CONTENT); 
	    intent.setType("*/*"); 
	    intent.addCategory(Intent.CATEGORY_OPENABLE);

	    try {
	        startActivityForResult(
	                Intent.createChooser(intent, "Select a Resume to Upload"),
	                FILE_SELECT_CODE);
	    } catch (android.content.ActivityNotFoundException ex) {
	        // Potentially direct the user to the Market with a Dialog
	        Toast.makeText(this, "Please install a File Manager.", 
	                Toast.LENGTH_SHORT).show();
	    }
	}
	
	private void uploadResume() {
		InputStream inputStream = null;
		try 
	    {
	    	UploadResumeFragment.this.progressDialog = ProgressDialog.show(UploadResumeFragment.this, "",
					"Uploading Resume...", true);
	        inputStream = new FileInputStream(sResumePath);
	        byte[] data = readFully(inputStream);
	        String sFileName = sResumePath.substring(sResumePath.lastIndexOf("/")+1);
	        ParseFile file = new ParseFile(sFileName, data);
	        file.saveInBackground();
	        ParseObject resume = new ParseObject("Resume");
	        resume.put("title", file.getName().toString());
			resume.put("applicantResumeFile", file);
	        resume.put("user", ParseUser.getCurrentUser());
	        resume.saveInBackground();
	        UploadResumeFragment.this.progressDialog.dismiss();
	    } 
	    catch (Exception e) {
	    	Log.v("Debug", "Shit didn't work: " + e.getMessage());
	    }
	    finally
	    {
	        if (inputStream != null)
	        {
	            try {
					inputStream.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
	        }
	    }
	    finish();
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
	    switch (requestCode) {
	        case FILE_SELECT_CODE:
	        if (resultCode == RESULT_OK) {
	            // Get the Uri of the selected file 
	            Uri uri = data.getData();
	            // Get the path
	            try {
					String path = getPath(this, uri);
					sResumePath = path;
				} catch (URISyntaxException e) {
					Log.e("Debug", "getPath Error: " + e.getMessage());
				}
	        }
	        break;
	    }
	    super.onActivityResult(requestCode, resultCode, data);
	    uploadResume();
	}
	
	public static String getPath(Context context, Uri uri) throws URISyntaxException {
	    if ("content".equalsIgnoreCase(uri.getScheme())) {
	        String[] projection = { "_data" };
	        Cursor cursor = null;

	        try {
	            cursor = context.getContentResolver().query(uri, projection, null, null, null);
	            int column_index = cursor.getColumnIndexOrThrow("_data");
	            if (cursor.moveToFirst()) {
	                return cursor.getString(column_index);
	            }
	        } catch (Exception e) {
	            // Eat it
	        }
	    }
	    else if ("file".equalsIgnoreCase(uri.getScheme())) {
	        return uri.getPath();
	    }

	    return null;
	} 
	
	public static byte[] readFully(InputStream stream) throws IOException
	{
	    byte[] buffer = new byte[8192];
	    ByteArrayOutputStream baos = new ByteArrayOutputStream();

	    int bytesRead;
	    while ((bytesRead = stream.read(buffer)) != -1)
	    {
	        baos.write(buffer, 0, bytesRead);
	    }
	    return baos.toByteArray();
	}
}
