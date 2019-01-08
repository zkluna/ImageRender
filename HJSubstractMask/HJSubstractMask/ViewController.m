//
//  ViewController.m
//  HJSubstractMask
//
//  Created by rubick on 2018/12/4.
//  Copyright © 2018 LG. All rights reserved.
//

#import "ViewController.h"
#import "UIView+hjSubtractMask.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *visualEffectContainer;
@property (weak, nonatomic) IBOutlet UIView *blackView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (IBAction)scaleAction:(id)sender {
    [UIView animateWithDuration:0.5 animations:^{
        self.blackView.subtractMaskView.transform = CGAffineTransformMakeScale(2, 2);
        self.visualEffectContainer.subtractMaskView.transform = CGAffineTransformMakeScale(2, 2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            self.blackView.subtractMaskView.transform = CGAffineTransformIdentity;
            self.visualEffectContainer.subtractMaskView.transform = CGAffineTransformIdentity;
        }];
    }];
}
- (IBAction)tractImageAction:(id)sender {
    UIImageView *imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pikaqiu"]];
    imageV.frame = CGRectMake(30, 20, 100, 95);
    self.blackView.subtractMaskView = imageV;
    self.visualEffectContainer.subtractMaskView = imageV;
}
- (IBAction)tractTextAction:(id)sender {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 240, 128)];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:24];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"HJSubtractMask";
    self.blackView.subtractMaskView = label;
    self.visualEffectContainer.subtractMaskView = label;
}


@end
