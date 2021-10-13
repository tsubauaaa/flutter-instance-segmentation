package com.tsubauaaa.d2go.app;

public class Convert {
    /**
     * @param objects 変換前のDouble[]
     * @return primitives 変換後のfloat[]
     */
    public static float[] toFloatPrimitives(Double[] objects) {
        float[] primitives = new float[objects.length];
        for (int i = 0; i < objects.length; i++) {
            primitives[i] = objects[i].floatValue();
        }
        return  primitives;
    }

}
