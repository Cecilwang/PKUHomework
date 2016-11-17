package wifiLocate;

/**
 * Created by wan on 5/27/2016.
 */

import android.app.ActionBar;
import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Point;
import android.net.wifi.ScanResult;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.SystemClock;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import org.apache.http.util.EncodingUtils;

import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Sampling extends Activity {
    private Button saveButton, stopButton;
    ThreadFlag mythread;
    TextView info, info_time;
    //------------------
    float x = 0;
    float y = 0;
    int sample_time;
    Map<String, SampleResult> sampleResultMap = new HashMap<String, SampleResult>();
    private WifiManager wifiManager;
    private  FileOutputStream out;

    private OnClickListener listener = new OnClickListener(){//这个没有写好
        @Override
        public void onClick(View v) {
            if(v==saveButton){
                sampleResultMap.clear();
                sample_time = 0;

                try {
                    EditText filename = (EditText) findViewById(R.id.filename);
                    String name = String.valueOf(filename.getText());
                    out = openFileOutput(name, Context.MODE_APPEND);
                }
                catch (IOException e) {
                    Log.e("Exception", e.toString());
                }
                mythread = new ThreadFlag();
                mythread.start();
            }
            if(v==stopButton){
                System.out.println("save");
                try {
                    String out_content = String.format("@%f %f", x,y);
                    System.out.println(out_content);
                    out.write(out_content.getBytes("UTF-8"));
                }
                catch (IOException e) {
                    Log.e("Exception", e.toString());
                }

                List<Map.Entry<String, SampleResult>> list = new ArrayList<Map.Entry<String, SampleResult>>(sampleResultMap.entrySet());
                //然后通过比较器来实现排序
                Collections.sort(list,new Comparator<Map.Entry<String, SampleResult>>() {
                    //升序排序
                    public int compare(Map.Entry<String, SampleResult> a,
                                       Map.Entry<String, SampleResult> b) {
                        if(a.getValue().time > b.getValue().time) return -1;
                        if(a.getValue().time < b.getValue().time) return 1;
                        if(a.getValue().rssi > b.getValue().rssi) return -1;
                        if(a.getValue().rssi < b.getValue().rssi) return 1;
                        return 0;
                    }

                });

                int i = 0;
                for(Map.Entry<String, SampleResult> mapping:list){
                    i++;
                    if(i > 2) break;
                    SampleResult one_sample = mapping.getValue();
                    one_sample.rssi = one_sample.rssi/one_sample.time;
                    String out_content =
                            String.format(" %s %d", mapping.getKey(), one_sample.rssi);
                    try {
                        out.write(out_content.getBytes("UTF-8"));
                    }
                    catch (IOException e) {
                        Log.e("Exception", e.toString());
                    }


                    System.out.println(out_content);

                    //System.out.println(mapping.getKey()+":"+mapping.getValue());
                }

                sample_time = 0;
                try {
                    out.close();
                }
                catch (IOException e) {
                    Log.e("Exception", e.toString());
                }
                mythread.exit = true;
                try {
                    mythread.join();
                }
                catch (InterruptedException e) {
                    Log.e("Exception", e.toString());
                }
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Sampling.this.info_time.setText("");
                    }
                });

            }
        }

    };

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_sampling);
        RelativeLayout rl_Main;
		rl_Main = (RelativeLayout) findViewById(R.id.rl_main);
		rl_Main.addView( new MyView(this));
        saveButton = (Button)this.findViewById(R.id.saveButton);
        saveButton.setOnClickListener(listener);
        stopButton = (Button)this.findViewById(R.id.stopButton);
        stopButton.setOnClickListener(listener);
        info=(TextView) this.findViewById(R.id.info);
        info_time=(TextView) this.findViewById(R.id.sample_time);

        init();
	}

    public class ThreadFlag extends Thread {
        public volatile boolean exit = false;

        public void run() {
            while (!exit) {
                sample_time++;

                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Sampling.this.info_time.setText(Integer.toString(sample_time));
                    }
                });

                try {
                    Thread.sleep(300);
                    wifiManager.startScan();
                    List<ScanResult> list = wifiManager.getScanResults();

                    for (ScanResult result : list) {
                        SampleResult tmp = new SampleResult();
                        try{
                            tmp = sampleResultMap.get(result.BSSID);
                            tmp.rssi += result.level;
                            tmp.time++;
                        }
                        catch(NullPointerException e){
                            tmp = new SampleResult();
                            tmp.rssi = result.level;
                            tmp.time = 1;
                        }

                        sampleResultMap.put(result.BSSID, tmp);
                    }
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    private void init(){
        wifiManager = (WifiManager) getSystemService(Context.WIFI_SERVICE);
        openWifi();
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

		@Override
		public boolean onTouchEvent(MotionEvent event) {
			switch (event.getAction()) {
				case MotionEvent.ACTION_DOWN:
                    x = event.getX();
                    y = event.getY();
					point.x = event.getX();
					point.y = event.getY();
                    Sampling.this.info.setText("x="+event.getX()+"y="+event.getY());
			}
			invalidate();
			return true;
		}
	}

	class Point {
		float x, y;
	}

    class SampleResult{
        String BSSID;
        int rssi;
        int time;
    }

}
