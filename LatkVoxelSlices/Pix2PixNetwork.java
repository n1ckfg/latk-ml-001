package ch.bildspur.vision;

import ch.bildspur.vision.network.BaseNeuralNetwork;
import ch.bildspur.vision.result.ImageResult;
import ch.bildspur.vision.util.CvProcessingUtils;
import org.bytedeco.javacpp.DoublePointer;
import org.bytedeco.javacpp.FloatPointer;
import org.bytedeco.javacpp.IntPointer;
import org.bytedeco.opencv.global.opencv_dnn;
import org.bytedeco.opencv.opencv_core.*;
import org.bytedeco.opencv.opencv_dnn.Net;
import processing.core.PImage;

import java.nio.file.Path;

import static org.bytedeco.opencv.global.opencv_core.*;
import static org.bytedeco.opencv.global.opencv_dnn.*;
import static org.bytedeco.opencv.global.opencv_imgproc.*;

public class Pix2PixNetwork extends BaseNeuralNetwork<ImageResult> {
    private Path model;
    private Net net;

    public Pix2PixNetwork(Path model) {
        this.model = model;
    }

    @Override
    public boolean setup() {
        net = readNetFromONNX(model.toAbsolutePath().toString());

        DeepVision.enableDesiredBackend(net);

        return true;
    }

    @Override
    public ImageResult run(Mat frame) {
        Size inputSize = frame.size();
        System.out.println("Input image size: " + inputSize.width() + ", " + inputSize.height());

        // convert image into batch of images
        Mat inputBlob = blobFromImage(frame, 1.0, new Size(256, 256), new Scalar(0, 0, 0, 0), false, false, CV_32F);

        // set input
        net.setInput(inputBlob);

        // create output layers
        StringVector outNames = net.getUnconnectedOutLayersNames();
        MatVector outs = new MatVector(outNames.size());

        // run detection
        net.forward(outs, outNames);
        Mat output = outs.get(0);

        // reshape output mat
        output = output.reshape(1, 256);

        // resize output instead of PImage to avoid Processing4 problems
        resize(output, output, inputSize);

        System.out.println("Output image size: " + output.size(2) + ", " + output.size(1));

        // todo: result a depth frame instead of a color image!
        PImage result = new PImage(inputSize.width(), inputSize.height());
        matToImage(output, result);
        return new ImageResult(result);
    }

    private void matToImage(Mat mat, PImage img) {
        // find min / max
        DoublePointer minValuePtr = new DoublePointer(1);
        DoublePointer maxValuePtr = new DoublePointer(1);

        minMaxLoc(mat, minValuePtr, maxValuePtr, null, null, null);

        double minValue = minValuePtr.get();
        double maxValue = maxValuePtr.get();

        double distance = maxValue - minValue;
        double minScaled = minValue / distance;

        double alpha = 1.0 / distance * 255.0;
        double beta = -1.0 * minScaled * 255.0;

        mat.convertTo(mat, CV_8U, alpha, beta);
        CvProcessingUtils.toPImage(mat, img);
    }

    public Net getNet() {
        return net;
    }
}
