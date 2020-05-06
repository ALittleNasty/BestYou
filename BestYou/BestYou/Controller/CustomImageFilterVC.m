//
//  CustomImageFilterVC.m
//  BestYou
//
//  Created by 胡阳 on 2020/4/30.
//  Copyright © 2020 胡阳. All rights reserved.
//

#import "CustomImageFilterVC.h"
#import "BYUtil.h"
#import "YYFilterBar.h"

#import <GLKit/GLKit.h>
#import <Masonry/Masonry.h>

#define kFilterBarHeight 80.f

typedef struct {
    GLKVector3 positionCoord; // (X, Y, Z)
    GLKVector2 textureCoord;  // (U, V)
} YYVertexData;


@interface CustomImageFilterVC ()
// 顶点数据
@property (nonatomic, assign) YYVertexData *vertices;
// 上下文
@property (nonatomic, strong) EAGLContext *context;
// eaglLayer
@property (nonatomic, strong) CAEAGLLayer *eaglLayer;
// 用于刷新屏幕
@property (nonatomic, strong) CADisplayLink *displayLink;
// 开始的时间戳
@property (nonatomic, assign) NSTimeInterval startTimeInterval;
// 着色器程序
@property (nonatomic, assign) GLuint program;
// 顶点缓存
@property (nonatomic, assign) GLuint vertexBuffer;
// 纹理 ID
@property (nonatomic, assign) GLuint textureID;
// 滤镜工具栏
@property (nonatomic, strong) YYFilterBar *filterBar;

@property (nonatomic) GLuint offscreenFramebuffer;
@end

@implementation CustomImageFilterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
        
    [self setupFilterBar];
    [self basicSetup];
    [self startFilerAnimation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 移除 displayLink
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

// 释放资源
- (void)dealloc {
    //1.上下文释放
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    //顶点缓存区释放
    if (_vertexBuffer) {
        glDeleteBuffers(1, &_vertexBuffer);
        _vertexBuffer = 0;
    }
    //顶点数组释放
    if (_vertices) {
        free(_vertices);
        _vertices = nil;
    }
}

#pragma mark - Setup UI

- (void)setupFilterBar
{
    __weak typeof(self) ws = self;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat posY = [UIScreen mainScreen].bounds.size.height - kFilterBarHeight;
    _filterBar = [[YYFilterBar alloc] initWithFrame:CGRectMake(0, posY, width, kFilterBarHeight)];
    _filterBar.selection = ^(NSString * _Nonnull shaderName) {
        [ws filterBarTappedWithShaderName:shaderName];
    };
    [self.view addSubview:_filterBar];
}

#pragma mark - Setup

- (void)basicSetup
{
    // 1. 设置 openGL 的 context 和 CAEAGLLayer
    CAEAGLLayer *eaglLayer = [self setupOpenGL];
    if (eaglLayer == nil) {
        NSLog(@"openGL ES 相关设置失败!");
        return;
    }
    self.eaglLayer = eaglLayer;
    
    // 2. 配置顶点数据
    [self configVertexData];
    
    // 3.绑定渲染缓冲区和帧缓冲区
    [self bindBufferWithLayer:eaglLayer];
    
    // 4. 加载图片纹理 
    GLuint textureID = [self generateTextureWithImage:_image];
    if (textureID == 0) {
        NSLog(@"获取纹理失败!"); return;
    }
    self.textureID = textureID;
    
    // 5. 设置视口大小
    [self setViewport];
    
    // 6. 将顶点数据(VAO) copy 到 顶点缓冲区(VBO)
    [self copyBufferDataToGPU];
    
    // 7. 开启默认滤镜
    [self filterBarTappedWithShaderName:@"normal"];
}

/**
 *  openGL ES 相关设置
 */
- (CAEAGLLayer *)setupOpenGL
{
    // 创建上下文
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (context == nil) {
        NSLog(@"create context failed!"); return nil;
    }
    
    // 设置为当前上下文
    BOOL setContextResult = [EAGLContext setCurrentContext:context];
    if (setContextResult == NO) {
        NSLog(@"set current context failed!"); return nil;
    }
    
    self.context = context;
    
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    //导航栏高度
    CGFloat navigationHeight = (statusBarHeight + 44);
    CGFloat screentHeight = [UIScreen mainScreen].bounds.size.height;
    // 创建 CAEAGLLayer, 设置 context 属性以及 内容比例, 添加到 self.view.layer 上
    CAEAGLLayer *eaglLayer = [[CAEAGLLayer alloc] init];
    eaglLayer.frame = CGRectMake(0.0, navigationHeight, self.view.bounds.size.width, screentHeight - kFilterBarHeight - navigationHeight);
    eaglLayer.contents = context;
    eaglLayer.contentsScale = [[UIScreen mainScreen] scale];
    [self.view.layer addSublayer:eaglLayer];
    
    return eaglLayer;
}

/**
 * program 相关设置
 */
- (void)setupProgramWithShaderName:(NSString *)shaderName
{
    // 获取 program
    GLuint program = [self generateProgramWithShaderName:shaderName];
    if (program == 0) {
        NSLog(@"create program failed");
        return;
    }
    self.program = program;
    
    // 使用 program
    glUseProgram(self.program);
    
    // 获取  attribute 的 position 通道位置
    GLuint positionLocation = glGetAttribLocation(self.program, "position");
    // 打开  attribute 的 position 通道
    glEnableVertexAttribArray(positionLocation);
    // 设置  attribute 的 position 数据的读取方式
    glVertexAttribPointer(positionLocation, 3, GL_FLOAT, GL_FALSE, sizeof(YYVertexData), NULL + offsetof(YYVertexData, positionCoord));
    
    // 获取  attribute 的 textureCoordinate 通道位置
    GLuint textureCoordinateLocation = glGetAttribLocation(self.program, "textureCoordinate");
    // 打开  attribute 的 textureCoordinate 通道
    glEnableVertexAttribArray(textureCoordinateLocation);
    // 设置  attribute 的 textureCoordinate 数据的读取方式
    glVertexAttribPointer(textureCoordinateLocation, 2, GL_FLOAT, GL_FALSE, sizeof(YYVertexData), NULL + offsetof(YYVertexData, textureCoord));
    
    // 获取  uniform 的 inputTexture 通道位置
    GLuint textureLocation = glGetUniformLocation(self.program, "inputTexture");
    // 激活纹理
    glActiveTexture(GL_TEXTURE_2D);
    // 绑定纹理
    glBindTexture(GL_TEXTURE_2D, self.textureID);
    // 将第一个纹理(索引为 0)数据通过 uniform 传递
    glUniform1i(textureLocation, 0);
}

/**
 * 根据 shader 名称生成 program
 */
- (GLuint)generateProgramWithShaderName:(NSString *)shaderName
{
    // 获取顶点着色器, 片元着色器
    GLuint vertexShader = [self compileShaderWithName:shaderName type:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShaderWithName:shaderName type:GL_FRAGMENT_SHADER];
    if (vertexShader == 0 || fragmentShader == 0) {
        NSLog(@"获取 shader 失败!");
        return 0;
    }
    
    // 创建 program
    GLuint program = glCreateProgram();
    
    // 将着色器附着到 program
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    
    // 链接 program
    glLinkProgram(program);
    
    // 获取链接状态, 如有必要打印链接失败错误日志信息
    GLint linkStatus;
    glGetProgramiv(program, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        GLchar messages[512];
        glGetProgramInfoLog(program, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"link program failed：%@", messageString);
        return 0;
    }
    
    return program;
}

/**
 * 编译shader代码
 */
- (GLuint)compileShaderWithName:(NSString *)name type:(GLenum)shaderType
{
    // 获取着色器文件路径
    NSString *shaderTypeStr = shaderType == GL_VERTEX_SHADER ? @"vsh" : @"fsh";
    NSString *shaderPath = [[NSBundle mainBundle] pathForResource:name ofType:shaderTypeStr];
    
    // 读取着色器程序
    NSError *error;
    NSString *content = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"read shader content failed! %@", error);
        return 0;
    }
    
    // 将着色器程序 NSString* 转为 char *
    const char *shaderStringUTF8 = [content UTF8String];
    
    // 获取 shader source
    GLuint shader = glCreateShader(shaderType);
    GLint length = (GLint)content.length;
    glShaderSource(shader, 1, &shaderStringUTF8, &length);
    
    // 编译 shader
    glCompileShader(shader);
    
    // 获取编译状态, 如有必要打印错误日志信息
    GLint compileStatus;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileStatus);
    if (compileStatus == GL_FALSE) {
        GLchar messages[512];
        glGetShaderInfoLog(shader, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"shader编译失败：%@", messageString);
        return 0;
    }
    
    return shader;
}

/**
 * 将顶点数据从 cpu copy 到 gpu
 */
- (void)copyBufferDataToGPU
{
    // 设置顶点缓冲区 VBO
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    GLsizeiptr bufferSize = sizeof(YYVertexData) * 4;
    // 把 VAO 拷贝至 VBO
    glBufferData(GL_ARRAY_BUFFER, bufferSize, self.vertices, GL_STATIC_DRAW);
    
    self.vertexBuffer = vertexBuffer;
}

/**
 * 绑定渲染缓存区和帧缓存区
 */
- (void)configVertexData
{
    // 开辟内存空间
    self.vertices = malloc(sizeof(YYVertexData) * 4);
    
    // 给 4 个顶点赋值
    self.vertices[0] = (YYVertexData){{-1.0, 1.0, 0.0}, {0.0, 1.0}};
    self.vertices[1] = (YYVertexData){{-1.0, -1.0, 0.0}, {0.0, 0.0}};
    self.vertices[2] = (YYVertexData){{1.0, 1.0, 0.0}, {1.0, 1.0}};
    self.vertices[3] = (YYVertexData){{1.0, -1.0, 0.0}, {1.0, 0.0}};
}

/**
 * 绑定渲染缓存区和帧缓存区
 */
- (void)bindBufferWithLayer:(CALayer <EAGLDrawable> *)layer
{
    // 声明渲染缓存区和帧缓存区
    GLuint renderBuffer, frameBuffer;
    
    // 创建渲染缓存区,并绑定
    glGenRenderbuffers(1, &renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    
    // 创建帧缓存区, 并绑定渲染缓存区和帧缓存区
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuffer);
}

/**
 * 设置视口大小
 */
- (void)setViewport
{
    // 从渲染缓冲区获取宽,高
    GLint backingWidth, backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    // 设置视口大小
    glViewport(0, 0, backingWidth, backingHeight );
}

/**
 * 从图片中加载纹理, 并返回纹理 ID
 */
- (GLuint)generateTextureWithImage:(UIImage *)image
{
    // 将 UIImage 转为 CGImageRef
    CGImageRef imgRef = image.CGImage;
    if (!imgRef) {
        NSLog(@"load CGImageRef failed!"); return 0;
    }
    
    // 获取图片的宽高
    size_t width = CGImageGetWidth(imgRef);
    size_t height = CGImageGetHeight(imgRef);
    
    // 计算图片大小
    GLubyte *imgBytes = calloc(width * height * 4, sizeof(GLubyte));
    
    // 创建位图绘制上下文
    /*
    参数1：data,指向要渲染的绘制图像的内存地址
    参数2：width,bitmap的宽度，单位为像素
    参数3：height,bitmap的高度，单位为像素
    参数4：bitPerComponent,内存中像素的每个组件的位数，比如32位RGBA，就设置为8
    参数5：bytesPerRow,bitmap的没一行的内存所占的比特数
    参数6：colorSpace,bitmap上使用的颜色空间  kCGImageAlphaPremultipliedLast：RGBA
    */
    CGContextRef contextRef = CGBitmapContextCreate(imgBytes, width, height, 8, width * 4, CGImageGetColorSpace(imgRef), kCGImageAlphaPremultipliedLast);
    
    // 设置绘图的大小
    CGRect rect = CGRectMake(0, 0, width, height);
    
    // 翻转图形(Y 轴上下翻转)
    CGContextSetTextMatrix(contextRef, CGAffineTransformIdentity);
    CGContextTranslateCTM(contextRef, 0, rect.size.height);
    CGContextScaleCTM(contextRef, 1.0, -1.0);
    
    // 绘图
    CGContextDrawImage(contextRef, rect, imgRef);
    
    // 释放上下文资源
    CGContextRelease(contextRef);
    
    // 激活纹理 0, 生成纹理 0 的 ID, 并且进行绑定
    GLuint textureID;
    glActiveTexture(GL_TEXTURE0);
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
    
    // 设置放大缩小过滤模式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    // 设置环绕方式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    // 载入纹理2D数据
    /*
    参数1：纹理模式，GL_TEXTURE_1D、GL_TEXTURE_2D、GL_TEXTURE_3D
    参数2：加载的层次，一般设置为0
    参数3：纹理的颜色值GL_RGBA
    参数4：宽
    参数5：高
    参数6：border，边界宽度
    参数7：format
    参数8：type
    参数9：纹理数据
    */
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (float)width, (float)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imgBytes);
    
    // 释放图片数据
    free(imgBytes);
    
    return textureID;
}

#pragma mark - Filter Animation

/**
 * 开始一个滤镜动画
 */
- (void)startFilerAnimation
{
    //1.判断displayLink 是否为空
    //CADisplayLink 定时器
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
    //2. 设置displayLink 的方法
    self.startTimeInterval = 0;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(refresh)];
    
    //3.将 displayLink 添加到 runloop 运行循环
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

//2. 动画
- (void)refresh
{
    //DisplayLink 的当前时间撮
    if (self.startTimeInterval == 0) {
        self.startTimeInterval = self.displayLink.timestamp;
    }
    //使用program
    glUseProgram(self.program);
    //绑定buffer
    glBindBuffer(GL_ARRAY_BUFFER, self.vertexBuffer);
    
    // 传入时间
    CGFloat currentTime = self.displayLink.timestamp - self.startTimeInterval;
    GLuint time = glGetUniformLocation(self.program, "time");
    glUniform1f(time, currentTime);
    
    // 清除画布
    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(1.0, 1.0, 1.0, 1.0);
    
    // 重绘
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    //渲染到屏幕上
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark - Action

- (void)filterBarTappedWithShaderName:(NSString *)shaderName
{
    // 根据 shader 名称设置 program
    [self setupProgramWithShaderName:shaderName];
}

#pragma mark - Save Image

- (void)createOffscreenBuffer:(UIImage *)image
{
    glGenFramebuffers(1, &_offscreenFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _offscreenFramebuffer);
    
    //Create the texture
    GLuint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,  image.size.width, image.size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    //Bind the texture to your FBO
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture, 0);
    
    //Test if everything failed
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if(status != GL_FRAMEBUFFER_COMPLETE) {
        printf("failed to make complete framebuffer object %x", status);
    }
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glBindTexture(GL_TEXTURE_2D, 0);
}


/*

 参考叶孤城的文章: https://zhuanlan.zhihu.com/p/32194345
 
- (void)getCurrentImage
{
    glBindFramebuffer(GL_FRAMEBUFFER, _offscreenFramebuffer);
    glViewport(0, 0, _image.size.width, _image.size.height);
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    [shaderCompiler prepareToDraw];

    glUniform1f(_brightness, _brightSlider.value);
    [self activeTexture];

    [self drawRaw];
    
    [self getImageFromBuffe:width withHeight:height];
}

- (void)getImageFromBuffe:(int)width withHeight:(int)height {
    GLint x = 0, y = 0;
    NSInteger dataLength = width * height * 4;
    GLubyte *data = (GLubyte*)malloc(dataLength * sizeof(GLubyte));
    
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGImageRef iref = CGImageCreate(width, height, 8, 32, width * 4, colorspace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast,
                                    ref, NULL, true, kCGRenderingIntentDefault);
    
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef cgcontext = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
    CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, width, height), iref);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    free(data);
    CFRelease(ref);
    CFRelease(colorspace);
    CGImageRelease(iref);
    
    [BYUtil saveImage:image];
}
*/
@end
