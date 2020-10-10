package com.android.ffmpegdemo;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.jeffmony.ffmpeglib.FFmpegRemuxUtils;
import com.jeffmony.ffmpeglib.LogUtils;

import java.io.File;

public class FFmpegRemuxActivity extends AppCompatActivity implements View.OnClickListener {

    private static final String TAG = "FFmpegRemuxActivity";

    private EditText mSrcTxt;
    private EditText mDestTxt;
    private Button mConvertBtn;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_ffmpeg_remux);

        initViews();
    }

    private void initViews() {
        mSrcTxt = findViewById(R.id.src_path_txt);
        mDestTxt = findViewById(R.id.dest_path_txt);
        mConvertBtn = findViewById(R.id.convert_btn);

        mConvertBtn.setOnClickListener(this);
    }

    private void doConvertVideo(String inputPath, String outputPath) {
        if (TextUtils.isEmpty(inputPath) || TextUtils.isEmpty(outputPath)) {
            LogUtils.i(TAG, "InputPath or OutputPath is null");
            return;
        }
        File inputFile = new File(inputPath);
        if (!inputFile.exists()) {
            return;
        }
        File outputFile = new File(outputPath);
        if (!outputFile.exists()) {
            try {
                outputFile.createNewFile();
            } catch (Exception e) {
                LogUtils.w(TAG, "Create file failed, exception = " +e);
                return;
            }
        }

        FFmpegRemuxUtils.remux(inputPath, outputPath);
    }

    @Override
    public void onClick(View v) {
        if (v == mConvertBtn) {
            doConvertVideo(mSrcTxt.getText().toString(), mDestTxt.getText().toString());
        }
    }
}
