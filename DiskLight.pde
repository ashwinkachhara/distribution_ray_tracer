class DiskLight extends Light{
  PVector pos = new PVector();
  PVector lColor = new PVector();
  PVector lNormal = new PVector();
  float radius;
  
  DiskLight(PVector p, PVector n, PVector c, float r){
    pos = p.copy();
    lColor = c.copy();
    lNormal = n.copy();
    radius = r;
    lNormal.normalize();
  }
  
  DiskLight(){
    
  }
  
  PVector vec2Light(PVector P){
    return PVector.sub(pos,P);
  }
  
  PVector getColor(){
    return lColor;
  }
  
  /* This function assumes that the normal of the disk light is along either of the coordinate axes. My unsuccessful attempt at 
  writing a function that does not make this assumption is below (commented out)*/
  float visible(PVector pt, PVector normal, int obIndex){
    
    float sampleR = random(0.0,radius);
    float sampleTheta = random(0.0,2*PI);
    PVector samplePos = new PVector(0,0,0);
    if (lNormal.equals(new PVector(1,0,0)) || lNormal.equals(new PVector(-1,0,0)))
      samplePos = new PVector(pos.x,pos.y+sqrt(sampleR)*cos(sampleTheta),pos.z+sqrt(sampleR)*sin(sampleTheta));
    else if (lNormal.equals(new PVector(0,1,0)) || lNormal.equals(new PVector(0,-1,0)))
      samplePos = new PVector(pos.x+sqrt(sampleR)*cos(sampleTheta),pos.y,pos.z+sqrt(sampleR)*sin(sampleTheta));
    else
      samplePos = new PVector(pos.x+sqrt(sampleR)*cos(sampleTheta),pos.y+sqrt(sampleR)*sin(sampleTheta),pos.z);
    PVector v1 = PVector.sub(samplePos,pt);
    float d = v1.dot(normal);
    //return d>0;
    
    if (d<0)
      if (objects[obIndex] instanceof Polygon)
        return 1.0;
      else
        return 0.0;
    else{
      boolean found = false;
     for (int o=0;o<numObjects;o++){
       if (o != obIndex){
         float t = objects[o].intersects(v1,pt);
         if (t>0 && t<1){
           found = true;
           break;
         }
       }
     }
     if (found)
       return 0.0;
     else
       return 1.0;
    }
  }
  /*
  float visible(PVector pt, PVector normal, int obIndex){
    //PVector A = lNormal;
    //PVector B = new PVector(0,0,1);
    //PVector row2 = PVector.sub(B,PVector.mult(A, A.dot(B))).normalize();
    //PMatrix3D G = new PMatrix3D(A.dot(B), -1*A.cross(B).mag(), 0.0, 0.0, A.cross(B).mag(), A.dot(B), 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0);
    //PMatrix3D F = new PMatrix3D(A.x, row2.x, B.cross(A).x, 0.0, A.y, row2.y, B.cross(A).y,A.z, 0.0, row2.z, B.cross(A).z, 0.0, 0.0, 0.0, 0.0, 1.0);
    //PMatrix3D Fi = new PMatrix3D(A.x, row2.x, B.cross(A).x, 0.0, A.y, row2.y, B.cross(A).y,A.z, 0.0, row2.z, B.cross(A).z, 0.0, 0.0, 0.0, 0.0, 1.0);
    //Fi.invert();
    
    if (lNormal.equals(new PVector(0,-1,0))){
      
    }
    
    //G.preApply(Fi);
    //F.preApply(G);
    
    //F.mult(samplePos,x)
    float visibility=0;
    PVector samplePos = new PVector(0,0,0);
    
    //PVector x = new PVector(0,0,0);
        
    //for (int s=0; s<raysPerPx; s++){
    
      float sampleR = random(0.0,radius);
      float sampleTheta = random(0.0,2*PI);
      samplePos = new PVector(pos.x+sqrt(sampleR)*cos(sampleTheta),pos.y,pos.z+sqrt(sampleR)*sin(sampleTheta));
      
      //F.mult(sampleP,samplePos);
      
      //if (PVector.sub(pos,samplePos).mag()>radius)
      //  println("point out of disk");
      
      //if (s==0)
      //  x = samplePos;
      //else{
      //  if (PVector.sub(samplePos,x).dot(lNormal) != 0)
      //    println("nonzero");
      //  x = samplePos;
      //}
      
      PVector v1 = PVector.sub(samplePos,pt);
      float d = v1.dot(normal);
      //return d>0;
      
      if (d<0)
      if(objects[obIndex] instanceof Polygon)
        visibility = visibility+1;
      else{
        boolean found = false;
        for (int o=0;o<numObjects;o++){
          if (o != obIndex){
            float t = objects[o].intersects(v1,pt);
            if (t>0 && t<1){
              found = true;
              break;
            }
          }
        }
        if (!found)
          visibility = visibility+1;
      }
    //}
    visibility = visibility/raysPerPx;
    //if (visibility>0)
    //  println("visibility: " + visibility);
    return visibility;
  }
  */
}