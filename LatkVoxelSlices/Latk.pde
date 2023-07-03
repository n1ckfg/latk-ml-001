import latkProcessing.*;

Latk latk;
ArrayList<LatkStroke> strokes;
int currentFrame = 0;

void initLatk() {
  latk = new Latk(this, "layer_test.json");  
  println("Latk strokes loaded.");
  latk.normalize();
  strokes = new ArrayList<LatkStroke>();
  
  for (int i=0; i<latk.layers.size(); i++) {
    for (int j=0; j<latk.layers.get(i).frames.get(currentFrame).strokes.size(); j++) {
      LatkStroke stroke = latk.layers.get(i).frames.get(currentFrame).strokes.get(j);
      for (int k=0; k<stroke.points.size(); k++) {
        LatkPoint point = stroke.points.get(k);
        point.co.y = 1.0 - point.co.y;
        point.co.x = 1.0 - point.co.x;
      }
      
      for (int k=0; k<subPointSteps; k++) {
        stroke.splitStroke();
      }
      strokes.add(stroke);
    }
  }
}
