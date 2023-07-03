import peasy.*;

int subPointSteps = 5;
boolean drawMouse = false;
boolean selectMouse = false;
int sliceCounter = 0;
color vbgColor = color(0,0);
boolean doLoadSlices = false;
float globalScale = 500;
boolean doStyleTransfer = true;

PeasyCam cam;
int dim = 64;
int scaleFactor=10;
int dW = 1920;
int dH = 1080;
int fps = 60;
PVector offsetOrig = new PVector(0, 0, -1 * 20 * scaleFactor);
PVector offset = offsetOrig;
PVector loc = new PVector(0, 0, 0);
float offsetDelta = 10;
float drawOdds = 0.001;
boolean triggered=false;
Settings settings;
Voxel[][][] voxel;

void setup() {
  size(50,50,P3D);
  settings = new Settings("settings.txt");
  voxel = new Voxel[dim][dim][dim];
  surface.setSize(dim*scaleFactor, dim*scaleFactor);

  initVolume();
  initLatk();
  noCursor();
  frameRate(fps);
  //cam = new PeasyCam(this, width/2, height/2, (width+height)/4, 500);
  cam = new PeasyCam(this, 5000);
  //cam.setMinimumDistance(50);
  //cam.setMaximumDistance(500);
  
  styleSetup();
}

void draw() {
  controls();
  background(0);
  
  refreshLatk();

  if (!doLoadSlices) {
    buildVolume();
  } else {
    loadSlices();
  }
  
  refreshVolume();
  
  surface.setTitle(int(frameRate) + " fps");
}

void saveSlices() {
  for (int k=0;k<voxel[0][0].length;k++) {
    PGraphics slice = createGraphics(voxel.length, voxel[0].length);
    slice.beginDraw();
    slice.loadPixels();
    for (int i=0;i<voxel.length;i++) {
      for (int j=0;j<voxel[i].length;j++) {
        int pos = i + j * voxel.length;
        slice.pixels[pos] = voxel[i][j][k].c;
      }
    }
    slice.updatePixels();
    slice.endDraw();
    
    if (doStyleTransfer) {
      PImage styledSlice = styleInference(slice.get());
      styledSlice.loadPixels();
      for (int i=0; i<styledSlice.pixels.length; i++) {
        color col = slice.pixels[i];
        color colStyled = styledSlice.pixels[i];
        col = color(red(colStyled), green(colStyled), blue(colStyled), alpha(col));
        styledSlice.pixels[i] = col;
      }
      slice.beginDraw();
      slice.image(styledSlice, 0, 0, slice.width, slice.height);
      slice.endDraw();
    }
    
    slice.save("slices/test" + k + ".png");
    println("saved img " + k);
  }
}

void loadSlices() {
  if (sliceCounter < voxel[0][0].length) {
    PImage slice = loadImage("slices/test" + sliceCounter + ".png");
    slice.loadPixels();
    for (int i=0;i<voxel.length;i++) {
      for (int j=0;j<voxel[i].length;j++) {
        int pos = i + j * voxel.length;
        if (alpha(slice.pixels[pos]) > 0) {
          voxel[i][j][sliceCounter].c = slice.pixels[pos];
          voxel[i][j][sliceCounter].drawMe=true;
        }
      }
    }
    println("loaded img " + sliceCounter);
    sliceCounter++;
    if (sliceCounter==voxel[0][0].length) {
      objMain();
      mayaKeysMain();
      blenderKeysMain();
    }
  }
}

void posCheck(){
    if (loc.z > dim - 1) loc.z = dim - 1;
    if (loc.z < 0) loc.z = 0;
    if (loc.x > dim - 1) loc.x = dim - 1;
    if (loc.x < 0) loc.x = 0;
    if (loc.y > dim - 1) loc.y = dim - 1;
    if (loc.y < 0) loc.y = 0;
}

void findCollision(PVector p, color c) {
  for (int i=0;i<voxel.length;i++) {
    for (int j=0;j<voxel[i].length;j++) {
      for (int k=0;k<voxel[i][j].length;k++) {
        if (!voxel[i][j][k].drawMe) {
          //PVector hitBox = new PVector(scaleFactor, scaleFactor, scaleFactor);
          //if (hitDetect3D(p, hitBox, voxel[i][j][k].p, hitBox)) {
          if (hitDetect(p, voxel[i][j][k].p, scaleFactor)) {
            voxel[i][j][k].drawMe = true;
            voxel[i][j][k].c = c;
          }
        }
      }
    }
  }  
}

void initVolume() {
    for (int i=0;i<voxel.length;i++) {
    for (int j=0;j<voxel[i].length;j++) {
      for (int k=0;k<voxel[i][j].length;k++) {
        voxel[i][j][k] = new Voxel(i, j, k, scaleFactor);
      }
    }
  }
  println("Volume ready.");
}

void buildVolume() {
  if (strokeCounter < strokes.length) {
    if (strokeCounter==0) println("STARTED rendering volume...");
    for (int i=1; i<strokes[strokeCounter].p.length; i++) {
        PVector[] subPoints = pointsAlongLine(strokes[strokeCounter].p[i], strokes[strokeCounter].p[i-1], subPointSteps);
        for (int j=0; j<subPoints.length; j++) {
          findCollision(subPoints[j], strokes[strokeCounter].c);
        }
    }
    println("Stroke " + (strokeCounter + 1) + " / " + strokes.length); 
    strokeCounter++;
    if (strokeCounter >= strokes.length) {
      saveSlices();
      println("...FINISHED rendering volume.");
      doLoadSlices = true;
    }
  }
}

void refreshVolume() {
  for (int i=0;i<voxel.length;i++) {
    for (int j=0;j<voxel[i].length;j++) {
      for (int k=0;k<voxel[i][j].length;k++) {
        if (selectMouse) {
          voxel[i][j][k].selectMe=false;
          voxel[i][j][k].sameZ=false;
          voxel[int(loc.x)][int(loc.y)][int(loc.z)].selectMe=true;
          voxel[i][j][int(loc.z)].sameZ=true;
        }
        voxel[i][j][k].run();
      }
    }
  }
}
