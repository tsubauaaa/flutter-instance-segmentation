package com.tsubauaaa.d2go.app;
import android.graphics.BitmapFactory;
import android.util.Log;

import java.nio.FloatBuffer;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import android.graphics.Bitmap;
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
 * Class property
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
     * <p>d2goモデルを読み込んで、[modules]にorg.pytorch.Moduleを追加し、そのindexを返却する</>
     *
     * @param call absPath org.pytorch.Moduleのloadメソッドが読み込むD2Goモデル(d2go.pt)のxxxパス,
     *             assetPath モデルの読み込み失敗時に、ログ表示するために使うD2Goモデル(d2go.pt)の相対パス
     * @param result 成功した場合は、ArrayList<org.pytorch.Module>のindexをresult.successで返却する
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
     * <p>D2Goモデルを使って推論し、結果を整形して返却する</>
     *
     * @param call [index] ArrayList<Module>のindex,
     *             [image] 推論対象の画像のList<Bytes>,
     *             [width] 画像の横長,
     *             [height] 画像の縦長,
     *             [mean] Normalizeで使う平均値,
     *             [std] Normalizeで使う標準偏差,
     *             [minScore] しきい値
     * @param result 成功した場合は、[outputs]をresult.successで返却する,
     *               [outputs]は{ "rect": { "left": Float, "top": Float, "right": Float, "bottom": Float },
     *               "confidenceInClass": Float, "detectedClass": Long }のList
     */
    private void d2go(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Module module;
        Bitmap bitmap;
        float [] mean;
        float [] std;
        double minScore;
        int inputWidth;
        int inputHeight;
        float imageWidthScale, imageHeightScale;


        int index = call.argument("index");
        byte[] imageBytes = call.argument("image");


        // meanとstdをfloat変換
        ArrayList<Double> _mean = call.argument("mean");
        mean = toFloatPrimitives(_mean.toArray(new Double[0]));
        ArrayList<Double> _std = call.argument("std");
        std = toFloatPrimitives(_std.toArray(new Double[0]));

        minScore = call.argument("minScore");

        inputWidth = call.argument("width");
        inputHeight = call.argument("height");

        // loadModelして生成したPyTorch Moduleを取得
        module = modules.get(index);

        // bitmap objectをimageから作成してサイズを復元
        bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.length);
        Bitmap resizedBitmap = Bitmap.createScaledBitmap(bitmap, inputWidth, inputHeight, true);

        imageWidthScale = (float)bitmap.getWidth() / inputWidth;
        imageHeightScale = (float)bitmap.getHeight() / inputHeight;

        final FloatBuffer floatBuffer = Tensor.allocateFloatBuffer(3 * resizedBitmap.getWidth() * resizedBitmap.getHeight());
        TensorImageUtils.bitmapToFloatBuffer(resizedBitmap,0,0, resizedBitmap.getWidth(), resizedBitmap.getHeight(), mean, std, floatBuffer, 0);
        final Tensor inputTensor = Tensor.fromBlob(floatBuffer, new long[] {3, resizedBitmap.getHeight(), resizedBitmap.getWidth()});

        // 推論
        IValue[] outputTuple = module.forward(IValue.listFrom(inputTensor)).toTuple();

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
            List<Map<String, Object>> outputs = new ArrayList<>();
            for (int i = 0; i < totalInstances; i++) {
                if (scoresData[i] < minScore)
                    continue;
                Map<String, Object> output = new LinkedHashMap<>();
                Map<String, Float> rect = new LinkedHashMap<>();
                rect.put("left", boxesData[4 * i + 0] * imageWidthScale);
                rect.put("top", boxesData[4 * i + 1] * imageHeightScale);
                rect.put("right", boxesData[4 * i + 2] * imageWidthScale);
                rect.put("bottom", boxesData[4 * i + 3] * imageHeightScale);

                output.put("rect", rect);
                output.put("confidenceInClass", scoresData[i]);
                output.put("detectedClass", labelsData[i] - 1);

                outputs.add(output);
            }
            result.success(outputs);
        }
    }

    /**
     * <p>Normalize parameterをFloat変換する</>
     *
     * @param objects 変換前のDouble[]
     * @return primitives 変換後のfloat[]
     */
    private static float[] toFloatPrimitives(Double[] objects) {
        float[] primitives = new float[objects.length];
        for (int i = 0; i < objects.length; i++) {
            primitives[i] = objects[i].floatValue();
        }
        return  primitives;
    }
}

