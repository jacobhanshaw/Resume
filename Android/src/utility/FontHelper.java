package utility;

import android.content.res.AssetManager;
import android.graphics.Typeface;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

public class FontHelper {

	public static Typeface face;
	
	public static void makeTypeface(AssetManager mgr, String path) {
		face = Typeface.createFromAsset(mgr, path);
	}
	
	public static void setFont(ViewGroup mContainer) {
		if (mContainer == null) return;

	    final int mCount = mContainer.getChildCount();

	    // Loop through all of the children.
	    for (int i = 0; i < mCount; ++i)
	    {
	        final View mChild = mContainer.getChildAt(i);
	        if (mChild instanceof TextView)
	        {
	            // Set the font if it is a TextView.
	            ((TextView) mChild).setTypeface(face);
	        }
	        else if (mChild instanceof ViewGroup)
	        {
	            // Recursively attempt another ViewGroup.
	            setFont((ViewGroup) mChild);
	        }
	    }
	}
	
}
