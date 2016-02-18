class PtLight extends Light{
  PVector pos = new PVector();
  PVector lColor = new PVector();
  
  PtLight(PVector p, PVector c){
    pos = p.copy();
    lColor = c.copy();
  }
  
  PtLight(){
  }
  
  PVector vec2Light(PVector P){
    return PVector.sub(pos,P);
  }
  
  PVector getColor(){
    return lColor;
  }
  
  float visible(PVector pt, PVector normal, int obIndex){
    PVector v1 = PVector.sub(pos,pt);
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
}