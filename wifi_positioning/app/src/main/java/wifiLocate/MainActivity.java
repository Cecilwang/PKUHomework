package wifiLocate;

import android.os.Bundle;
import android.app.Activity;
import android.content.Intent;
import android.view.Menu;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;

public class MainActivity extends Activity implements OnClickListener {

    private Button rssiInfo, tracking, sampling;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        rssiInfo = (Button) findViewById(R.id.rssiInfo);
        tracking = (Button) findViewById(R.id.tracking);
        sampling = (Button) findViewById(R.id.sampling);
        rssiInfo.setOnClickListener(this);
        tracking.setOnClickListener(this);
        sampling.setOnClickListener(this);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }

    @Override
    public void onClick(View v) {
        // TODO Auto-generated method stub
        switch (v.getId()) {
            case R.id.rssiInfo:
                Intent in2 = new Intent(MainActivity.this, WifiListActivity.class);//检测
                startActivity(in2);
                break;
            case R.id.sampling:
                Intent in3 = new Intent(MainActivity.this, Sampling.class);//采样
                startActivity(in3);
                break;
            case R.id.tracking:
                Intent in4 = new Intent(MainActivity.this, Tracking.class);//定位
                startActivity(in4);
                break;
        }
    }

}
