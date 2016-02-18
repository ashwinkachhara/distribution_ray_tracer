abstract class Light{
  public abstract float visible(PVector pt, PVector normal, int obIndex);
  public abstract PVector vec2Light(PVector P);
  public abstract PVector getColor();
}