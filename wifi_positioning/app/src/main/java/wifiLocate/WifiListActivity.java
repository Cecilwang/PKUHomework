package wifiLocate;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import android.app.Activity;
import android.content.Context;
import android.net.wifi.ScanResult;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ListView;
import android.widget.TextView;

public class WifiListActivity extends Activity {

    private WifiManager wifiManager;
    List<ScanResult> list;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_wifi_list);
        final WifiListActivity this_pointer = this;
        final ListView listView = (ListView) findViewById(R.id.listView);
        wifiManager = (WifiManager) getSystemService(Context.WIFI_SERVICE);
        openWifi();
        new Thread(new Runnable() {
            @Override
            public void run() {
                int i = 0;
                while (true) {
                    i++;
                    System.out.println("Result " + i);
                    list = wifiManager.getScanResults();
                    for (ScanResult result : list) {
                        System.out.println(String.format("rssi:%d, mac:%s", result.level, result.BSSID));
                    }
                    System.out.println();
                    try {
                        Thread.sleep(300);
                        listView.post(new Runnable() {
                            @Override
                            public void run() {//这个刷新ui线程
                                wifiManager.startScan();
                                list = wifiManager.getScanResults();

                                Collections.sort(list, new Comparator<ScanResult>() {
                                    public int compare(ScanResult a, ScanResult b) {
                                        if (a.level > b.level) return -1;
                                        if (a.level < b.level) return 1;
                                        return 0;
                                    }
                                });


                                List<ScanResult> list1 = new ArrayList<ScanResult>();
                                list1.add(list.get(0));
                                list1.add(list.get(1));
                                list1.add(list.get(2));
                                list1.add(list.get(3));
                                list1.add(list.get(4));

                                listView.setAdapter(new MyAdapter(this_pointer, list));
                            }
                        });
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }
        }).start();
    }

    private void init() {
        wifiManager = (WifiManager) getSystemService(Context.WIFI_SERVICE);

        openWifi();
        while (list == null) {
            list = wifiManager.getScanResults();
        }
        ListView listView = (ListView) findViewById(R.id.listView);
        if (list == null) {
            //Toast.makeText(this, "wifi未打开！", Toast.LENGTH_LONG).show();
        } else {
            listView.setAdapter(new MyAdapter(this, list));
        }

    }

    /**
     * 打开WIFI
     */
    private void openWifi() {
        if (!wifiManager.isWifiEnabled()) {
            wifiManager.setWifiEnabled(true);
        }
    }

    public class MyAdapter extends BaseAdapter {

        LayoutInflater inflater;
        List<ScanResult> list;

        public MyAdapter(Context context, List<ScanResult> list) {
            this.inflater = LayoutInflater.from(context);
            this.list = list;
        }

        @Override
        public int getCount() {
            return list.size();
        }

        @Override
        public Object getItem(int position) {
            return position;
        }

        @Override
        public long getItemId(int position) {
            return position;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {

            View view = null;
            view = inflater.inflate(R.layout.item_wifi_list, null);
            ScanResult scanResult = list.get(position);
            TextView textView = (TextView) view.findViewById(R.id.textView);
            textView.setText(scanResult.SSID);
            TextView signalStrenth = (TextView) view.findViewById(R.id.signal_strenth);
            signalStrenth.setText("\nMac: " + scanResult.BSSID + "\nRSSI: " + scanResult.level);
            return view;
        }

    }
}
