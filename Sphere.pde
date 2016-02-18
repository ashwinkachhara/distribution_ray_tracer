class Sphere extends Shape{
  PVector pos = new PVector();
  PVector Ca = new PVector();
  PVector Cd = new PVector();
  float radius;
  boolean moving;
  PVector pos1, pos2;
  
  Sphere(PVector p, float r, PVector ka, PVector kd){
    pos = p.copy();
    radius = r;
    Ca = ka.copy();
    Cd = kd.copy();
    moving = false;
  }
  
  Sphere(PVector p, float r, PVector ka, PVector kd, boolean m, PVector p1, PVector p2){
    pos = p.copy();
    radius = r;
    Ca = ka.copy();
    Cd = kd.copy();
    moving = m;
    pos1 = p1.copy();
    pos2 = p2.copy();
  }
  
  Sphere(){
    
  }
  
  float intersects(PVector d, PVector P){
    float b = -2*((pos.x-P.x)*d.x+(pos.y-P.y)*d.y+(pos.z-P.z)*d.z);
    float a = d.magSq();
    float c = sq(P.x-pos.x)+sq(P.y-pos.y)+sq(P.z-pos.z)-radius*radius;
    //print(a+" "+b+" "+c+" ");
    if (b*b < 4*a*c){
      //println(-1);
      return -1000;
    }
    float t1 = (-b+sqrt(1.0*b*b-4.0*a*c))/(2.0*a);
    float t2 = (-b-sqrt(1.0*b*b-4.0*a*c))/(2.0*a);
    //println(t1," ",t2);
    
    if (t1<0 && t2<0){
      return -1000;
    } else if (t1>0 && t2>0){
      return min(t1,t2);
    } else if (t1>0){
      return t1;
    } else {
      return t2;
    }
  }
  
  float intersects(PVector d, PVector P, float t){
    
    PVector newpos = PVector.lerp(pos1,pos2,t);
    float b = -2*((newpos.x-P.x)*d.x+(newpos.y-P.y)*d.y+(newpos.z-P.z)*d.z);
    float a = d.magSq();
    float c = sq(P.x-newpos.x)+sq(P.y-newpos.y)+sq(P.z-newpos.z)-radius*radius;
    //print(a+" "+b+" "+c+" ");
    if (b*b < 4*a*c){
      //println(-1);
      return -1000;
    }
    float t1 = (-b+sqrt(1.0*b*b-4.0*a*c))/(2.0*a);
    float t2 = (-b-sqrt(1.0*b*b-4.0*a*c))/(2.0*a);
    //println(t1," ",t2);
    
    if (t1<0 && t2<0){
      return -1000;
    } else if (t1>0 && t2>0){
      return min(t1,t2);
    } else if (t1>0){
      return t1;
    } else {
      return t2;
    }
  }
  
  PVector getNormal(PVector P){
    return PVector.sub(P,pos).normalize();
  }
  
  PVector getNormal(PVector P, float t){
    PVector newpos = PVector.lerp(pos1,pos2,t);
    return PVector.sub(P,newpos).normalize();
  }
  
  PVector calcDiffuse(PVector P, PVector n, int l){
    PVector col = new PVector(0,0,0);
    PVector L = lights[l].vec2Light(P);//PVector.sub(lights[l].pos,P);
    L.normalize();
    PVector lColor = lights[l].getColor();
    col.x = Cd.x*(PVector.dot(L,n))*lColor.x;
    col.y = Cd.y*(PVector.dot(L,n))*lColor.y;
    col.z = Cd.z*(PVector.dot(L,n))*lColor.z;
    return col;
  }
  
  PVector calcAmbient(int l){
    PVector col = new PVector(0,0,0);
    PVector lColor = lights[l].getColor();
    col.x = Ca.x*lColor.x;
    col.y = Ca.y*lColor.y;
    col.z = Ca.z*lColor.z;
    return col;
  }
  
  void printval(){
    println("pos: "+pos.x+" "+pos.y+" "+pos.z);
  }
  
  boolean isMoving(){
    return moving;
  }
}