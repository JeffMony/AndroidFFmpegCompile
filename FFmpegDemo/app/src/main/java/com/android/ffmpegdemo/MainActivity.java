package com.android.ffmpegdemo;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.text.method.ScrollingMovementMethod;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

public class MainActivity extends AppCompatActivity implements View.OnClickListener {

    // Used to load the 'native-lib' library on application startup.
    static {
        System.loadLibrary("native-lib");
        System.loadLibrary("avcodec");
        System.loadLibrary("avfilter");
        System.loadLibrary("avformat");
        System.loadLibrary("avutil");
        System.loadLibrary("postproc");
        System.loadLibrary("swresample");
        System.loadLibrary("swscale");
    }

    private Button mAvcodecBtn;
    private Button mAvformatBtn;
    private Button mAvfilterBtn;
    private Button mProtocolBtn;
    private TextView mInfoText;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mInfoText = (TextView) findViewById(R.id.sample_text);
        mAvcodecBtn = (Button) findViewById(R.id.avcodec_btn);
        mAvformatBtn = (Button) findViewById(R.id.avformat_btn);
        mAvfilterBtn = (Button) findViewById(R.id.avfilter_btn);
        mProtocolBtn = (Button) findViewById(R.id.protocol_btn);

        mInfoText.setText(avcodecInfo());
        mInfoText.setMovementMethod(ScrollingMovementMethod.getInstance());

        mAvcodecBtn.setOnClickListener(this);
        mAvformatBtn.setOnClickListener(this);
        mAvfilterBtn.setOnClickListener(this);
        mProtocolBtn.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        if (v == mAvcodecBtn) {
            mInfoText.setText(avcodecInfo());
        } else if (v == mAvformatBtn) {
            mInfoText.setText(avformatInfo());
        } else if (v == mAvfilterBtn) {
            mInfoText.setText(avfilterInfo());
        } else if (v == mProtocolBtn) {
            mInfoText.setText(protocolInfo());
        }
    }

    /**
     * A native method that is implemented by the 'native-lib' native library,
     * which is packaged with this application.
     */
    public native String stringFromJNI();
    public native String avcodecInfo();
    public native String avfilterInfo();
    public native String avformatInfo();
    public native String protocolInfo();

}
