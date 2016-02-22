///////////////////////////////////////////////////////////////////////
//
//  Ray Tracing Shell
//
///////////////////////////////////////////////////////////////////////

int screen_width = 300;
int screen_height = 300;

float fov;
PVector bgcolor = new PVector();
// PVector screenPos = new PVector();
float winsize=0;
// Store latest reflectance constants
PVector ka = new PVector(0, 0, 0);
PVector kd = new PVector(0, 0, 0);
// Arrays to store properties of objects and lights
Shape[] objects = new Shape[2000];
Light[] lights = new Light[20];
int numLights=0, numObjects=0;
int raysPerPx;
float lensRadius, lensFocal;
boolean isLens;

PVector[] polyVerts = new PVector[3];
int curVert = 0;
boolean poly = false;

// global matrix values
PMatrix3D global_mat;
float[] gmat = new float[16];  // global matrix values

// Some initializations for the scene.

void reInit() {
  numObjects = 0;
  numLights = 0;
  bgcolor.set(0, 0, 0);
  isLens = false;
  resetMatrix();
}

void setup() {
  size (300, 300, P3D);  // use P3D environment so that matrix commands work properly
  noStroke();
  colorMode (RGB, 1.0);
  background (0, 0, 0);

  // grab the global matrix values (to use later when drawing pixels)
  PMatrix3D global_mat = (PMatrix3D) getMatrix();
  global_mat.get(gmat);  
  printMatrix();
  //resetMatrix();    // you may want to reset the matrix here
  reInit();
  interpreter("t01.cli");
}

// Press key 1 to 9 and 0 to run different test cases.

void keyPressed() {
  switch(key) {
  case '1':
    reInit();
    interpreter("t01.cli"); 
    break;
  case '2':  
    reInit();
    interpreter("t02.cli"); 
    break;
  case '3':  
    reInit();
    interpreter("t03.cli"); 
    break;
  case '4':  
    reInit();
    interpreter("t04.cli"); 
    break;
  case '5':  
    reInit();
    interpreter("t05.cli"); 
    break;
  case '6':  
    reInit();
    interpreter("t06.cli"); 
    break;
  case '7':  
    reInit();
    interpreter("t07.cli"); 
    break;
  case '8':  
    reInit();
    interpreter("t08.cli"); 
    break;
  case '9':  
    reInit();
    interpreter("t09.cli"); 
    break;
  case '0':  
    reInit();
    interpreter("t10.cli"); 
    break;
  case 't':
    reInit();
    interpreter("test.cli");
    break;
  case 'q':  
    exit(); 
    break;
  }
}

//  Parser core. It parses the CLI file and processes it based on each 
//  token. Only "color", "rect", and "write" tokens are implemented. 
//  You should start from here and add more functionalities for your
//  ray tracer.
//
//  Note: Function "splitToken()" is only available in processing 1.25 or higher.

void interpreter(String filename) {
  String str[] = loadStrings(filename);
  if (filename.charAt(0) == 't' && filename.charAt(1) == '0')

    println(filename);
  if (str == null) println("Error! Failed to read the file.");
  for (int i=0; i<str.length; i++) {

    String[] token = splitTokens(str[i], " "); // Get a line and parse tokens.
    if (token.length == 0) continue; // Skip blank line.
//////////////////// FOV ////////////////////
    if (token[0].equals("fov")) {
      // TODO
      fov = float(token[1]);
      //screenPos.set(0,0,-screen_width/tan(fov/2));
      winsize = tan(radians(fov/2));
//////////////////// background ////////////////////
    } else if (token[0].equals("background")) {
      // TODO
      float r = float(token[1]);
      float g = float(token[2]);
      float b = float(token[3]);
      bgcolor.set(r, g, b);
      //background(r,g,b);
//////////////////// point_light ////////////////////
    } else if (token[0].equals("point_light")) {
      // TODO
      float x = float(token[1]);
      float y = float(token[2]);
      float z = float(token[3]);
      float r = float(token[4]);
      float g = float(token[5]);
      float b = float(token[6]);

      PVector p = new PVector(x, y, z);
      PVector c = new PVector(r, g, b);
      
      PMatrix3D mat = (PMatrix3D) getMatrix();
      PVector Lp = new PVector(0, 0, 0);

      mat.mult(p, Lp);

      lights[numLights] = new PtLight(Lp, c);
      numLights++;

//////////////////// diffuse ////////////////////
    } else if (token[0].equals("diffuse")) {
      // TODO
      kd.set(float(token[1]), float(token[2]), float(token[3]));
      ka.set(float(token[4]), float(token[5]), float(token[6]));
//////////////////// sphere ////////////////////
    } else if (token[0].equals("sphere")) {
      // TODO
      float r = float(token[1]);
      PVector p = new PVector(float(token[2]), float(token[3]), float(token[4]));

      PMatrix3D mat = (PMatrix3D) getMatrix();
      PVector Pp = new PVector(0, 0, 0);

      mat.mult(p, Pp);


      objects[numObjects] = new Sphere(Pp, r, ka, kd);
      numObjects++;
//////////////////// read ////////////////////
    } else if (token[0].equals("read")) {  // reads input from another file
      //println("Before read");
      interpreter (token[1]);
      //println("After read");
//////////////////// color ////////////////////
    } else if (token[0].equals("color")) {  // example command -- not part of ray tracer
      float r = float(token[1]);
      float g = float(token[2]);
      float b = float(token[3]);
      fill(r, g, b);
//////////////////// rect ////////////////////
    } else if (token[0].equals("rect")) {  // example command -- not part of ray tracer
      float x0 = float(token[1]);
      float y0 = float(token[2]);
      float x1 = float(token[3]);
      float y1 = float(token[4]);
      rect(x0, screen_height-y1, x1-x0, y1-y0);
//////////////////// begin ////////////////////
    } else if (token[0].equals("begin")) {
      poly = true;
//////////////////// vertex ////////////////////
    } else if (token[0].equals("vertex")) {
      if (poly && curVert < 3) {

        polyVerts[curVert] = new PVector(float(token[1]), float(token[2]), float(token[3]));
        curVert++;
      }
//////////////////// end ////////////////////
    } else if (token[0].equals("end")) {
      PMatrix3D mat = (PMatrix3D) getMatrix();
      PVector[] polyV = new PVector[3];
      for (int ii=0; ii<3; ii++) {
        polyV[ii] = new PVector(0, 0, 0);
        mat.mult(polyVerts[ii], polyV[ii]);
      }
      //println("Ka: "+ka.x+" "+ka.y+" "+ka.z);
      //println("Kd: "+kd.x+" "+kd.y+" "+kd.z);
      objects[numObjects] = new Polygon(polyV[0], polyV[1], polyV[2], ka, kd);
      numObjects++;
      curVert = 0;
      poly = false;
//////////////////// push ////////////////////
    } else if (token[0].equals("push")) {
      //PMatrix3D mat = (PMatrix3D) getMatrix();
      //mat.print();
      pushMatrix();
//////////////////// pop ////////////////////
    } else if (token[0].equals("pop")) {
      popMatrix();
//////////////////// translate ////////////////////
    } else if (token[0].equals("translate")) {
      translate(float(token[1]), float(token[2]), float(token[3]));
//////////////////// scale ////////////////////
    } else if (token[0].equals("scale")) {
      scale(float(token[1]), float(token[2]), float(token[3]));
//////////////////// rotate ////////////////////
    } else if (token[0].equals("rotate")) {
      float angle = radians(float(token[1]));
      PVector axis = new PVector(float(token[2]), float(token[3]), float(token[4]));
      axis.normalize();
      float y, p, r;

      // Convert Axis-Angle to Quaternion. REF: https://en.wikipedia.org/wiki/Rotation_formalisms_in_three_dimensions
      float[] q = {cos(angle/2), axis.x*sin(angle/2), axis.y*sin(angle/2), axis.z*sin(angle/2)};
      
      // Convert Quaternion to Euler Angles. REF: https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles
      y = atan2(2*(q[0]*q[1]+q[2]*q[3]), 1-2*(sq(q[1])+sq(q[2])));
      p = asin(2*(q[0]*q[2]-q[3]*q[1]));
      r = atan2(2*(q[0]*q[3]+q[1]*q[2]), 1-2*(sq(q[2])+sq(q[3])));
      
      //println("Euler: "+y+" "+p+" "+r);
      rotateX(y);
      rotateY(p);
      rotateZ(r);
//////////////////// rays_per_pixel ////////////////////
    } else if (token[0].equals("rays_per_pixel")){
      raysPerPx = int(token[1]);
//////////////////// moving_sphere ////////////////////
    } else if (token[0].equals("moving_sphere")){
      float r = float(token[1]);
      PVector p1 = new PVector(float(token[2]), float(token[3]), float(token[4]));
      PVector p2 = new PVector(float(token[5]), float(token[6]), float(token[7]));

      PMatrix3D mat = (PMatrix3D) getMatrix();
      PVector Pp1 = new PVector(0, 0, 0);
      PVector Pp2 = new PVector(0,0,0);

      mat.mult(p1, Pp1);
      mat.mult(p2, Pp2);


      objects[numObjects] = new Sphere(Pp1, r, ka, kd, true, Pp1, Pp2);
      numObjects++;
//////////////////// disk_light ////////////////////
    } else if (token[0].equals("disk_light")){
      float x = float(token[1]);
      float y = float(token[2]);
      float z = float(token[3]);
      float radius = float(token[4]);
      float r = float(token[8]);
      float g = float(token[9]);
      float b = float(token[10]);

      PVector p = new PVector(x, y, z);
      PVector n = new PVector(float(token[5]), float(token[6]), float(token[7]));
      PVector c = new PVector(r, g, b);
      
      PMatrix3D mat = (PMatrix3D) getMatrix();
      PVector Lp = new PVector(0, 0, 0);
      PVector Ln = new PVector(0, 0, 0);

      mat.mult(p, Lp);
      mat.mult(n, Ln);

      lights[numLights] = new DiskLight(Lp, Ln, c, radius);
      numLights++;
//////////////////// lens ////////////////////
    } else if (token[0].equals("lens")){
      
      lensRadius = float(token[1]);
      lensFocal = float(token[2]);
      isLens = true;
      
//////////////////// write ////////////////////
    } else if (token[0].equals("write")) {
      // save the current image to a .png file
      println("Num Objects: "+numObjects);
      //objects[0].printval();
      loadPixels();
      //println(numObjects);
      //println("Lights: "+numLights);
      //println(objects[0].pos);
      //println(lights[0].pos);
      //println(objects[0].radius);
      //println(width);
      //println(height);
      //scale(-1,1);
      int foundIndex = 0, unFoundIndex = 0;

      for (int x=0; x<width; x++) {
        for (int y=0; y<height; y++) {
          //println("Iterating over pixels");
                   
          PVector rayP = new PVector(0,0,0);
          // Pixel Center coords
          float x1 = (x - screen_width*1.0/2)*(winsize*2.0/(1.0*screen_width));
          float y1 = (y - screen_width*1.0/2)*(winsize*2.0/(1.0*screen_width));
          
          float pxbound = ((winsize*1.0)/(1.0*screen_width)); // Pixel bound each side from the center.
          PVector pxcolor = new PVector(0,0,0); // For anti-aliasing in case of multiple rays per pixel
          PVector focalHit = new PVector(0,0,-lensFocal);
          //println("Per Ray");
          for (int r=0; r<raysPerPx;r++){
            
            PVector startPt = new PVector(0,0,0);
            if (isLens){
              if (r==0){
                //println("once");
                float t = -lensFocal/(-1);
                rayP = new PVector(x1,y1,-1);
                focalHit = PVector.mult(rayP,t);
              }
              float sampleR = random(0.0,lensRadius);
              float sampleTheta = random(0.0,2*PI);
              startPt = new PVector(sampleR*cos(sampleTheta),sampleR*sin(sampleTheta),0);
              rayP = PVector.sub(focalHit,startPt);
              
            } else if (raysPerPx == 1){
              rayP = new PVector(x1, y1, -1);
            } else {
              rayP = new PVector(random(x1-pxbound,x1+pxbound),random(y1-pxbound,y1+pxbound),-1);
            }
            float time = random(0.0,1.0); // For motion blur
            //if (x%50 == 0 && y%50 == 0)
            //  println(x+" "+y+" "+x1+" "+y1+" "+rayP+" "+pxbound);
  
            float minT = MAX_INT; 
            int obIndex=0;
            boolean found = false;
            
            //println("Iterating over objects");
            for (int o=0; o<numObjects; o++) {
              //does object[i] and rayP intersect at any point(s)?
              //if so, are the points visible from any light source
              //print(x+" "+y+" "+rayP+" ");
              float t;
              if (objects[o].isMoving())
                t = objects[o].intersects(rayP, startPt, time);
              else
                t = objects[o].intersects(rayP, startPt);
              if (t > 0 && t<minT) {
                //println(t);
                found = true;
                minT = t;
                obIndex = o;
              }
            }
            if (found) {
              //set(x,y,color(1,1,1));
              foundIndex++;
              //println("found: "+obIndex);
              PVector pxcol = new PVector(0, 0, 0);
              PVector P = startPt;
              P.add(PVector.mult(rayP,minT));
              //rayP.copy();
              //P.mult(minT);
              PVector normal = new PVector(0,0,0);
              if (objects[obIndex].isMoving())
                normal = objects[obIndex].getNormal(P,time);
              else
                normal = objects[obIndex].getNormal(P);
              normal.normalize();
  
              //println("Iterating over lights");
  
              for (int l=0; l<numLights; l++) {
                pxcol.add(objects[obIndex].calcAmbient(l));
                //println("Ambient: "+pxcolor.x+" "+pxcolor.y+" "+pxcolor.z);
                //if (lights[l].visible(P, normal, obIndex)) {
                  //println("visible");
                  //println(lights[l].visible(P,normal,obIndex));
                pxcol.add(objects[obIndex].calcDiffuse(P, normal, l).mult(lights[l].visible(P, normal, obIndex)));
                
              }
              //pixels[loc] = color(pxcolor.x,pxcolor.y,pxcolor.z);
              //set(x, 299 - y, color(pxcol.x, pxcol.y, pxcol.z));
              pxcolor.add(pxcol);
              //println("pxdone");
              //println("Color: "+pxcolor.x+" "+pxcolor.y+" "+pxcolor.z);
            } else {
              unFoundIndex++;
              //println("not found");
              //pixels[loc] = color(bgcolor.x,bgcolor.y,bgcolor.z);
              //set(x, 299 - y, color(bgcolor.x, bgcolor.y, bgcolor.z));
              pxcolor.add(bgcolor);
              //println("bgdone");
            }
          }
          //println("col: "+pxcolor);
          pxcolor.div(raysPerPx);
          set(x, 299 - y, color(pxcolor.x, pxcolor.y, pxcolor.z));
        }
      }
      
      println("Found: "+foundIndex/raysPerPx+" UnFound: "+unFoundIndex/raysPerPx);
      println("DONE");

      save(token[1]);
    }
  }
}

//  Draw frames.  Should be left empty.
void draw() {
}

// when mouse is pressed, print the cursor location
void mousePressed() {
  println ("mouse: " + mouseX + " " + mouseY);
}