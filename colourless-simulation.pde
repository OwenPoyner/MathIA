public static class Complex {
  public float re = 0;
  public float im = 0;
  
  public Complex (float re, float im) {
    this.re = re;
    this.im = im;
  } 
  
  public Complex conj() {
    return new Complex(this.re, this.im*(-1));
  }
  
  public float mod() {
    return sqrt((this.re * this.re) + (this.im * this.im));
  }  
  
  public float arg() {
    if ((this.re > 0) && (this.im > 0)) {
      return atan(this.im / this.re); // quad 1
    }  else if ((this.re < 0) && (this.im > 0)) {
      return atan(this.im / this.re) + PI; // quad 2
    }  else if ((this.re < 0) && (this.im <= 0)) {
      return atan(this.im / this.re) + PI; //quad 3
    }  else if ((this.re >= 0) && (this.im < 0)) {
      return atan(this.im / this.re) + (2 * PI); //quad 4
    }  else if (this.re == 0 || this.im == 0) {
      return atan(this.im / this.re); // in re/im 0 edge cases, unmodified atan works
    }  else {
      return 0.0;
    }  
  }    
}

public static class com {
  public static Complex toComplex(float a) {
    return new Complex(a, 0);
  }  
  
  public static Complex sum(Complex a, Complex b) {
    return new Complex(a.re + b.re, a.im + b.im);
  }  
  
  public static Complex subtract(Complex a, Complex b){
    return new Complex(a.re - b.re, a.im - b.im);
  }
  
  public static Complex product(Complex a, Complex b) {
    return new Complex(((a.re * b.re) - (a.im * b.im)), ((a.re * b.im) + (a.im * b.re)));
  }
  
  public static Complex divide(Complex a, Complex b) {
    return new Complex((((a.re * b.re) + (a.im * b.im)) / ((b.re * b.re) + (b.im * b.im))), (((b.re * a.im) - (a.re * b.im)) / ((b.re * b.re) + (b.im * b.im))));
  }
  
  public static float arg(Complex a) {
    if ((a.re > 0) && (a.im > 0)) {
      return atan(a.im / a.re); // quad 1
    }  else if ((a.re < 0) && (a.im > 0)) {
      return atan(a.im / a.re) + PI; // quad 2
    }  else if ((a.re < 0) && (a.im <= 0)) {
      return atan(a.im / a.re) + PI; //quad 3
    }  else if ((a.re >= 0) && (a.im < 0)) {
      return atan(a.im / a.re) + (2 * PI); //quad 4
    }  else if (a.re == 0 || a.im == 0) {
      return atan(a.im / a.re); // in re/im 0 edge cases, unmodified atan works
    }  else {
      return 0.0;
    }  
  }
  
  public static Complex mod(Complex z) {
    return new Complex(sqrt((z.re * z.re) + (z.im * z.im)), 0);
  }  
  
  public static ArrayList<Complex> roots (Complex z, int m) {
    ArrayList<Complex> roots = new ArrayList<Complex>();
    float theta = z.arg();
    float r = z.mod();
    for (int n = 0; n < m; n++) {
      float re = pow(r,1.0/m)*sin((2*PI*n+theta)/m);
      float im = pow(r,1.0/m)*cos((2*PI*n+theta)/m);
      Complex nth = new Complex(re, im);
      roots.add(nth);
    }  
    return roots;
  }  
  
  public static void test (Complex z) {
    String sign = "";
    if (z.im >= 0) {
      sign = "+";
    }
    println(z.re + sign + z.im + "i");
  }  
}


public float opacityvelcross(Complex vel, Complex accel, float amnt) {
  Complex cross = com.divide(com.subtract(com.product(vel.conj(), accel), com.product(vel, accel.conj())), new Complex(2, 0));
  float a = (com.product(new Complex(0, 1), cross).mod())/(2*accel.mod()*vel.mod());
  return 1.0-(amnt/(a+1));
  
}

/* 

public float vfield (float x){
  float mag = abs(x);
  float f = ((x / (mag * mag * mag)) + (cos(1.1 * x) / 7) + (sin(x) / 4) + (100 / x)) * 10;
  return -f;
} 





*/

public Complex forcefield (Complex k, Complex alpha, int w, float m) {
  //return com.product(k, new Complex(0, 1));
  Complex tot = new Complex(0, 0);
  Complex mass = new Complex( m, 0);
  ArrayList<Complex> roots = com.roots(alpha, w);
  
  
  for (Complex root : roots) {
    Complex a = com.product(mass, com.subtract(root, k));
    Complex b = com.product(com.product(com.mod(com.subtract(root, k)), com.mod(com.subtract(root, k))), com.mod(com.subtract(root, k)));
    tot = com.sum(tot, com.divide(a, b));
  }  
  
  return com.product(tot, new Complex(1, 0));
}

public Complex airdrag (Complex vel, float dc) {
  float mag = (vel.mod()/2)*dc;
  
  return com.product(new Complex(mag, 0), vel);
}  

public class Particle {
  public Complex pos;
  public Complex vel;
  public color colour;
  public int maxlife;
  public int life;
  public float mass;
  public float drag;
  
  public Particle (Complex pos, Complex vel, color colour, int maxlife, float mass, float drag) {
    this.pos = pos;
    this.vel = vel;
    this.colour = colour;
    this.maxlife = maxlife;
    this.life = maxlife;
    this.mass = mass;
    this.drag = drag;
    
  }
  
  public void move (Complex accel, float t) {
    Complex prevVel = this.vel;
    Complex netforce = com.subtract(accel, airdrag(this.vel, drag));
    this.vel = com.sum(prevVel, com.product(netforce, new Complex(t, 0)));
    //this.xpos += ((prevVel + this.vel) / 2) * t;
    this.pos = com.sum(this.pos, com.product(new Complex(t, 0), com.divide(com.sum(prevVel, this.vel), new Complex(2, 0))));
    this.life--;
  }

} 

void setup() {
  size(1900, 900);
  background(0,0,0);
  strokeWeight(1);
  
  float numParts = 1000;
  float partRange = 1;
  float interval = partRange / (numParts - 1);
  float lowerbound = 0 - (partRange/2);
  
  //important
  float tstep = 0.01;
  float scale = 8;
  Complex alpha = new Complex(3, 1000);
  int blackHoles = 3;
 
 
  /*
  //make black holes
  ArrayList<Complex> roots = com.roots(alpha, blackHoles);
  for (Complex root : roots) {
    fill(255, 0, 0);
    stroke(255, 0, 0);
    Complex rescal = com.product(root, new Complex(scale, 0));
    circle(rescal.re + width/2, (rescal.im * -1) + height/2, 20);
    //com.test(root);
  }
  */
  
  
  
  ArrayList<Particle> particles = new ArrayList<Particle>();
  
  for (int i = 0; i < numParts; i += 1) {
  
    float normalizedinterval = i / numParts;
    float colnormint = normalizedinterval * 255;
    
    float startpos = lowerbound + (interval * i);
    color col = color(colnormint);
    Complex pos = new Complex(-20, startpos+10);
    Complex vel = new Complex(4, 1);
    particles.add(new Particle(pos, vel, col, 100000, 100.0, 0.01));
    
    //print(particles.get(i).xpos + "     ");
    //particles.get(i).move(vfield(particles.get(i).xpos), tstep);
    //print(particles.get(i).xpos + "\n");

    
  }
  for (Particle part : particles) {
    for (int j = part.life; j != 0; j--) {
      stroke(part.colour, 255*opacityvelcross(part.vel, forcefield(part.pos, alpha, blackHoles, part.mass), 1));
      //square(j+10, part.xpos, 2);
      Complex prevpos = part.pos;
      part.move(forcefield(part.pos, alpha, blackHoles, part.mass), tstep);
      Complex curpos = part.pos;
      
      Complex pre = com.product(prevpos, new Complex(scale, 0));
      Complex cur = com.product(curpos, new Complex(scale, 0));
      
      line(pre.re + width/2, (pre.im * -1) + height/2, cur.re + width/2, (cur.im * -1) + height/2);
      
      if(forcefield(part.pos, alpha, blackHoles, part.mass).mod() > 3000) {
        break;
      }

    }
  }
  print("done!");
}
