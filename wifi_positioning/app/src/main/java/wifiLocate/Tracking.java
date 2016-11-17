package wifiLocate;

/**
 * Created by wan on 5/27/2016.
 */

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.InterruptedIOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.net.wifi.ScanResult;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.TextView;

public class Tracking extends Activity {
	private TextView info;
	ThreadFlag mythread;
	//------------------
	float x = 0;
	float y = 0;
	Map<String, Integer> now_status = new HashMap<String, Integer>();
	Map<Point, Map<String, Integer>> db = new HashMap<Point, Map<String, Integer>>();
	private WifiManager wifiManager;
	private MyView myview = null;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_tracking);
		RelativeLayout rl_Main;
		rl_Main = (RelativeLayout) findViewById(R.id.rl_main);
		myview = new MyView(this);
		rl_Main.addView(myview);
		info = (TextView) this.findViewById(R.id.info);
		Button button = (Button) findViewById(R.id.readmap);
		button.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View view) {
				mythread = new ThreadFlag();
				mythread.start();
			}
		});
		button = (Button) findViewById(R.id.exit);
		button.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View view) {
				mythread.exit = true;
				try {
					mythread.join();
				}
				catch (InterruptedException e) {
					Log.e("Exception", e.toString());
				}
				myview.change(0,0,"");
			}
		});
		init();
	}

	private  void creatdb(String s){
		System.out.println("create db");
		db.clear();
		//System.out.println(s);
		String[] pos = s.split("@");
		//System.out.println("pos num : "+pos.length);
		for(int j = 0; j < pos.length; ++j) {
			String one_pos = pos[j];
			//System.out.println("one length  : "+one_pos.length());
			//System.out.println(one_pos);
			if (one_pos.length() == 0) continue;
			Map<String, Integer> tmp = new HashMap<String, Integer>();
			String[] c = one_pos.split(" ");
			Point now = new Point();
			now.x = Float.parseFloat(c[0]);
			now.y = Float.parseFloat(c[1]);
			for (int i = 2; i < c.length; i+=2){
				tmp.put(c[i].replaceAll("\\s*", ""), Integer.valueOf( c[i+1].replaceAll("\\s*", "")));
			}
			db.put(now, tmp);
		}

		System.out.println("difference");
		for(Point pointa : db.keySet()){
			Map<String, Integer> t1 = db.get(pointa);
			for(Point pointb : db.keySet()){
				if(pointb == pointa) continue;

				Map<String, Integer> t2 = db.get(pointb);

				for(String mac: t1.keySet()){
					System.out.print(" " + mac + " " + t1.get(mac));
				}
				System.out.println("");

				for(String mac: t2.keySet()){
					System.out.print(" " + mac + " " + t2.get(mac));
				}
				System.out.println("");

				double tmp = 0;
				double length = 0;
				for (String mac: t1.keySet()) {
					if (t2.containsKey(mac)) {
						tmp += t2.get(mac) * t1.get(mac);
					}
					length += t1.get(mac) * t1.get(mac);
				}
				tmp /= Math.sqrt(length);
				length = 0;
				for (String mac: t2.keySet()) {
					length += t2.get(mac) * t2.get(mac);
				}
				tmp /= Math.sqrt(length);

				System.out.print(" " + pointa.x + " " + pointa.y);
				System.out.print(" " + pointb.x + " " + pointb.y);
				System.out.print(" " + tmp);
				System.out.println("");
				System.out.println("");
			}
			System.out.println("-----");
		}

	}

	private void init(){
		try {
			EditText filename = (EditText) findViewById(R.id.filename);
			String name = String.valueOf(filename.getText());
			String db_contnet = getStringFromFile(name);
			creatdb(db_contnet);
		}
		catch (Exception e) {
			Log.e("Exception", e.toString());
		}

		wifiManager = (WifiManager) getSystemService(Context.WIFI_SERVICE);
		openWifi();
		System.out.print("nihao");
	}


	public class ThreadFlag extends Thread {
		public volatile boolean exit = false;

		private  void update_pos(){
			double sim = 0;
			String content = new String();
			for (Point point: db.keySet()) {
				double tmp = 0;
				double length = 0;
				int st=0;
				int ft = 0;
				for (String mac: db.get(point).keySet()) {
					if (now_status.containsKey(mac)) {
						tmp += now_status.get(mac) * db.get(point).get(mac);
						//System.out.println(""+db.get(point).get(mac));
						st ++;
					} else {
						ft ++;
					}
					length += db.get(point).get(mac) * db.get(point).get(mac);
				}
				tmp /= Math.sqrt(length);
				length = 0;
				for (String mac: now_status.keySet()){
					length += now_status.get(mac) *now_status.get(mac);
				}
				tmp /= Math.sqrt(length);

				content += "\n" + (int)point.x + " " + (int)point.y + " : " + tmp;
				System.out.println(point.x + " " + point.y + " : " + tmp + "   " +
						st + " " + ft);
				if (tmp > sim) {
					x = point.x;
					y = point.y;
					sim  = tmp;
				}
			}
			myview.change(x,y, content);
		}

		public void run() {
			init();

			while (!exit) {
				try {
					Thread.sleep(300);
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
				wifiManager.startScan();
				List<ScanResult> list = wifiManager.getScanResults();
				now_status.clear();
				for (ScanResult result : list) {
					now_status.put(result.BSSID, result.level);
				}
				filter();
				update_pos();
			}
		}
	}

	private void filter() {
		List<Map.Entry<String, Integer>> list = new ArrayList<Map.Entry<String, Integer>>(now_status.entrySet());
                //然后通过比较器来实现排序
                Collections.sort(list,new Comparator<Map.Entry<String, Integer>>() {
                    //升序排序
                    public int compare(Map.Entry<String, Integer> a,
                                       Map.Entry<String, Integer> b) {
                        if(a.getValue() > b.getValue() ) return -1;
                        if(a.getValue() < b.getValue() ) return 1;
                        return 0;
                    }

                });
		now_status.clear();
		for (int i = 0; i < 2; i++)
			now_status.put(list.get(i).getKey(), list.get(i).getValue());
	}

	private void openWifi() {
		if (!wifiManager.isWifiEnabled()) {
			wifiManager.setWifiEnabled(true);
		}
	}

	class MyView extends View{
		Paint paint = new Paint();
		Point point = new Point();
		public MyView(Context context) {
			super(context);
			this.setY(300);
			paint.setColor(Color.RED);
			paint.setStrokeWidth(15);
			paint.setStyle(Paint.Style.STROKE);
		}

		@Override
		protected void onDraw(Canvas canvas) {
			Bitmap b= BitmapFactory.decodeResource(getResources(), R.drawable.bb);
			canvas.drawBitmap(b, 0, 0, paint);
			canvas.drawCircle(point.x, point.y, 5, paint);
		}

		public void change(float x, float y, final String content) {
			point.x = x;
			point.y = y;
			runOnUiThread(new Runnable() {
				@Override
				public void run() {
					info.setText(content);
					invalidate();
				}
			});

		}
	}

	class Point {
		float x, y;
	}

	private  String convertStreamToString(InputStream is) throws Exception {
		BufferedReader reader = new BufferedReader(new InputStreamReader(is));
		StringBuilder sb = new StringBuilder();
		String line = null;
		while ((line = reader.readLine()) != null) {
			sb.append(line).append("\n");
		}
		reader.close();
		return sb.toString();
	}

	private  String getStringFromFile (String filePath) throws Exception {
		FileInputStream in = openFileInput(filePath);
		String ret = convertStreamToString(in);
		in.close();
		System.out.println("Open file ok");
		return ret;
	}
}