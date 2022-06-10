package com.parenting.ppsflutter;

import android.app.Activity;
import android.app.Application;
import android.graphics.drawable.AnimationDrawable;

import androidx.annotation.CallSuper;

import io.flutter.view.FlutterMain;

public class PPS extends Application {
    @Override
    @CallSuper
    public void onCreate() {
        super.onCreate();
        /*AnimationDrawable animationDrawable = (AnimationDrawable) getDrawable(R.drawable.animated_list);
        animationDrawable.start();*/
        FlutterMain.startInitialization(this);
    }

    private Activity mCurrentActivity = null;

    public Activity getCurrentActivity() {
        return mCurrentActivity;
    }

    public void setCurrentActivity(Activity mCurrentActivity) {
        this.mCurrentActivity = mCurrentActivity;
        //mCurrentActivity.getWindow().setBackgroundDrawable(getDrawable(R.drawable.ic_launcher));
    }
}
