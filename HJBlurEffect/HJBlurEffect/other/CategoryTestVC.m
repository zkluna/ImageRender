//
//  CategoryTestVC.m
//  HJBlurEffect
//
//  Created by rubick on 2018/10/30.
//  Copyright © 2018 linggao. All rights reserved.
//

#import "CategoryTestVC.h"
#import "UIImage+Extend.h"

@interface CategoryTestVC ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageBottom;

@end

@implementation CategoryTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSArray *temp = @[@"旋转图片",@"裁剪图片"];
    self.title = temp[_index];
    self.slider.value = 0.0;
}
- (IBAction)sliderChangeAction:(UISlider *)sender {
    float value = sender.value;
    if(_index == 0){
        [self rotateImage:value];
    } else if(_index == 1) {
        [self cutImage:value==0?0.1:value];
    }
}
- (void)rotateImage:(float)degree {
    UIImage *image = [UIImage imageNamed:@"img1.jpg"];
    image = [image imageRotateInDegree:degree * M_PI * 2];
    self.imageView.image = image;
}
- (void)cutImage:(float)degree {
    UIImage *image = [UIImage imageNamed:@"img1.jpg"];
    CGSize imageSize = CGSizeZero;
    if(imageSize.height == 0 || imageSize.width == 0){
        imageSize = image.size;
    }
    image = [image imageCutSize:CGRectMake(0, 0, imageSize.width * degree, imageSize.height * degree)];
    self.imageRight.constant = self.view.bounds.size.width*(1-degree);
    self.imageBottom.constant = (self.view.bounds.size.height-35-64-20)-(self.view.bounds.size.width - self.imageRight.constant)*image.size.height/image.size.width;
    self.imageView.image = image;
}


@end
