//
// A Boids-model implemantation on Processing
//      written by Fumio Nagasaka on 04th July 2020 
//
float  image_w = 600;
float  image_h = 600;
PImage background_image;   //背景イメージのオブジェクト

int NUM = 256;
int NBR = 32;        // 近所の鳥たちとしてとりあえず

class LookAtThisBird {
  float xpos;
  float ypos;
  float velocity;
  float direction;
}

SingleBird[] skyBirds = new SingleBird[NUM];  //今、この空にいる全ての鳥たち
LookAtThisBird[] allFlyingMap = new LookAtThisBird[NUM];  //その全ての鳥たちの情報

void setup() {
  background_image = loadImage("sky20200703.png");
  size(600, 600);
  frameRate(60);

  for (int i = 0; i < NUM; i++) {
    allFlyingMap[i] = new LookAtThisBird();          // 空全体の鳥のマップを作る
    allFlyingMap[i].xpos = random(0, image_w);       // 各鳥の出現場所の初期値は、
    allFlyingMap[i].ypos = random(0, image_h);       // X,Y を乱数で作りだす
    allFlyingMap[i].direction = random(0.0, PI);     // 単位はラジアン
  }
  
  for (int i = 0; i < NUM; i++) {
    skyBirds[i] = new SingleBird(i);
    skyBirds[i].x0 = allFlyingMap[i].xpos;
    skyBirds[i].y0 = allFlyingMap[i].ypos;
    skyBirds[i].ag0 = allFlyingMap[i].direction;
  }
}

void draw() {
  
  image(background_image, 0, 0, 600, 600);
  
  noStroke();  
  for (int i = 1; i < NUM; i++) {
    skyBirds[i].draw();
  }
}






  
