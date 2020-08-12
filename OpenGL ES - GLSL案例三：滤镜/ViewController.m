//
//  ViewController.m
//  OpenGL ES - GLSL案例三：滤镜
//
//  Created by Henry on 2020/8/11.
//  Copyright © 2020 Henry. All rights reserved.
//

#import "ViewController.h"
#import <OpenGLES/ES3/gl.h>
#import <GLKit/GLKit.h>
#import "FilterBar.h"
typedef struct {
    GLKVector3 position;
    GLKVector2 texture;
}HyVertice;

@interface ViewController () <FilterBarDelegate>

@property(nonatomic,strong)EAGLContext *myConten;

@property(nonatomic,assign)GLuint myProgarm;
@property(nonatomic,assign)GLuint myVertexID;
@property(nonatomic,assign)GLuint myTextureID;
@property(nonatomic,assign)HyVertice *vertices;

@property(nonatomic,assign)GLuint myRenderBuffer;
@property(nonatomic,assign)GLuint myFrameBuffer;
@end

@implementation ViewController
{
    CADisplayLink *link;
    
    // 开始的时间戳
    NSTimeInterval startTimeInterval;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self setupInit];
    [self setupFilterBar];
    
    [self setupShaderProgramWithName:@"SplitScreen_0"];
    
    link = [CADisplayLink displayLinkWithTarget:self selector:@selector(timeAction)];
    [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

// 创建滤镜栏
-(void)setupFilterBar {
    CGFloat filterBarWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat filterBarHeight = 100;
    CGFloat filterBarY = [UIScreen mainScreen].bounds.size.height - filterBarHeight;
    FilterBar *filerBar = [[FilterBar alloc] initWithFrame:CGRectMake(0, filterBarY, filterBarWidth, filterBarHeight)];
    filerBar.delegate = self;
    [self.view addSubview:filerBar];
    
    NSArray *dataSource = @[@"无",@"分屏_2",@"分屏_3",@"分屏_4",@"分屏_5",@"分屏_6",@"分屏_9",@"灰度滤镜_1",@"灰度滤镜_2",@"翻转",@"翻转动画",@"马赛克_1"];
    filerBar.itemList = dataSource;
}

#pragma mark - FilterBarDelegate
- (void)filterBar:(FilterBar *)filterBar didScrollToIndex:(NSUInteger)index {
    //1. 选择默认shader
    if (index == 0) {
        [self setupShaderProgramWithName:@"SplitScreen_0"];
    }else if(index == 1)
    {
        [self setupShaderProgramWithName:@"SplitScreen_2"];
    }else if(index == 2)
    {
        [self setupShaderProgramWithName:@"SplitScreen_3"];
    }else if(index == 3)
    {
        [self setupShaderProgramWithName:@"SplitScreen_4"];
    }else if(index == 4)
    {
        [self setupShaderProgramWithName:@"SplitScreen_5"];
    }else if(index == 5)
    {
        [self setupShaderProgramWithName:@"SplitScreen_6"];
    }else if(index == 6)
    {
        [self setupShaderProgramWithName:@"SplitScreen_9"];
    }else if(index == 7)
    {
        [self setupShaderProgramWithName:@"gray_1"];
    }else if(index == 8)
    {
        [self setupShaderProgramWithName:@"gray_2"];
    }else if(index == 9)
    {
        [self setupShaderProgramWithName:@"reversal"];
    }else if(index == 10){
        [self setupShaderProgramWithNameAnimation:@"reversal_2"];
    }else if(index == 11){
        [self setupShaderProgramWithName:@"mosaic"];
    }
}

-(void)setupInit {
    self.myConten = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if(![EAGLContext setCurrentContext:self.myConten]){
        exit(1);
    }
    
    CAEAGLLayer *layer = [[CAEAGLLayer alloc] init];
    layer.frame = CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
    layer.opaque = YES;
    layer.drawableProperties = @{
        kEAGLDrawablePropertyRetainedBacking:@(false),
        kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8
    };
    layer.contentsScale = [[UIScreen mainScreen] scale];
    [self.view.layer addSublayer:layer];
    
    glGenRenderbuffers(1, &_myRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, self.myRenderBuffer);
    [self.myConten renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    
    glGenFramebuffers(1, &_myFrameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, self.myFrameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.myRenderBuffer);
    
    //设置视口大小
    glViewport(0, 0, [self drawableWidth], [self drawableHeight]);
    
    self.myVertexID = [self loadVertexs];
    
    self.myTextureID = [self loadImage];
}

-(GLuint)loadVertexs{
    GLuint vertex;
    
    self.vertices = malloc(sizeof(HyVertice) * 4);
    self.vertices[0] = (HyVertice){{-1, 1, 0}, {0, 1}};
    self.vertices[1] = (HyVertice){{-1, -1, 0}, {0, 0}};
    self.vertices[2] = (HyVertice){{1, 1, 0}, {1, 1}};
    self.vertices[3] = (HyVertice){{1, -1, 0}, {1, 0}};
    
    glGenBuffers(1, &vertex);
    glBindBuffer(GL_ARRAY_BUFFER, vertex);
    glBufferData(GL_ARRAY_BUFFER, sizeof(HyVertice) * 4, self.vertices, GL_DYNAMIC_DRAW);
    return vertex;
}

-(GLuint)loadImage {
    CGImageRef ref = [UIImage imageNamed:@"cat"].CGImage;
    GLsizei width = (GLsizei)CGImageGetWidth(ref);
    GLsizei height = (GLsizei)CGImageGetHeight(ref);
    //直接使用设备的RGB颜色空间
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    
    GLubyte *spritData = malloc(width * height * 4);
    CGContextRef contentRef = CGBitmapContextCreate(spritData, width, height, 8, width * 4, space, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    if (!contentRef){exit(1);}
    //翻转
    CGContextTranslateCTM(contentRef, 0, height);
    CGContextScaleCTM(contentRef, 1.0, -1.0);
    
    CGColorSpaceRelease(space);
    //对contentRef的画布进行清理
    CGContextClearRect(contentRef, CGRectMake(0, 0, width, height));
    //image重新绘制
    CGContextDrawImage(contentRef, CGRectMake(0, 0, width, height), ref);
    //绘制完成释放content
    CGContextRelease(contentRef);
    
    GLuint texture;
    glGenTextures(1, &texture);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spritData);

    free(spritData);
    return texture;
}

// 初始化着色器程序
- (void)setupShaderProgramWithName:(NSString *)name {
    [link setPaused:YES];
    
    glClearColor(1, 0.5, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self sutupShader:name];
    glUseProgram(self.myProgarm);
    
    glBindBuffer(GL_ARRAY_BUFFER, self.myVertexID);
    GLuint position = glGetAttribLocation(self.myProgarm, "position");
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(HyVertice), NULL + offsetof(HyVertice, position));
    GLuint texCoord = glGetAttribLocation(self.myProgarm, "texCoord");
    glEnableVertexAttribArray(texCoord);
    glVertexAttribPointer(texCoord, 2, GL_FLOAT, GL_FALSE, sizeof(HyVertice), NULL + offsetof(HyVertice, texture));
    
    //激活纹理,绑定纹理ID
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.myTextureID);
    GLuint colorMap = glGetUniformLocation(self.myProgarm, "colorMap");
    glUniform1i(colorMap, 0);
    
    GLuint size = glGetUniformLocation(self.myProgarm, "size");
    glUniform2f(size,
                [[NSString stringWithFormat:@"%d",[self drawableWidth]] floatValue],
                [[NSString stringWithFormat:@"%d",[self drawableHeight]] floatValue]);
//    glUniform2i(size, [self drawableWidth], [self drawableHeight]);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    [self.myConten presentRenderbuffer:GL_RENDERBUFFER];
}

// 初始化着色器程序
- (void)setupShaderProgramWithNameAnimation:(NSString *)name {
    [link setPaused:NO];
    
    [self sutupShader:name];
    
    GLuint position = glGetAttribLocation(self.myProgarm, "position");
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(HyVertice), NULL + offsetof(HyVertice, position));
    GLuint texCoord = glGetAttribLocation(self.myProgarm, "texCoord");
    glEnableVertexAttribArray(texCoord);
    glVertexAttribPointer(texCoord, 2, GL_FLOAT, GL_FALSE, sizeof(HyVertice), NULL + offsetof(HyVertice, texture));
    
    GLuint colorMap = glGetUniformLocation(self.myProgarm, "colorMap");
    glUniform1i(colorMap, 0);
    
    GLuint size = glGetUniformLocation(self.myProgarm, "size");
    glUniform2i(size, [self drawableWidth], [self drawableHeight]);
    
    startTimeInterval = 0;
}

-(void)timeAction{
    glClearColor(1, 0.5, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    if (startTimeInterval == 0) {
        startTimeInterval = link.timestamp;
    }
    
    glUseProgram(self.myProgarm);
    
    glBindBuffer(GL_ARRAY_BUFFER, self.myVertexID);
    //激活纹理,绑定纹理ID
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.myTextureID);
    
    GLuint colorMap = glGetUniformLocation(self.myProgarm, "Time");
    glUniform1f(colorMap, link.timestamp - startTimeInterval);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    [self.myConten presentRenderbuffer:GL_RENDERBUFFER];
}

//着色器编译
-(void)sutupShader:(NSString*)name{
    GLuint vShader,fShader;
    NSString *vPath = [[NSBundle bundleForClass:[self class]] pathForResource:name ofType:@"vsh"];
    NSString *fPath = [[NSBundle bundleForClass:[self class]] pathForResource:name ofType:@"fsh"];
    
    [self compiler:&vShader type:GL_VERTEX_SHADER path:vPath];
    [self compiler:&fShader type:GL_FRAGMENT_SHADER path:fPath];
    
    self.myProgarm = glCreateProgram();
    glAttachShader(self.myProgarm, vShader);
    glAttachShader(self.myProgarm, fShader);
    glDeleteShader(vShader);
    glDeleteShader(fShader);
    glLinkProgram(self.myProgarm);
    
    GLint status;
    glGetProgramiv(self.myProgarm, GL_LINK_STATUS, &status);
    if(status == GL_FALSE){
        GLchar info[256];
        glGetProgramInfoLog(self.myProgarm, sizeof(info), 0, &info[0]);
        NSString *message = [NSString stringWithUTF8String:info];
        NSLog(@"%@--%@",name,message);
        return;
    }
}
-(void)compiler:(GLuint *)shader type:(GLenum)type path:(NSString*)path{
    NSString *sSource = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    const GLchar *source = [sSource UTF8String];
    
    *shader = glCreateShader(type);
    
    GLint legth = (int)[sSource length];
    glShaderSource(*shader, 1, &source, &legth);
    glCompileShader(*shader);
}



-(GLint)drawableWidth{
    GLint width;
    //获取渲染缓存区大小
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    return width;
}

-(GLint)drawableHeight{
    GLint height;
    //获取渲染缓存区大小
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    return height;
}
@end
