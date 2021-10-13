package com.tsubauaaa.d2go.app;
import android.graphics.BitmapFactory;
import android.util.Log;

import java.nio.FloatBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import android.graphics.Bitmap;
import android.graphics.Matrix;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import org.pytorch.IValue;
import org.pytorch.Module;
import org.pytorch.Tensor;
import org.pytorch.torchvision.TensorImageUtils;

/**
 * クラスプロパティ
 * [CHANNEL] MethodChannelで参照される識別子
 * [modules] ArrayList<org.pytorch.Module>
 */
public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "flutter_d2go";

    ArrayList<Module> modules = new ArrayList<>();

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                    (call, result) -> {
                        switch (call.method) {
                            case "loadModel":
                                loadModel(call, result);
                                break;
                            case "d2go":
                                d2go(call, result);
                                break;
                            default:
                                result.notImplemented();
                                break;
                        }
                }
        );
    }


    /**
     * @param call absPath org.pytorch.Moduleのloadメソッドが読み込むD2Goモデル(d2go.pt)のxxxパス
     * @param call assetPath モデルの読み込み失敗時に、ログ表示するために使うD2Goモデル(d2go.pt)の相対パス
     * @param result 成功した場合は、ArrayList<Module>のindexをresult.successで返却する
     */
    private void loadModel(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        try {
            String absPath = call.argument("absPath");
            modules.add(Module.load(absPath));
            result.success(modules.size() - 1);
        } catch (Exception e) {
            String assetPath = call.argument("assetPath");
            Log.e("flutter_d2go", assetPath + "is not a proper model", e);
        }
    }

    /**
     *
     * @param call index ArrayList<Module>のindex
     * @param call image 推論対象の画像のList<Bytes>
     * @param call width 画像の横長
     * @param call height 画像の縦長
     * @param call mean Normalizeで使う平均値
     * @param call std Normalizeで使う標準偏差
     * @param call minScore しきい値
     * @param result 成功した場合は、[outputs]をresult.successで返却する
     */
    private void d2go(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Module mModule = null;
        Bitmap bitmap = null;
        float [] mean = null;
        float [] std = null;
        double minScore = 0.0;
        int inputWidth = 640;
        int inputHeight = 640;
        float mImgScaleX, mImgScaleY, mIvScaleX, mIvScaleY, mStartX, mStartY;


        int index = call.argument("index");
        byte[] imageBytes = call.argument("image");


        // meanとstdをfloat変換
        ArrayList<Double> _mean = call.argument("mean");
        mean = Convert.toFloatPrimitives(_mean.toArray(new Double[0]));
        ArrayList<Double> _std = call.argument("std");
        std = Convert.toFloatPrimitives(_std.toArray(new Double[0]));

        minScore = call.argument("minScore");

        inputWidth = call.argument("width");
        inputHeight = call.argument("height");

        // loadModelして生成したPyTorch Moduleを取得
        mModule = modules.get(index);

        // bitmap objectをimageから作成してサイズを復元
        bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.length);
        Bitmap resizedBitmap = Bitmap.createScaledBitmap(bitmap, inputWidth, inputHeight, true);

        final FloatBuffer floatBuffer = Tensor.allocateFloatBuffer(3 * resizedBitmap.getWidth() * resizedBitmap.getHeight());
        TensorImageUtils.bitmapToFloatBuffer(resizedBitmap,0,0, resizedBitmap.getWidth(), resizedBitmap.getHeight(), mean, std, floatBuffer, 0);
        final Tensor inputTensor = Tensor.fromBlob(floatBuffer, new long[] {3, resizedBitmap.getHeight(), resizedBitmap.getWidth()});

        // 推論
        IValue[] outputTuple = mModule.forward(IValue.listFrom(inputTensor)).toTuple();

        final Map<String, IValue> map = outputTuple[1].toList()[0].toDictStringKey();

        float[] boxesData;
        float[] scoresData;
        long[] labelsData;

        // 推論結果整形
        if (map.containsKey("boxes")) {
            final Tensor boxesTensor = map.get("boxes").toTensor();
            final Tensor scoresTensor = map.get("scores").toTensor();
            final Tensor labelsTensor = map.get("labels").toTensor();
            boxesData = boxesTensor.getDataAsFloatArray();
            scoresData = scoresTensor.getDataAsFloatArray();
            labelsData = labelsTensor.getDataAsLongArray();

            final int totalInstances = scoresData.length;

            // 全インスタンス数 x outputカラム(left, top, right, bottom, score, label)
            List<Map<String, Object>> outputs = new ArrayList<Map<String, Object>>();
//            float[] outputs = new float[totalInstances * 6];
//            int count = 0;
            for (int i = 0; i < totalInstances; i++) {
                if (scoresData[i] < minScore)
                    continue;
                Map<String, Object> output = new LinkedHashMap<String, Object>();
                Map<String, Float> rect = new LinkedHashMap<String, Float>();
                rect.put("left", boxesData[4 * i + 0]);
                rect.put("top", boxesData[4 * i + 1]);
                rect.put("right", boxesData[4 * i + 2]);
                rect.put("bottom", boxesData[4 * i + 3]);

                output.put("rect", rect);
                output.put("confidenceInClass", scoresData[i]);
                output.put("detectedClass", labelsData[i] - 1);

                outputs.add(output);
//                outputs[6 * count + 0] = boxesData[4 * i + 0]; // left
//                outputs[6 * count + 1] = boxesData[4 * i + 1]; // top
//                outputs[6 * count + 2] = boxesData[4 * i + 2]; // right
//                outputs[6 * count + 3] = boxesData[4 * i + 3]; // bottom
//                outputs[6 * count + 4] = scoresData[i]; // score
//                outputs[6 * count + 5] = labelsData[i] - 1; // label
//                count++;
            }
            result.success(outputs);
        }
    }


}

