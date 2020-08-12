//
//  HyGLKView.m
//  OpenGL ES - GLSL案例三： 纹理颜色混合
//
//  Created by Henry on 2020/8/9.
//  Copyright © 2020 刘恒. All rights reserved.
//

#import "HyGLKView.h"
#import <OpenGLES/ES3/gl.h>
#import <GLKit/GLKMath.h>
@interface HyGLKView() <GLKViewDelegate>
@property(nonatomic,strong)GLKBaseEffect *myEffect;
@end

@implementation HyGLKView
{
    CGFloat xDegree;
    CGFloat yDegree;
    CGFloat zDegree;
    
    BOOL bx;
    BOOL by;
    BOOL bz;
    
    CADisplayLink *link;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
        [EAGLContext setCurrentContext:context];
        self = [super initWithFrame:frame context:context];
    }
    return self;
}

- (void)layoutSubviews{
    self.delegate = self;
    self.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    self.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    glEnable(GL_DEPTH_TEST);
    
    //顶点数组, 前3位顶点， 后3位颜色（RGB，A默认为1.0）
    GLfloat vertex[] = {
        -0.5f, 0.0f, -0.5f, 0, 1, 1.0f,0.0f,0.0f, //左上
        -0.5f, 0.0f,  0.5f, 0, 0, 1.0f,0.5f,0.0f, //左下
         0.5f, 0.0f,  0.5f, 1, 0, 0.5f,0.5f,0.5f, //右下
         0.5f, 0.0f, -0.5f, 1, 1, 0.0f,0.5f,1.0f, //右上
         0.0f, 1.0f,  0.0f, 0.5, 0.5, 1.0f,1.0f,1.0f,  //顶点
    };
    
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertex), vertex, GL_DYNAMIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat*)NULL+0);
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat*)NULL+3);
    
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat*)NULL+5);
    
    GLKTextureInfo *info = [GLKTextureLoader textureWithCGImage:[UIImage imageNamed:@"earth"].CGImage options:@{GLKTextureLoaderOriginBottomLeft:@(YES)} error:nil];
    
    self.myEffect = [[GLKBaseEffect alloc] init];
    self.myEffect.texture2d0.enabled = YES;
    self.myEffect.texture2d0.name = info.name;
    self.myEffect.texture2d0.target = info.target;
    
    self.myEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(30), self.bounds.size.width / self.bounds.size.height, 1, 100);
    
    link = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.2, 0.5, 0.6, 1.0);
    glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
    
    //索引数组
    //需要根据初始位置的正背面，来确定绘制顺序（逆时针为正面）
    GLuint indices[] = {
        0, 2, 1,    //下左
        3, 2, 0,    //下右
        0, 1, 4,    //上左
        1, 2, 4,    //上前
        2, 3, 4,    //上右
        0, 4, 3,    //上后
    };
    
    [self.myEffect prepareToDraw];
    glDrawElements(GL_TRIANGLES, sizeof(indices) / sizeof(indices[0]), GL_UNSIGNED_INT, indices);
}

-(void)update{
    xDegree += 0.5f * bx;
    yDegree += 0.5f * by;
    zDegree += 0.5f * bz;
    
    GLKMatrix4 matrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, -0.4f, -5);
    matrix = GLKMatrix4Rotate(matrix, GLKMathDegreesToRadians(xDegree), 1, 0, 0);
    matrix = GLKMatrix4Rotate(matrix, GLKMathDegreesToRadians(yDegree), 0, 1, 0);
    matrix = GLKMatrix4Rotate(matrix, GLKMathDegreesToRadians(zDegree), 0, 0, 1);
    
    self.myEffect.transform.modelviewMatrix = matrix;
    
    [self display];
}

-(void)x{
    bx = !bx;
}
-(void)y{
    by = !by;
}
-(void)z{
    bz = !bz;
}
@end
