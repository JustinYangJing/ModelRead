//
//  Sphere.m
//  iyinxiu
//
//  Created by JustinYang on 2021/3/17.
//  Copyright © 2021 yinxiu. All rights reserved.
//

#import "Sphere.h"
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/EAGL.h>
#import <mach/mach.h>
#include "Shader.hpp"
#include "Camera.hpp"
#include "Model.hpp"
#import <GLKit/GLKit.h>
#include "stb_image.h"

Camera camera(glm::vec3(0.0f,0.0f,55.0f));

@interface Sphere()
@property(nonatomic, strong) CADisplayLink *link;
@end
@implementation Sphere
{
    GLuint _fbo;
    GLuint _rbo;
    EAGLContext *_context;
    Shader  *_glsl;
    unsigned int VAO;
    unsigned int VBO;
    unsigned int textureID;
    unsigned int textureID1;
    Model  *_sphereModel;
    float angle;
}
+(Class)layerClass{
    return [CAEAGLLayer class];
}
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self layerInit];
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
        _context.multiThreaded = YES;
        [EAGLContext setCurrentContext:_context];
        
        
    }
    return self;
}

-(void)layerInit{
    CAEAGLLayer *layer = (CAEAGLLayer *)self.layer;
    
    layer.opaque = NO;
    layer.contentsScale = [UIScreen mainScreen].scale;
    layer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:@(NO),
                                kEAGLDrawablePropertyRetainedBacking,
                                kEAGLColorFormatRGBA8,
                                kEAGLDrawablePropertyColorFormat,nil];
    self.backgroundColor = [UIColor clearColor];
}

-(void)setFBOAndRBO{
    
    glGenFramebuffers(1, &_fbo);
    glBindFramebuffer(GLenum(GL_FRAMEBUFFER), _fbo);
    
    glGenRenderbuffers(1, &_rbo);
    glBindRenderbuffer(GLenum(GL_RENDERBUFFER), _rbo);
    
    glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), _rbo);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    
    
    NSAssert(glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER)) == GLenum(GL_FRAMEBUFFER_COMPLETE), @"初始化fbo出错");
    
   
}
-(void)showSphere{
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
//    for (float xita = -M_PI_2 ; xita < M_PI_2; ) {
//        for (float alpha = -M_PI; alpha < M_PI ; ) {
//            float x = 1.0*sin(xita)*cos(alpha);
//            float y = 1.0*sin(xita)*sin(alpha);
//            float z = 1.0*cos(xita);
//            vertex[i++] = x;
//            vertex[i++] = y;
//            vertex[i++] = z;
//            alpha = alpha + xy_step;
//        }
//        xita = xita + z_step;
//
//    }
    
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

unsigned int loadTexture(char const *path)
{
    unsigned int textureID;
    glGenTextures(1, &textureID);

    int width, height, nrComponents;
    unsigned char *data = stbi_load(path, &width, &height, &nrComponents, 0);
    if (data)
    {
        GLenum format = GL_RGB ;
        if (nrComponents == 1)
            format = GL_RED;
        else if (nrComponents == 3)
            format = GL_RGB;
        else if (nrComponents == 4)
            format = GL_RGBA;

        glBindTexture(GL_TEXTURE_2D, textureID);
        glTexImage2D(GL_TEXTURE_2D, 0, format, width, height, 0, format, GL_UNSIGNED_BYTE, data);
        glGenerateMipmap(GL_TEXTURE_2D);

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

        stbi_image_free(data);
    }
    else
    {
        std::cout << "Texture failed to load at path: " << path << std::endl;
        stbi_image_free(data);
    }

    return textureID;
}

-(void)display{
    
    glBindFramebuffer(GL_FRAMEBUFFER,_fbo);
    glBindRenderbuffer(GL_RENDERBUFFER, _rbo);
    
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    
    float scale = [UIScreen mainScreen].scale;
    glViewport(0, 0, self.frame.size.width * scale, self.frame.size.height * scale);
   
    
    _glsl->use();
  

    glm::mat4 model = glm::mat4(1.0);
    float angleX = M_PI_2;
    model = glm::rotate(model, angleX, glm::vec3(1.0f, 0.0f, 0.0f));
    
    model = glm::rotate(model, angle, glm::vec3(0.0f, 0.0f, 1.0f));
    angle = angle + M_PI/300;
    if (angle > 2*M_PI){
        angle = 0;
    }
    

    _glsl->setMat4("model", model);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self->textureID);
    
    glBindVertexArray(VAO);
    glDrawArrays(GL_TRIANGLES, 0, 100*100*6);
    

    model = glm::scale(model, glm::vec3(0.5,0.5,0.5));
    _glsl->setMat4("model", model);
    glBindTexture(GL_TEXTURE_2D, self->textureID1);
    glDrawArrays(GL_TRIANGLES, 0, 100*100*6);
    
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
    glBindVertexArray(0);
   
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
    glBindFramebuffer(GL_FRAMEBUFFER,0);
    

    
}
-(void)showSphereModel{
    NSString *vertPath = [[NSBundle mainBundle] pathForResource:@"sphere" ofType:@"vert"];
    NSString *fragPath = [[NSBundle mainBundle] pathForResource:@"sphere" ofType:@"frag"];
    
    _glsl = new Shader(vertPath.UTF8String,fragPath.UTF8String);
    
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"main" ofType:@"obj"];
    _sphereModel = new Model(modelPath.UTF8String);
    
    
    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(display1)];
    [self.link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

-(void)display1{
    glBindFramebuffer(GL_FRAMEBUFFER,_fbo);
    glBindRenderbuffer(GL_RENDERBUFFER, _rbo);
    
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    
    float scale = [UIScreen mainScreen].scale;
    glViewport(0, 0, self.frame.size.width * scale, self.frame.size.height * scale);
   
    
    _glsl->use();
    glm::mat4 projection = glm::perspective(glm::radians(camera.Zoom), (float)self.frame.size.width / (float)self.frame.size.height, 0.1f, 100.0f);
    glm::mat4 view = camera.GetViewMatrix();
    _glsl->setMat4("projection", projection);
    _glsl->setMat4("view", view);

    glm::mat4 model = glm::mat4(1.0);
    model = glm::translate(model, glm::vec3(0.0f, -3.0f, 0.0f));
    model = glm::scale(model, glm::vec3(0.12f, 0.12f, 0.12f));
    model = glm::rotate(model, angle, glm::vec3(0.0f, 1.0f, 0.0f));
    angle = angle + M_PI/300;
    if (angle > 2*M_PI){
        angle = 0;
    }
    _glsl->setMat4("model", model);
    
    _sphereModel->Draw(*_glsl);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
//    glBindVertexArray(0);
   
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
    glBindFramebuffer(GL_FRAMEBUFFER,0);
    
}
@end
