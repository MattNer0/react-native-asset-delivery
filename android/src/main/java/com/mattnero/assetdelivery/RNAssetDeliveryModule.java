package com.mattnero.assetdelivery;

import android.app.Activity;
import android.content.Intent;
import android.content.IntentSender;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.BaseActivityEventListener;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;

import com.facebook.react.modules.core.DeviceEventManagerModule;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;

import com.google.android.play.core.assetpacks.AssetPackManager;
import com.google.android.play.core.assetpacks.AssetPackManagerFactory;
import com.google.android.play.core.assetpacks.AssetPackLocation;
import com.google.android.play.core.assetpacks.AssetPackStates;
import com.google.android.play.core.assetpacks.AssetPackState;
import com.google.android.play.core.assetpacks.AssetPackStateUpdateListener;
import com.google.android.play.core.assetpacks.model.AssetPackStatus;
import com.google.android.play.core.tasks.OnFailureListener;
import com.google.android.play.core.tasks.OnSuccessListener;
import com.google.android.play.core.tasks.Task;
import com.google.android.play.core.tasks.RuntimeExecutionException;

import com.google.android.play.core.appupdate.AppUpdateInfo;
import com.google.android.play.core.appupdate.AppUpdateManager;
import com.google.android.play.core.appupdate.AppUpdateManagerFactory;
import com.google.android.play.core.install.model.AppUpdateType;
import com.google.android.play.core.install.model.UpdateAvailability;

import static android.app.Activity.RESULT_OK;

/*
import android.app.Activity;
import android.app.DownloadManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.os.PowerManager;
import android.provider.Settings;
import android.util.Log;
import androidx.core.content.FileProvider;
import androidx.documentfile.provider.DocumentFile;

import java.io.InputStream;
import java.io.OutputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.File;
import java.io.IOException;
import java.io.FileNotFoundException;
import java.lang.NullPointerException;
import java.lang.UnsupportedOperationException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.BaseActivityEventListener;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableNativeArray;
*/

public class RNAssetDeliveryModule extends ReactContextBaseJavaModule implements LifecycleEventListener {
    //private static final int DIRECTORY_SELECT_CODE = 65502;
    private static final String TAG = RNAssetDeliveryModule.class.getSimpleName();

    private AppUpdateManager appUpdateManager;
    private static final int MY_REQUEST_CODE = 543;
    private ReactApplicationContext reactContext;
    private AssetPackManager assetPackManager;
    //private Callback mCallback;

    private final AssetPackStateUpdateListener mAssetPackStateUpdateListener = new AssetPackStateUpdateListener() {
        @Override
        public void onStateUpdate(AssetPackState assetPackState) {
            try {
                reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                    .emit("onProgress", getStatusMap(assetPackState));
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    };

    private final ActivityEventListener mActivityEventListener = new BaseActivityEventListener() {
        @Override
        public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent intent) {
            if (requestCode == MY_REQUEST_CODE) {
                if (resultCode != RESULT_OK) {
                    System.out.println("Update flow failed! Result code: " + resultCode);
                    // If the update is cancelled or fails,
                    // you can request to start the update again.
                }
            }
        }
    };

    public RNAssetDeliveryModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        this.reactContext.addActivityEventListener(mActivityEventListener);
        this.reactContext.addLifecycleEventListener(this);
        this.assetPackManager = AssetPackManagerFactory.getInstance(this.reactContext);
        this.assetPackManager.registerListener(mAssetPackStateUpdateListener);
    }

    @Override
    public String getName() {
        return "RNAssetDelivery";
    }

    @Override
    public void onHostResume() {
    }

    @Override
    public void onHostPause() {
        assetPackManager.clearListeners();
    }

    @Override
    public void onHostDestroy() {
        assetPackManager.clearListeners();
    }

    private ArrayList<String> getPacksList(ReadableArray packNames) {
        ArrayList<String> packsList = new ArrayList<String>(packNames.size());
        for (int i = 0; i < packNames.size(); i++) {
            packsList.add(packNames.getString(i));
        }

        return packsList;
    }

    private WritableMap getStatusMap(AssetPackState assetPackState) {
        WritableMap statusMap = Arguments.createMap();
        int statusCode = assetPackState.status();
        statusMap.putString("name", assetPackState.name());
        statusMap.putInt("statusCode", statusCode);
        statusMap.putInt("errorCode", assetPackState.errorCode());
        statusMap.putDouble("percentage", assetPackState.transferProgressPercentage() / 100.0);
        statusMap.putDouble("bytesDownloaded", (double)assetPackState.bytesDownloaded());
        statusMap.putDouble("totalBytes", (double)assetPackState.totalBytesToDownload());

        switch (statusCode) {
            case AssetPackStatus.CANCELED:
                statusMap.putString("status", "CANCELED");
                statusMap.putBoolean("completed", false);
                statusMap.putBoolean("pending", false);
                break;
            case AssetPackStatus.COMPLETED:
                statusMap.putString("status", "COMPLETED");
                statusMap.putBoolean("completed", true);
                statusMap.putBoolean("pending", false);
                break;
            case AssetPackStatus.DOWNLOADING:
                statusMap.putString("status", "DOWNLOADING");
                statusMap.putBoolean("completed", false);
                statusMap.putBoolean("pending", true);
                break;
            case AssetPackStatus.FAILED:
                statusMap.putString("status", "FAILED");
                statusMap.putBoolean("completed", false);
                statusMap.putBoolean("pending", false);
                break;
            case AssetPackStatus.NOT_INSTALLED:
                statusMap.putString("status", "NOT_INSTALLED");
                statusMap.putBoolean("completed", false);
                statusMap.putBoolean("pending", false);
                break;
            case AssetPackStatus.PENDING:
                statusMap.putString("status", "PENDING");
                statusMap.putBoolean("completed", false);
                statusMap.putBoolean("pending", true);
                break;
            case AssetPackStatus.TRANSFERRING:
                statusMap.putString("status", "TRANSFERRING");
                statusMap.putBoolean("completed", false);
                statusMap.putBoolean("pending", true);
                break;
            case AssetPackStatus.UNKNOWN:
                statusMap.putString("status", "UNKNOWN");
                statusMap.putBoolean("completed", false);
                statusMap.putBoolean("pending", false);
                break;
            case AssetPackStatus.WAITING_FOR_WIFI:
                statusMap.putString("status", "WAITING_FOR_WIFI");
                statusMap.putBoolean("completed", false);
                statusMap.putBoolean("pending", true);
                break;
            default:
                break;
        }

        return statusMap;
    }

    @ReactMethod
    public void getPackLocation(String packName, final Promise promise) {
        try {
            AssetPackLocation retrievedPackLocation = assetPackManager.getPackLocation(packName);

            WritableMap locationMap = Arguments.createMap();
            locationMap.putString("assetsPath", retrievedPackLocation.assetsPath());
            locationMap.putInt("storageMethod", retrievedPackLocation.packStorageMethod());
            locationMap.putString("path", retrievedPackLocation.path());

            promise.resolve(locationMap);
        } catch (Exception e) {
            e.printStackTrace();
            promise.reject(e.getClass().getSimpleName(), e.getMessage());
        }
    }

    @ReactMethod
    public void getPackContent(String packName, final Promise promise) {
        try {
            AssetPackLocation retrievedPackLocation = assetPackManager.getPackLocation(packName);
            File file = new File(retrievedPackLocation.assetsPath());

            if (!file.exists()) throw new Exception("Folder does not exist");

            File[] files = file.listFiles();
            WritableArray fileMaps = Arguments.createArray();

            for (File childFile : files) {
                WritableMap fileMap = Arguments.createMap();

                fileMap.putDouble("mtime", (double) childFile.lastModified() / 1000);
                fileMap.putString("name", childFile.getName());
                fileMap.putString("path", childFile.getAbsolutePath());
                fileMap.putDouble("size", (double) childFile.length());
                fileMap.putInt("type", childFile.isDirectory() ? 1 : 0);

                fileMaps.pushMap(fileMap);
            }

            promise.resolve(fileMaps);
        } catch (Exception e) {
            e.printStackTrace();
            promise.reject(e.getClass().getSimpleName(), e.getMessage());
        }
    }

    @ReactMethod
    public void getPackState(final String packName, final Promise promise) {
        assetPackManager.getPackStates(Collections.singletonList(packName))
            .addOnSuccessListener(new OnSuccessListener<AssetPackStates>() {
                @Override
                public void onSuccess(AssetPackStates assetPackStates) {
                    try {
                        AssetPackState assetPackState = assetPackStates.packStates().get(packName);
                        promise.resolve(getStatusMap(assetPackState));

                    } catch (RuntimeExecutionException e) {
                        promise.reject("RuntimeExecutionException", e.getMessage());
                        return;
                    }
                }
            })
            .addOnFailureListener(new OnFailureListener() {
                @Override
                public void onFailure(Exception e) {
                    promise.reject(e.getClass().getSimpleName(), e.getMessage());
                }
            });
    }

    @ReactMethod
    public void getPacksState(final ReadableArray packNames, final Promise promise) {
        assetPackManager.getPackStates(getPacksList(packNames))
            .addOnSuccessListener(new OnSuccessListener<AssetPackStates>() {
                @Override
                public void onSuccess(AssetPackStates assetPackStates) {
                    try {
                        WritableArray statusMaps = Arguments.createArray();
                        for (int i = 0; i < packNames.size(); i++) {
                            AssetPackState assetPackState = assetPackStates.packStates().get(packNames.getString(i));
                            statusMaps.pushMap(getStatusMap(assetPackState));
                        }
                        
                        promise.resolve(statusMaps);

                    } catch (RuntimeExecutionException e) {
                        promise.reject("RuntimeExecutionException", e.getMessage());
                        return;
                    }
                }
            })
            .addOnFailureListener(new OnFailureListener() {
                @Override
                public void onFailure(Exception e) {
                    promise.reject(e.getClass().getSimpleName(), e.getMessage());
                }
            });
    }

    @ReactMethod
    public void fetchPack(final String packName, final Promise promise) {
        assetPackManager.fetch(Collections.singletonList(packName))
            .addOnSuccessListener(new OnSuccessListener<AssetPackStates>() {
                @Override
                public void onSuccess(AssetPackStates assetPackStates) {
                    try {
                        AssetPackState assetPackState = assetPackStates.packStates().get(packName);
                        promise.resolve(getStatusMap(assetPackState));

                    } catch (RuntimeExecutionException e) {
                        promise.reject("RuntimeExecutionException", e.getMessage());
                        return;
                    }
                }
            })
            .addOnFailureListener(new OnFailureListener() {
                @Override
                public void onFailure(Exception e) {
                    promise.reject(e.getClass().getSimpleName(), e.getMessage());
                }
            });
    }

    @ReactMethod
    public void removePack(String packName, final Promise promise) {
        assetPackManager.removePack(packName)
            .addOnSuccessListener(new OnSuccessListener<Void>() {
                @Override
                public void onSuccess(Void res) {
                    promise.resolve(null);
                }
            })
            .addOnFailureListener(new OnFailureListener() {
                @Override
                public void onFailure(Exception e) {
                    promise.reject(e.getClass().getSimpleName(), e.getMessage());
                }
            });
    }

    @ReactMethod
    public void checkUpdate() {
        appUpdateManager = AppUpdateManagerFactory.create(reactContext);
        Task<AppUpdateInfo> appUpdateInfoTask = appUpdateManager.getAppUpdateInfo();
        appUpdateInfoTask.addOnSuccessListener(new OnSuccessListener<AppUpdateInfo>() {
            @Override
            public void onSuccess(AppUpdateInfo appUpdateInfo) {
                if (appUpdateInfo.updateAvailability() == UpdateAvailability.UPDATE_AVAILABLE && appUpdateInfo.isUpdateTypeAllowed(AppUpdateType.IMMEDIATE)) {
                    try {
                        appUpdateManager.startUpdateFlowForResult(
                                appUpdateInfo,
                                AppUpdateType.IMMEDIATE,
                                reactContext.getCurrentActivity(),
                                MY_REQUEST_CODE);
                    } catch (IntentSender.SendIntentException e) {
                        e.printStackTrace();
                    }
                }
            }
        });
    }
}
