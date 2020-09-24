package com.android.ffmpegdemo;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.text.method.ScrollingMovementMethod;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

public class MainActivity extends AppCompatActivity implements View.OnClickListener {

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

        mInfoText.setText(FFmpegInfoUtils.avcodecInfo());
        mInfoText.setMovementMethod(ScrollingMovementMethod.getInstance());

        mAvcodecBtn.setOnClickListener(this);
        mAvformatBtn.setOnClickListener(this);
        mAvfilterBtn.setOnClickListener(this);
        mProtocolBtn.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        if (v == mAvcodecBtn) {
            mInfoText.setText(FFmpegInfoUtils.avcodecInfo());
        } else if (v == mAvformatBtn) {
            mInfoText.setText(FFmpegInfoUtils.avformatInfo());
        } else if (v == mAvfilterBtn) {
            mInfoText.setText(FFmpegInfoUtils.avfilterInfo());
        } else if (v == mProtocolBtn) {
            mInfoText.setText(FFmpegInfoUtils.protocolInfo());
        }
    }

    /**
     * A native method that is implemented by the 'native-lib' native library,
     * which is packaged with this application.
     */
}
