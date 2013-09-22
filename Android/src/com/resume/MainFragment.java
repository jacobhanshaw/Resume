package com.resume;

import java.io.File;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.nio.charset.CharacterCodingException;
import java.nio.charset.Charset;
import java.nio.charset.CharsetEncoder;
import java.util.Hashtable;
import java.util.List;

import android.app.Dialog;
import android.app.Fragment;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebView;
import android.widget.Button;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.MultiFormatWriter;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.integration.android.IntentIntegrator;
import com.google.zxing.integration.android.IntentResult;
import com.parse.FindCallback;
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

		Button bShare = (Button) rootView.findViewById(R.id.bShare);
		//List Click Listener
		bShare.setOnClickListener(new View.OnClickListener() {
			public void onClick(View view) {
//				createQR();
				/*
				IntentIntegrator integrator = new IntentIntegrator(getActivity());
				integrator.initiateScan();*/
			}			
		});

		return rootView;
	}

	public void createQR() {
		Charset charset = Charset.forName("UTF-8");
		CharsetEncoder encoder = charset.newEncoder();
		byte[] b = new String("http://google.com").getBytes();
		try {
			// Convert a string to UTF-8 bytes in a ByteBuffer
			ByteBuffer bbuf = encoder.encode(CharBuffer.wrap("utf 8 characters - i used hebrew, but you should write some of your own language characters"));
			b = bbuf.array();
		} catch (CharacterCodingException e) {
			System.out.println(e.getMessage());
		}

		String data;
		try {
			data = new String(b, "UTF-8");
			// get a byte matrix for the data
			BitMatrix matrix = null;
			int h = 100;
			int w = 100;
			com.google.zxing.Writer writer = new MultiFormatWriter();
			try {
				Hashtable<EncodeHintType, String> hints = new Hashtable<EncodeHintType, String>(2);
				hints.put(EncodeHintType.CHARACTER_SET, "UTF-8");
				matrix = writer.encode(data,
						com.google.zxing.BarcodeFormat.QR_CODE, w, h, hints);
			} catch (com.google.zxing.WriterException e) {
				System.out.println(e.getMessage());
			}

			// change this path to match yours (this is my mac home folder, you can use: c:\\qr_png.png if you are on windows)
			String filePath = "/sdcard/Download/qr.png";
			File file = new File(filePath);
			try {
				MatrixToImageWriter.writeToFile(matrix, "PNG", file);
				System.out.println("printing to " + file.getAbsolutePath());
			} catch (IOException e) {
				System.out.println(e.getMessage());
			}
		} catch (UnsupportedEncodingException e) {
			System.out.println(e.getMessage());
		}
	}


	private void getResume() {
		MainFragment.this.progressDialog = ProgressDialog.show(getActivity(), "",
				"Fetching Resumes...", true);
		SharedPreferences settings = getActivity().getSharedPreferences("com.resume", 0);
		String sCurrentResumeName = settings.getString("selectedResume", null);
		ParseQuery<ParseObject> query = ParseQuery.getQuery("Resume");
		query.whereEqualTo("user", ParseUser.getCurrentUser());
		query.whereEqualTo("title", sCurrentResumeName);
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

	public void onActivityResult(int requestCode, int resultCode, Intent intent) {
		IntentResult scanResult = IntentIntegrator.parseActivityResult(requestCode, resultCode, intent);
		if (scanResult != null) {
			// handle scan result
		}
		// else continue with any other code you need in the method
	}

}
