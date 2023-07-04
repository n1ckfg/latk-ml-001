import ch.bildspur.vision.*;
import ch.bildspur.vision.result.*;
import ch.bildspur.vision.dependency.*;

import java.nio.file.Paths;
import java.nio.file.Path;

boolean doDeepVision = true;
DeepVision vision;
Pix2PixNetwork network;

void modelSetup() {
  vision = new DeepVision(this);
  
  String url = sketchPath(new File("data", "midasnet2.1.onnx").getPath());
  //String url = sketchPath(new File("data", "pix2pix003_140_net_G.onnx").getPath());
  println("Loading model from " + url);
  Path model = Paths.get(url).toAbsolutePath();
  //Path weights = Paths.get(sketchPath("../models/mask-yolov3-tiny-prn.weights")).toAbsolutePath();
  //yolo = new YOLONetwork(model, weights, detectionSize, detectionSize);

  network = new Pix2PixNetwork(model);
  println("Loading model...");
  network.setup();
}

PImage modelInference(PImage img) {
  println("Inferencing...");
  ImageResult result = network.run(img);
  println("...done!");
  PImage returnImg = result.getImage();
  returnImg.resize(dim, dim);
  return returnImg;
}
