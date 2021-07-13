//
//  SimpleImageVC.m
//  HJBlurEffect
//
//  Created by 曼殊 on 2021/6/29.
//  Copyright © 2021 linggao. All rights reserved.
//

#import "SimpleImageVC.h"

@interface SimpleImageVC ()

@end

@implementation SimpleImageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupChildren];
}
- (void)setupChildren {
    CGRect mainScreenFrame = [UIScreen mainScreen].bounds;
    GPUImageView *primaryView = [[GPUImageView alloc] initWithFrame:mainScreenFrame];
    self.view  = primaryView;
    self.imageSileder = [[UISlider alloc] initWithFrame:CGRectMake(25.0, mainScreenFrame.size.height - 50.f, mainScreenFrame.size.width - 50.f, 40.f)];
    [_imageSileder addTarget:self action:@selector(updateSliderValue:) forControlEvents:UIControlEventValueChanged];
    _imageSileder.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _imageSileder.minimumValue = 0.0;
    _imageSileder.maximumValue = 1.0;
    _imageSileder.value = 0.5;
    [primaryView addSubview:_imageSileder];
    
    [self setupDisplayFiltering];
//    [self setupImageResampling];
//    [self setupImageFilteringToDisk];
}
- (void)updateSliderValue:(UISlider *)sender {
    CGFloat midpoint = [sender value];
    [(GPUImageTiltShiftFilter *)_sepiaFilter setTopFocusLevel:midpoint - 0.1];
    [(GPUImageTiltShiftFilter *)_sepiaFilter setBottomFocusLevel:midpoint + 0.1];
    [_sourcePicture processImage];
}
- (void)setupDisplayFiltering {
    UIImage *inputImage = [UIImage imageNamed:@"WID-small.jpg"];
    _sourcePicture = [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:YES];
    _sepiaFilter = [[GPUImageTiltShiftFilter alloc] init];
    GPUImageView *imageView = (GPUImageView *)self.view;
    [_sepiaFilter forceProcessingAtSize:imageView.sizeInPixels];
    [_sourcePicture addTarget:_sepiaFilter];
    [_sepiaFilter addTarget:imageView];
    [_sourcePicture processImage];
}
- (void)setupImageFilteringToDisk {
    NSURL *inputImageURL = [[NSBundle mainBundle] URLForResource:@"Lambeau" withExtension:@"jpg"];
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithURL:inputImageURL];
    GPUImageSepiaFilter *stillImageFilter = [[GPUImageSepiaFilter alloc] init];
    GPUImageVignetteFilter *vignetteImageFilter = [[GPUImageVignetteFilter alloc] init];
    vignetteImageFilter.vignetteEnd = 0.6;
    vignetteImageFilter.vignetteStart = 0.4;

    [stillImageSource addTarget:stillImageFilter];
    [stillImageFilter addTarget:vignetteImageFilter];

    [vignetteImageFilter useNextFrameForImageCapture];
    [stillImageSource processImage];

    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    @autoreleasepool {
        UIImage *currentFilteredImage = [vignetteImageFilter imageFromCurrentFramebuffer];
        
        NSData *dataForPNGFile = UIImagePNGRepresentation(currentFilteredImage);
        if (![dataForPNGFile writeToFile:[documentsDirectory stringByAppendingPathComponent:@"Lambeau-filtered1.png"] options:NSAtomicWrite error:&error])
        {
            NSLog(@"Error: Couldn't save image 1");
        }
        dataForPNGFile = nil;
        currentFilteredImage = nil;
    }

    GPUImageSepiaFilter *stillImageFilter2 = [[GPUImageSepiaFilter alloc] init];
    NSLog(@"Second image filtering");
    UIImage *inputImage = [UIImage imageNamed:@"Lambeau.jpg"];
    UIImage *quickFilteredImage = [stillImageFilter2 imageByFilteringImage:inputImage];
    NSData *dataForPNGFile2 = UIImagePNGRepresentation(quickFilteredImage);
    
    if (![dataForPNGFile2 writeToFile:[documentsDirectory stringByAppendingPathComponent:@"Lambeau-filtered2.png"] options:NSAtomicWrite error:&error]) {
        NSLog(@"Error: Couldn't save image 2");
    }
}
- (void)setupImageResampling {
    UIImage *inputImage = [UIImage imageNamed:@"Lambeau.jpg"];
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:inputImage];
    GPUImageBrightnessFilter *passthroughFilter = [[GPUImageBrightnessFilter alloc] init];
    [passthroughFilter forceProcessingAtSize:CGSizeMake(640.0, 480.0)];
    [stillImageSource addTarget:passthroughFilter];
    [passthroughFilter useNextFrameForImageCapture];
    [stillImageSource processImage];
    UIImage *nearestNeighborImage = [passthroughFilter imageFromCurrentFramebuffer];

    [stillImageSource removeAllTargets];
    GPUImageLanczosResamplingFilter *lanczosResamplingFilter = [[GPUImageLanczosResamplingFilter alloc] init];
    [lanczosResamplingFilter forceProcessingAtSize:CGSizeMake(640.0, 480.0)];
    [stillImageSource addTarget:lanczosResamplingFilter];
    [lanczosResamplingFilter useNextFrameForImageCapture];
    [stillImageSource processImage];
    UIImage *lanczosImage = [lanczosResamplingFilter imageFromCurrentFramebuffer];
    
    // Trilinear downsampling
    GPUImagePicture *stillImageSource2 = [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:YES];
    GPUImageBrightnessFilter *passthroughFilter2 = [[GPUImageBrightnessFilter alloc] init];
    [passthroughFilter2 forceProcessingAtSize:CGSizeMake(640.0, 480.0)];
    [stillImageSource2 addTarget:passthroughFilter2];
    [passthroughFilter2 useNextFrameForImageCapture];
    [stillImageSource2 processImage];
    UIImage *trilinearImage = [passthroughFilter2 imageFromCurrentFramebuffer];

    NSData *dataForPNGFile1 = UIImagePNGRepresentation(nearestNeighborImage);
    NSData *dataForPNGFile2 = UIImagePNGRepresentation(lanczosImage);
    NSData *dataForPNGFile3 = UIImagePNGRepresentation(trilinearImage);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSError *error = nil;
    if (![dataForPNGFile1 writeToFile:[documentsDirectory stringByAppendingPathComponent:@"Lambeau-Resized-NN.png"] options:NSAtomicWrite error:&error])
    {
        return;
    }

    if (![dataForPNGFile2 writeToFile:[documentsDirectory stringByAppendingPathComponent:@"Lambeau-Resized-Lanczos.png"] options:NSAtomicWrite error:&error])
    {
        return;
    }

    if (![dataForPNGFile3 writeToFile:[documentsDirectory stringByAppendingPathComponent:@"Lambeau-Resized-Trilinear.png"] options:NSAtomicWrite error:&error])
    {
        return;
    }
}

@end
