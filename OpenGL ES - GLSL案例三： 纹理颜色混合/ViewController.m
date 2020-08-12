//
//  ViewController.m
//  OpenGL ES - GLSL案例二：索引绘图
//
//  Created by Henry on 2020/8/8.
//  Copyright © 2020 刘恒. All rights reserved.
//

#import "ViewController.h"
#import "HyView.h"
#import "HyGLKView.h"
@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIView *vv;

@end

@implementation ViewController
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)glslTexture:(id)sender {
    [self.vv.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.vv addSubview:[[HyView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x,
                                                                   self.view.frame.origin.y,
                                                                   self.view.frame.size.width,
                                                                   self.view.frame.size.height / 2)]];
}

- (IBAction)GLKit:(id)sender {
    
    [self.vv.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.vv addSubview:[[HyGLKView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x,
                                                                   self.view.frame.origin.y,
                                                                   self.view.frame.size.width,
                                                                   self.view.frame.size.height / 2)]];
}

- (IBAction)x:(id)sender {
    [self.vv.subviews.firstObject performSelector:@selector(x)];
}

- (IBAction)y:(id)sender {
    [self.vv.subviews.firstObject performSelector:@selector(y)];
}

- (IBAction)z:(id)sender {
    [self.vv.subviews.firstObject performSelector:@selector(z)];
}

@end
