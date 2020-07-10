//
// A Boids-model implemantation on Processing
//      written by Fumio Nagasaka on 04th July 2020 
//

float Initial_Velocity = 6.0;
float Speed_Up         = 1.2;
float Slow_Down        = 0.6;

class SingleBird {
    float x0;
    float y0;
    float velocity;
    float ag0;
    float his_distance;
    float nearest;
    float mean_xpos;
    float mean_ypos;
    float mean_rad;  // 平均ラジアンの意味でつけた変数名
    float targ_rad;  // ターゲットまでの角度って意味の変数名
    int   blue_value;
    int   myself;
    
    class Neighbor {
      int   his_number;
      float distance;
      float direction;
    }
    
    Neighbor[] my_Neighbors = new Neighbor[NBR];
    
  //コンストラクター宣言部分
  SingleBird(int my_id) {
    
    x0  = 0.0;
    y0  = 0.0;
    velocity = Initial_Velocity;
    ag0 = 0.0;
    
    mean_xpos = 0.0;
    mean_ypos = 0.0;
    mean_rad  = 0.0;
    
    blue_value = int(100 + random(0,154));
    myself = my_id;
    
    for (int i = 0; i < NBR; i++) {
      my_Neighbors[i] = new Neighbor();
      my_Neighbors[i].his_number = 0;
      my_Neighbors[i].distance = 5000.0;
      my_Neighbors[i].direction = 0.0;
    }
    
  }
  
  //メソッド部分
  void draw() {

      int k_max = 0;
      float d_max = 0.0; // 初期値は「０番地さん」にするよ
    
    for (int i = 0; i < NBR; i++) {
      my_Neighbors[i].his_number = 0;
      my_Neighbors[i].distance = 5000.0;
      my_Neighbors[i].direction = 0.0;
    }
    
    // まずは空全体を眺めて、自分の近所の鳥たちを見つけ出す。見つける総数はNBR個にしたよ
    
    for (int i=0; i < NUM; i++) {
      
      // 今、この時点で、ご近所さんの中で一番遠くにいる人を見つけるよ
      int k = 0;
      while (k < NBR) {
         if (my_Neighbors[k].distance >= d_max) {
           d_max = my_Neighbors[k].distance;  // 新しく見つけた遠くのご近所さん！
           k_max = k;                         // その番地は覚えておきましょう
         }
         k++;
      }
      
      // さて次に「i番目」の鳥が、今のご近所さんよりも近くに来たかもしれないので、比べるよ
      // そのためには、ご近所さんの中でも、一番遠い人と比べてどうかな？って見てみるといいよ
      // 当たり前だけど、自分自身との距離は「0」だから、自分を除いて調べることを注意してね
      
      if (i != myself) {
      
          his_distance = get_Dist(i, x0, y0);    // i番目の鳥はどのくらい遠くにいるか？
          if (his_distance <= d_max) {
            my_Neighbors[k_max].distance = his_distance;  // もっとご近所さんが見つかったよ
            my_Neighbors[k_max].direction = allFlyingMap[i].direction;
            my_Neighbors[k_max].his_number = i;
          }
      } // <--- この範囲は、自分じゃない鳥を調べたって意味だよ
      
    }  // そして、この外側にあるfor文のループを使って空全体を一渡り眺めて見ているよ
    

    
    
    // ----------------------------- rule #1  普段はみんなの中心に寄っていくよ
    // 求心力の計算材料
    // 近所の皆さんの平均座標はどこにあるの？
    // ご近所の鳥さんの「鳥マイナンバー」はクラス・メンバーのhis_numberに入っている
    for (int i = 0; i < NBR; i++) {
      int k;
      k = my_Neighbors[i].his_number;
      mean_xpos += allFlyingMap[k].xpos;
      mean_ypos += allFlyingMap[k].ypos;
    }
    mean_xpos = mean_xpos/NBR;
    mean_ypos = mean_ypos/NBR;
    
    targ_rad = atan2(mean_xpos-x0, mean_ypos-y0);    // ここで群れの中心に向かうベクトルを計算
    velocity *= Speed_Up;                                 // 急いで群れに加わるよ
    ag0 = targ_rad;
    
    
    // ----------------------------- rule #2  飛ぶ方向はみんなにそろえるよ
    // 飛ぶ方向の合成ベクトルを計算するよ
    for (int i = 0; i < NBR; i++) {
      mean_rad += my_Neighbors[i].direction;
    }
    while (mean_rad > TWO_PI) {
      mean_rad -= TWO_PI;
    }

    for (int i = 0; i < NBR; i++) {
      my_Neighbors[i].direction = mean_rad;
    }
    
    // ----------------------------- rule #3  あんまり近いと離れるよ
    // 反発力の計算材料
    // 一番近い鳥はどのくらいの距離にいるの？
    nearest = 5000.0;
    for (int i = 0; i < NBR; i++) {
      if (my_Neighbors[i].distance <= nearest) {
        nearest = my_Neighbors[i].distance;
      }
    }
    
    if (nearest < 90) {
      velocity *= Slow_Down;
      ag0 -= HALF_PI/2;
    }
    
    
    // ----------------------------- 最終調整：墜落しない範囲での原則または加速
    //  速すぎなら少し遅くして
    //  遅すぎならやや加速する
    
    if (abs(velocity) > 8.0) {
      velocity *= 0.7;
    }
    if (abs(velocity) < 2.5) {
      velocity *= 2.0;
    }
    
    x0 += velocity*cos(ag0);
    y0 += velocity*sin(ag0);
    
    if ((x0 < 0) || (y0 < 0) || (x0 > image_w) || (y0 > image_h)) {
      velocity *= -1.0;
    } 
    
    fill(246, 221, blue_value);
    a_Bird(velocity, ag0, x0, y0);
    
    allFlyingMap[myself].xpos = x0;
    allFlyingMap[myself].ypos = y0;
    allFlyingMap[myself].direction = ag0;
  }
}


// 鳥１羽に着眼して、その頭の向きを回転させる、Processingでは角度の単位は「ラジアン」である
float x2 = 15.0;
float y2 = -3.0;
float x3 = 0.0;
float y3 = 10.0;
float x4 = -15.0;
float y4 = -3.0;

void a_Bird(float v, float angle, float cx, float cy) {
  float ang = angle + HALF_PI;
  
  if (v < 0) {    // 速度をマイナスにした場合は、後ろ向きに飛んだらおかしいので、向きを180°回転するよ
    ang += PI;    // <--   ここでね。
  }
  quad(cx+0,cy+0,
       cx+x2*cos(ang)-y2*sin(ang),  cy+x2*sin(ang)+y2*cos(ang),
       cx+x3*cos(ang)-y3*sin(ang),  cy+x3*sin(ang)+y3*cos(ang),
       cx+x4*cos(ang)-y4*sin(ang),  cy+x4*sin(ang)+y4*cos(ang));
}


// Mapの[index]番目の鳥と自分の距離を計算する
float get_Dist(int index, float my_xpos, float my_ypos) {
  float ds;
    ds = dist(allFlyingMap[index].xpos, allFlyingMap[index].ypos, my_xpos, my_ypos);
  return ds;
}
