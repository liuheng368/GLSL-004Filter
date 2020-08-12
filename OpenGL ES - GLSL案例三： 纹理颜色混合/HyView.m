//
//  HyView.m
//  OpenGL ES - GLSL案例三： 纹理颜色混合
//
//  Created by Henry on 2020/8/9.
//  Copyright © 2020 刘恒. All rights reserved.
//

#import "HyView.h"
#import <OpenGLES/ES3/gl.h>
#import <GLKit/GLKMath.h>

@interface HyView()

@property(nonatomic,strong)EAGLContext *myContent;
@property(nonatomic,strong)CAEAGLLayer *myLayer;

@property(nonatomic,assign)GLuint myRenderBuffer;
@property(nonatomic,assign)GLuint myFrameBuffer;
@property(nonatomic,assign)GLuint myProgram;

@end

@implementation HyView
{
    BOOL bx;
    BOOL by;
    BOOL bz;
    
    CGFloat xDegree;
    CGFloat yDegree;
    CGFloat zDegree;
    
    dispatch_source_t timer;
}

- (void)layoutSubviews{
    [self setupLayer];
    
    [self setupContent];
    
    [self cleanBuffer];
    
    [self setupRender];
    
    [self setupFrame];
    
    [self setupShader];
    
    [self render];
    
    if(!timer){
        double seconds = 0.1;
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC, 0.0);
        dispatch_source_set_event_handler(timer, ^{
            self->xDegree += 0.5f * self->bx;
            self->yDegree += 0.5f * self->by;
            self->zDegree += 0.5f * self->bz;
            [self render];
        });
        dispatch_resume(timer);
    }
}

//1
+ (Class)layerClass{
    return [CAEAGLLayer class];
}

-(void)setupLayer{
    self.myLayer = (CAEAGLLayer *)self.layer;
    [self.myLayer setContentsScale:[[UIScreen mainScreen] scale]];
    self.myLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking:
                                            @(false),
                                        kEAGLDrawablePropertyColorFormat:
                                            kEAGLColorFormatRGBA8
    };
    self.myLayer.opaque = YES;
}

//2
-(void)setupContent{
    self.myContent = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!self.myContent){
        exit(1);
    }
    if(![EAGLContext setCurrentContext:self.myContent ]){
        exit(1);
    }
}

//3
-(void)cleanBuffer{
    glDeleteRenderbuffers(1, &_myRenderBuffer);
    glDeleteFramebuffers(1, &_myFrameBuffer);
    self.myRenderBuffer = 0;
    self.myFrameBuffer = 0;
}

//4
-(void)setupRender{
    GLuint render;
    glGenRenderbuffers(1, &render);
    glBindRenderbuffer(GL_RENDERBUFFER, render);
    if(render == GL_FALSE){
        exit(1);
    }
    self.myRenderBuffer = render;
    [self.myContent renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myLayer];
    
}

//5
-(void)setupFrame{
    GLuint frame;
    glGenFramebuffers(1, &frame);
    glBindFramebuffer(GL_FRAMEBUFFER, frame);
    if (frame == GL_FALSE){
        exit(1);
    }
    self.myFrameBuffer = frame;
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.myRenderBuffer);
}

//6
-(void)setupShader{
    GLuint vShader,fShader;
    
    NSString *vPath = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"glsl"];
    NSString *fPath = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"glsl"];
    
    [self compile:&vShader type:GL_VERTEX_SHADER path:vPath];
    [self compile:&fShader type:GL_FRAGMENT_SHADER path:fPath];
    
    self.myProgram = glCreateProgram();
    if(self.myProgram == GL_FALSE){
        exit(1);
    }
    
    glAttachShader(self.myProgram, vShader);
    glAttachShader(self.myProgram, fShader);
    glDeleteShader(vShader);
    glDeleteShader(fShader);
    
    glLinkProgram(self.myProgram);
    
    GLint status;
    glGetProgramiv(self.myProgram, GL_LINK_STATUS, &status);
    if (status == GL_FALSE){
        GLchar info[256];
        glGetProgramInfoLog(self.myProgram, sizeof(info), 0, &info[0]);
        NSString *message = [NSString stringWithUTF8String:info];
        NSLog(@"%@",message);
        return;
    }
    NSLog(@"link success");
    
    glUseProgram(self.myProgram);
}

-(void)compile:(GLuint *)shader type:(GLenum)type path:(NSString*)path{
    const GLchar *source = [[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] UTF8String];
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    if(shader == GL_FALSE){
        exit(1);
    }
    glCompileShader(*shader);
}

//7
-(void)render{
    glClearColor(0.2, 0.2, 0.6, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glEnable(GL_CULL_FACE);
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    glViewport(self.frame.origin.x * scale,
               self.frame.origin.y * scale,
               self.frame.size.width * scale,
               self.frame.size.height * scale);
    
    //顶点数组, 前3位顶点， 后3位颜色（RGB，A默认为1.0）
    GLfloat vertex[] = {
        -0.5f, 0.0f, -0.5f, 0, 1, 1.0f,0.0f,0.0f, //左上
        -0.5f, 0.0f,  0.5f, 0, 0, 1.0f,0.5f,0.0f, //左下
         0.5f, 0.0f,  0.5f, 1, 0, 0.5f,0.5f,0.5f, //右下
         0.5f, 0.0f, -0.5f, 1, 1, 0.0f,0.5f,1.0f, //右上
         0.0f, 1.0f,  0.0f, 0.5, 0.5, 1.0f,1.0f,1.0f,  //顶点
    };
    
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
    
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertex), &vertex, GL_DYNAMIC_DRAW);
    
    GLuint position = glGetAttribLocation(self.myProgram, "position");
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat*)NULL + 0);
    
    GLuint texCoord = glGetAttribLocation(self.myProgram, "textureCoord");
    glEnableVertexAttribArray(texCoord);
    glVertexAttribPointer(texCoord, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat*)NULL + 3);
    
    GLuint positionColor = glGetAttribLocation(self.myProgram, "positionColor");
    glEnableVertexAttribArray(positionColor);
    glVertexAttribPointer(positionColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat*)NULL + 5);
    
    
    GLKMatrix4 projectingM = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(30), self.frame.size.width / self.frame.size.height, 1, 100);
    GLKMatrix4 viewModelM = GLKMatrix4Translate(GLKMatrix4Identity, 0, 0, -5);
    viewModelM = GLKMatrix4RotateX(viewModelM, GLKMathDegreesToRadians(xDegree));
    viewModelM = GLKMatrix4RotateY(viewModelM, GLKMathDegreesToRadians(yDegree));
    viewModelM = GLKMatrix4RotateZ(viewModelM, GLKMathDegreesToRadians(zDegree));
    
    GLuint pro = glGetUniformLocation(self.myProgram, "projectionMatrix");
    glUniformMatrix4fv(pro, 1, GL_FALSE, &projectingM.m00);
    GLuint vm = glGetUniformLocation(self.myProgram, "viewModelMatrix");
    glUniformMatrix4fv(vm, 1, GL_FALSE, &viewModelM.m00);
    
    
    GLuint texture = [self loadImage];
    glActiveTexture(texture);
    glUniform1i(glGetUniformLocation(self.myProgram, "colorMap"), 0);
    
    
    glUniform1f(glGetUniformLocation(self.myProgram, "alpha"), 0.3);
    
    
    glDrawElements(GL_TRIANGLES, sizeof(indices) / sizeof(indices[0]), GL_UNSIGNED_INT, indices);
    
    [self.myContent presentRenderbuffer:GL_RENDERBUFFER];
}

-(GLuint)loadImage{
    CGImageRef ref = [UIImage imageNamed:@"earth"].CGImage;
    
    CGFloat width = CGImageGetWidth(ref);
    CGFloat height = CGImageGetWidth(ref);
    CGColorSpaceRef space = CGImageGetColorSpace(ref);
    
    GLubyte *imageData = calloc(width * height * 4, sizeof(GLubyte));
    
    CGContextRef content = CGBitmapContextCreate(imageData, width, height, 8, width * 4, space, kCGImageAlphaPremultipliedLast);
    
    CGContextTranslateCTM(content, 0, height);
    CGContextScaleCTM(content, 1.0, -1.0);
    
    CGContextDrawImage(content, CGRectMake(0, 0, width, height), ref);
    CGContextRelease(content);
    
    GLuint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    free(imageData);
    return texture;
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
