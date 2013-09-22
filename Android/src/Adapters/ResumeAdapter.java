package Adapters;

import java.util.ArrayList;

import com.resume.R;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

public class ResumeAdapter extends ArrayAdapter<String> {

	ArrayList<String> alResumes;
	
	public ResumeAdapter(Context context, int textViewResourceId, ArrayList<String> resumes) {
		super(context, textViewResourceId, resumes);
		alResumes =  resumes;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		View v = convertView;
		if(v==null) {
			LayoutInflater vi = (LayoutInflater) this.getContext().getSystemService(Context.LAYOUT_INFLATER_SERVICE);
			v = vi.inflate(R.layout.list_item_resume, null);
		}		
		String sResume = alResumes.get(position);
		if(sResume != null) {
			TextView name = (TextView) v.findViewById(R.id.tvResume);

			if(name != null) {
				name.setText(sResume);
			}
		}

		return v;
	}

}
