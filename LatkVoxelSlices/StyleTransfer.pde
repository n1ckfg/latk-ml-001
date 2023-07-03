import ch.bildspur.vision.*;
import ch.bildspur.vision.result.*;
import ch.bildspur.vision.dependency.*;

DeepVision vision;
StyleTransferNetwork network;

void styleSetup() {
  vision = new DeepVision(this);
  println("Creating network...");
  network = vision.createStyleTransfer(Repository.InstanceNormCandy);
  println("Loading model...");
  network.setup();
}

PImage styleInference(PImage img) {
  println("Inferencing...");
  ImageResult result = network.run(img);
  println("...done!");
  return result.getImage();
}
