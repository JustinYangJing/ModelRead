### 画一个绕Y轴旋转的球

> 最近在做一个绕Y轴旋转的球，把之前mac端运行的opengl的相关库，让其支持手机，记录一下
>
> - 读取模型文件的库 `assimp`，制作的时候，只选了支持arm64与x86_64,光支持这2个架构，都有1G大小了
> - `stb_image`读取图片
> - `Shader`读取角色器文件
> - `Camera`生成视图矩阵
> - `glm`库，矩阵变化处理



> 实现绕Y轴旋转的球的三种方法
>
> - 使用导出的mp4，循环播放这个mp4
> - `assimp`引入模型文件，用opengl来动画
> - 代码构造顶点坐标，用opengl来动画



<video id="video" controls="" autoplay preload="none" loop  width=350 height=350 poster="https://lifestyle1.cn/Resource/Image/sphere/videoposter.png">  <source id="mp4" src="https://lifestyle1.cn/Resource/Image/sphere/video.mp4" type="video/mp4">  </video>

##### `assimp`引入模型文件，用opengl来动画

- `layer` `FBO` `RBO`的初始化设置，见[上一篇文章](https://lifestyle1.cn/2021/03/25/%E5%B1%8F%E5%B9%95%E7%9B%91%E6%8E%A7/)

- 编写顶点着色器与片元着色器

  导出的球的模型不包含纹理，所以在片元着色器中直接给了一个颜色值

- `showSphereModel`函数读取编译着色器、读取模型文件

- 在刷新帧中，改变`model`矩阵绕Y轴旋转角度，使用模型的对象的Draw方法不断重绘

##### 代码构造顶点坐标，用opengl来动画

> 要生成球面上的点，再以这个点为中心，偏移出一个四边形(其实是球面上的圆弧块)作为顶点着色器的顶点输入；一个四边形对应一个纹理图片；

- `layer` `FBO` `RBO`的初始化设置，见[上一篇文章](https://lifestyle1.cn/2021/03/25/%E5%B1%8F%E5%B9%95%E7%9B%91%E6%8E%A7/)

- 编写顶点着色器与片元着色器

  使用stb读png图片时，发现r和b分量是反的(变成BGRA,未深究，在mac上读图片，没碰到这样的问题)，所以在片元着色器中交换了 一下这两个分量

- 在`showSphere`中构造顶点与纹理坐标、加载着色器代码、加载纹理

  >球的上的点的方程是
  >
  >x = R\*sin(xita)\*cos(alpha)
  >
  >y = R\*sin(xita)\*sin(alpha)
  >
  >z = R\*cos(xita)
  >
  >这里的方程是针对三维笛卡尔坐标的
  >
  >![坐标系](https://lifestyle1.cn/Resource/Image/sphere/coor.jpeg)
  >
  >xita是圆心与该点连线与OZ的夹角，范围是 `-pi/2`~`pi/2`
  >
  >alpha是圆心与该点连线在xoy平面投影线段与ox的夹角，范围是 `-pi`~`pi`
  >
  >而opengl使用的坐标系是右手坐标系
  >
  >![右手坐标系](https://lifestyle1.cn/Resource/Image/sphere/rightHand.png)
  >
  >在用三维笛卡尔坐标系构造球体的点时，又直接将其放到右手坐标系中，需要使用模型矩阵先绕x轴旋转(代码的两个for循环，里层的for循环是画一圈经线，所以与Z轴的夹角也变成了-pi ~ pi的取值返回)，动画时是绕z轴旋转
  
  ```c++
  {
      float row = 100;
      float xy_step = 2*M_PI/row;
      float z_step = 2*M_PI/row;
      //总共的中心点是100(100条经度圈)*100(经度圈上100个中心点)个，以中心点为中心，构造一个四边形(GL_TRIANGLES画一个4边行是需要6个点，所以乘以6)
      //每个点有坐标和纹理坐标
      float *vertex = (float *)malloc(5*100*100*sizeof(float)*6);
      int i = 0;
      for (float alpha = -M_PI ; alpha < M_PI; ) {
          for (float xita = -M_PI; xita < M_PI ; ) {
              //生成大小不一的四边形
              int rand = 3 + arc4random_uniform(5);
              float x ,y ,z;
              x = 1.0*sin(xita+z_step/rand)*cos(alpha + xy_step/rand);
              y = 1.0*sin(xita+z_step/rand)*sin(alpha + xy_step/rand);
              z = 1.0*cos(xita+z_step/rand);
              vertex[i++] = x;
              vertex[i++] = y;
              vertex[i++] = z;
              
              vertex[i++] = 1.0f;
              vertex[i++] = 1.0f;
              
             float xx = 1.0*sin(xita+z_step/rand)*cos(alpha - xy_step/rand);
              float yy = 1.0*sin(xita+z_step/rand)*sin(alpha - xy_step/rand);
              float zz = 1.0*cos(xita+z_step/rand);
              vertex[i++] = xx;
              vertex[i++] = yy;
              vertex[i++] = zz;
              
              vertex[i++] = 0.0f;
              vertex[i++] = 1.0f;
              
              x = 1.0*sin(xita-z_step/rand)*cos(alpha + xy_step/rand);
              y = 1.0*sin(xita-z_step/rand)*sin(alpha + xy_step/rand);
              z = 1.0*cos(xita-z_step/rand);
              vertex[i++] = x;
              vertex[i++] = y;
              vertex[i++] = z;
              
              vertex[i++] = 1.0f;
              vertex[i++] = 0.0f;
              
              vertex[i++] = x;
              vertex[i++] = y;
              vertex[i++] = z;
              
              vertex[i++] = 1.0f;
              vertex[i++] = 0.0f;
              
              
              vertex[i++] = xx;
              vertex[i++] = yy;
              vertex[i++] = zz;
              
              vertex[i++] = 0.0f;
              vertex[i++] = 1.0f;
              
              x = 1.0*sin(xita-z_step/rand)*cos(alpha - xy_step/rand);
              y = 1.0*sin(xita-z_step/rand)*sin(alpha - xy_step/rand);
              z = 1.0*cos(xita-z_step/rand);
              
              vertex[i++] = x;
              vertex[i++] = y;
              vertex[i++] = z;
              
              vertex[i++] = 0.0f;
              vertex[i++] = 0.0f;
              
              xita = xita + z_step;
          }
          alpha = alpha + xy_step;
      }
      
      NSString *vertPath = [[NSBundle mainBundle] pathForResource:@"glsl" ofType:@"vert"];
      NSString *fragPath = [[NSBundle mainBundle] pathForResource:@"glsl" ofType:@"frag"];
      
      _glsl = new Shader(vertPath.UTF8String,fragPath.UTF8String);
         
      
      NSString *texPath = [[NSBundle mainBundle] pathForResource:@"blue1" ofType:@"png"];
      self->textureID = loadTexture(texPath.UTF8String);
      
      texPath = [[NSBundle mainBundle] pathForResource:@"blue1" ofType:@"png"];
      self->textureID1 = loadTexture(texPath.UTF8String);
      
      _glsl->use();
      _glsl->setInt("tex", 0);
      
      glm::mat4 projection = glm::perspective(glm::radians(camera.Zoom), (float)self.frame.size.width / (float)self.frame.size.height, 0.1f, 100.0f);
      Camera *c = new  Camera(glm::vec3(0.0f,0.0f,3));
      glm::mat4 view = c->GetViewMatrix();
      _glsl->setMat4("projection", projection);
      _glsl->setMat4("view", view);
      
      glGenVertexArrays(1,&VAO);
      glGenBuffers(1, &VBO);
      glBindVertexArray(VAO);
      glBindBuffer(GL_ARRAY_BUFFER,VBO);
      glBufferData(GL_ARRAY_BUFFER, 6*5*100*100*sizeof(float), vertex, GL_STATIC_DRAW);
      glEnableVertexAttribArray(0);
      glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5* sizeof(float), (void *)0);
      glEnableVertexAttribArray(1);
      glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5*sizeof(float), (void *)(3 *sizeof(float)));
      
      glBindVertexArray(0);
      
      
    glBindBuffer(GL_ARRAY_BUFFER, 0);
      glBindVertexArray(0);
      glBindFramebuffer(GL_FRAMEBUFFER, 0);
      glBindRenderbuffer(GL_RENDERBUFFER, 0);
      
  
      angle = 0;
      self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(display)];
      [self.link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
      
  }
  ```
  
- 在刷新帧中绘制顶点数据

