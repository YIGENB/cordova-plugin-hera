package com.android.hera;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.res.AssetManager;
import android.net.Uri;
import android.util.Log;

import com.weidian.lib.hera.config.HeraConfig;
import com.weidian.lib.hera.main.HeraService;
import com.android.hera.api.ApiOpenLink;
import com.android.hera.api.ApiOpenPageForResult;
import com.weidian.lib.hera.trace.HeraTrace;

import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaResourceApi;
import org.apache.cordova.PermissionHelper;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

/**
 * Created by JasonYang on 2019/11/27.
 */
public class Hera extends CordovaPlugin {

    public static final int REQUEST_CODE = 0x0ba7c0de;

    static final int ERR_CODE_PARAMETER = 1;
    static final int ERR_CODE_CONVERSATION = 2;

    static final String ERR_MSG_PARAMETER = "Parameters error";
    static final String ERR_MSG_CONVERSATION = "Can't get the conversation";

    private static final String LOG_TAG = "Hera";
    private String [] permissions = { Manifest.permission.READ_EXTERNAL_STORAGE,Manifest.permission.RECORD_AUDIO,Manifest.permission.WRITE_EXTERNAL_STORAGE,Manifest.permission.CAMERA };

    private JSONArray requestArgs;
    private CallbackContext callbackContext;

    @Override
    public boolean execute(String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {
        this.callbackContext = callbackContext;
        this.requestArgs = args;

        //android permission auto add
        if(!hasPermisssion()) {
            requestPermissions(0);
        } else {
            if (action.equalsIgnoreCase("start")) {
                this.Start(callbackContext);
                return true;
            }

            if (action.equalsIgnoreCase("open")) {
                this.Open(args,callbackContext);
                return true;
            }
        }

//        if (action.equalsIgnoreCase("login")) {
//            this.Open(args,callbackContext);
//            return true;
//        }
//
//        if (action.equalsIgnoreCase("logout")) {
//            this.Logout();
//            return true;
//        }
//
//        return false;
        return true;
    }

    /**
     * 初始化框架配置，启动框架服务进程
     * @param callback
     */
    public void Start(final CallbackContext callback){
        if (HeraTrace.isMainProcess(cordova.getContext())){
            HeraConfig config = new HeraConfig.Builder()
                    .addExtendsApi(new ApiOpenLink(cordova.getContext()))
                    .addExtendsApi(new ApiOpenPageForResult())
                    .setDebug(true)
                    .build();
//            cordova.getThreadPool().execute(new Runnable() {
//                public void run() {
//                    HeraService.start(cordova.getContext(), config);
//                }
//            });
            try {
                HeraService.start(cordova.getContext(), config);
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }

        callback.success("初始化成功");
    }

    /**
     * 打开小程序
     * @param args
     */
    public void Open(final JSONArray args,final CallbackContext callback) {

        try {

            JSONObject jsonObject = args.getJSONObject(0);

            //标识宿主App业务用户id
            String userId="";
            if(jsonObject.has("userid")) {
                userId=jsonObject.getString("userid");
            }
            else {
                JSONObject resultJsonObj = new JSONObject();
                resultJsonObj.put("isSuccess", false);
                resultJsonObj.put("msg", "缺少业务用户id");
                callback.error(resultJsonObj);
                return;
            }

            //appid
            String appId="";
            if(jsonObject.has("appid")) {
                appId=jsonObject.getString("appid");
            }
            else {
                JSONObject resultJsonObj = new JSONObject();
                resultJsonObj.put("isSuccess", false);
                resultJsonObj.put("msg", "缺少小程序id");
                callback.error(resultJsonObj);
                return;
            }

            //小程序的本地存储路径
            String appPath="";
            if(jsonObject.has("apppath")) {
                appPath=jsonObject.getString("apppath");
            }

            //加载页面标题
            String loadName="小程序";
            if(jsonObject.has("loadname")) {
                loadName=jsonObject.getString("loadname");
            }

            final CordovaPlugin that = this;
            final String _userId = userId;
            final String _appId = appId;
            final String _appPath = appPath;
            final String _loadName = loadName;
            final String noAppPath = "www/xiaochengxu/";//assets下内部目录：www/xiaochengxu/

            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
//                            if (HeraTrace.isMainProcess(cordova.getContext())) {
//                                HeraConfig config = new HeraConfig.Builder()
//                                        .addExtendsApi(new ApiOpenLink(cordova.getContext()))
//                                        .addExtendsApi(new ApiOpenPageForResult())
//                                        .setDebug(true)
//                                        .build();
//                                HeraService.start(cordova.getContext(), config);
//                            }

                    HeraService.launchHome(cordova.getContext().getApplicationContext(), _userId, _appId, _appPath,_loadName,noAppPath);
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
            handleResult(ERR_CODE_PARAMETER, ERR_MSG_PARAMETER, callback);
            return;
        }
    }


    private Uri getUriForArg(String arg) {
        CordovaResourceApi resourceApi = webView.getResourceApi();
        Uri tmpTarget = Uri.parse(arg);
        return resourceApi.remapUri(
                tmpTarget.getScheme() != null ? tmpTarget : Uri.fromFile(new File(arg)));
    }

    static void handleResult(int status, String desc, CallbackContext callback) {
        if (status == 0) {
            callback.success();
        } else {
            try {
                callback.error(getErrorObject(status, desc));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    }

    private static JSONObject getErrorObject(int code, String description) throws JSONException {
        JSONObject error = new JSONObject();
        error.put("code", code);
        error.put("description", description);
        return error;
    }

    /**
     * check application's permissions
     */
    public boolean hasPermisssion() {
        for(String p : permissions)
        {
            if(!PermissionHelper.hasPermission(this, p))
            {
                return false;
            }
        }
        return true;
    }

    /**
     * We override this so that we can access the permissions variable, which no longer exists in
     * the parent class, since we can't initialize it reliably in the constructor!
     *
     * @param requestCode The code to get request action
     */
    public void requestPermissions(int requestCode)
    {
        PermissionHelper.requestPermissions(this, requestCode, permissions);
    }

    /**
     * processes the result of permission request
     *
     * @param requestCode The code to get request action
     * @param permissions The collection of permissions
     * @param grantResults The result of grant
     */
    public void onRequestPermissionResult(int requestCode, String[] permissions,
                                          int[] grantResults) throws JSONException
    {
        PluginResult result;
        for (int r : grantResults) {
            if (r == PackageManager.PERMISSION_DENIED) {
                Log.d(LOG_TAG, "Permission Denied!");
                result = new PluginResult(PluginResult.Status.ILLEGAL_ACCESS_EXCEPTION);
                this.callbackContext.sendPluginResult(result);
                return;
            }
        }

        switch(requestCode)
        {
            case 0:
                this.Open(this.requestArgs,this.callbackContext);
                break;
        }
    }

}
