/*****************************************************************************
 *   ViewController.m
 ******************************************************************************
 *   by Kirill Kornyakov and Alexander Shishkov, 13th May 2013
 ******************************************************************************
 *   Chapter 10 of the "OpenCV for iOS" book
 *
 *   Capturing Video from Camera shows how to capture video
 *   stream from camera.
 *
 *   Copyright Packt Publishing 2013.
 *   http://bit.ly/OpenCV_for_iOS_book
 *****************************************************************************/

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>

using namespace cv;

@interface ViewController ()

@end

@implementation ViewController

@synthesize imageView;
@synthesize startCaptureButton;
@synthesize toolbar;
@synthesize videoCamera;

- (void)viewDidLoad
{
    canShoot = YES;
    score = 0;
    
    [super viewDidLoad];

    self.videoCamera = [[CvVideoCamera alloc]
                        initWithParentView:imageView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition =
    AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset =
                                AVCaptureSessionPreset640x480;
    self.videoCamera.defaultAVCaptureVideoOrientation =
                                AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    
    [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    CGSize s = self.view.frame.size;
    
    CGFloat side = 150/2;
    
    targetBox = [[UIView alloc] initWithFrame:CGRectMake((s.width/2) - (side/2), (s.height/2) - (side/2), side, side)];
    targetBox.backgroundColor = [UIColor redColor];
    targetBox.alpha = 0.3;
    
    [self.view addSubview:targetBox];
    
    isCapturing = NO;
    self.toolbar.hidden = YES;
    
    UIButton *settings = [UIButton buttonWithType:UIButtonTypeCustom];
    [settings setTitle:@"Settings" forState:UIControlStateNormal];
    [settings addTarget:self
               action:@selector(settings:)
     forControlEvents:UIControlEventTouchUpInside];
    CGFloat buttonHeight = 40;
    
    settings.frame = CGRectMake(10.0, self.view.bounds.size.height - buttonHeight, 100.0, 40.0);
//    settings.titleLabel.text = @"Settings";
//    settings.titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:settings];
    
    [self connectWebsocket];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void)settings:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    UIViewController *settingsVC = [sb instantiateViewControllerWithIdentifier:@"Settings"];
    settingsVC.title = @"Settings";
    [[self navigationController] pushViewController:settingsVC animated:YES];
    //[self presentViewController:settingsVC animated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startCaptureButtonPressed:nil];
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    NSLog(@"slider value = %f", sender.value);
}

- (NSInteger)supportedInterfaceOrientations
{
    // Only portrait orientation
    return UIInterfaceOrientationMaskPortrait;
}

-(IBAction)startCaptureButtonPressed:(id)sender
{
    [videoCamera start];
    isCapturing = YES;
}

-(IBAction)stopCaptureButtonPressed:(id)sender
{
    [videoCamera stop];
    isCapturing = NO;
}

- (float)whiteRatio:(cv::Mat&)image {
    Mat greyScale, blackWhite;
    cvtColor(image, greyScale, CV_BGR2GRAY);
    float thres = (0.25/4);
    threshold(greyScale, blackWhite, 255*thres, 255, CV_THRESH_BINARY);
    float whitePixelsCount = countNonZero(blackWhite);
    float percentWhite = whitePixelsCount/(blackWhite.rows * blackWhite.cols);
    NSLog(@"percentWhite=%f, whitePixelsCount=%f, blackWhite.rows=%d, blackWhite.cols=%d", percentWhite, whitePixelsCount, blackWhite.rows, blackWhite.cols);
    return percentWhite;
}

- (BOOL)isHit:(cv::Mat&)image {
    float _whiteRatio = [self whiteRatio:image];
    //return _whiteRatio > 0.25;
    return _whiteRatio > 0.25;
}

- (void)processImage:(cv::Mat&)image
{
    image.copyTo(currentFrame);
    
    /*
    Mat greyScale, blackWhite;
    cvtColor(image, greyScale, CV_BGR2GRAY);
    threshold(greyScale, blackWhite, 255*self.slider.value, 255, CV_THRESH_BINARY);
    float whitePixelsCount = countNonZero(blackWhite);
    float percentWhite = whitePixelsCount/(blackWhite.rows * blackWhite.cols);
    blackWhite.copyTo(image);
     */
    
//    Mat hsv;
//    Mat redColorOnly;
    
//    Scalar hsv_l(90,150,150);
//    Scalar hsv_h(150,255,255);
//    Scalar hsv_l(0,0,0);
//    Scalar hsv_h(255,255,255);
    
    //cvtColor(image,hsv,CV_BGR2HSV);
//    inRange(image,hsv_l,hsv_h,redColorOnly);
    
    //redColorOnly.copyTo(image);
    
    // Do some OpenCV processing with the image
    //NSLog(@"image: rows=%d, cols=%d", image.rows, image.cols);
    
    /*
    cv::Mat hsvImage;
    cv::cvtColor(image, hsvImage, cv::COLOR_BGR2HSV);
    NSLog(@"hsvImage: rows=%d, cols=%d", hsvImage.rows, hsvImage.cols);
    */
    
    /*
    cv::putText(image, [@"Hello" UTF8String],
                cv::Point(100, 200), cv::FONT_HERSHEY_COMPLEX,
                3.0, cv::Scalar::all(255), 4.0);
    */
    
    /*
    // greyscale
    cv::Mat greyImage;
    cv::cvtColor(image, greyImage, cv::COLOR_BGR2GRAY);
    greyImage.copyTo(image);
    */
    
    /*
    // manipulate pixels
    cv::Mat myImage;
    image.copyTo(myImage);
    for (int x = 0; x < myImage.rows; x++) {
        for (int y = 0; y < myImage.cols; y++) {
            cv::Vec3b& intensity = myImage.at<cv::Vec3b>(x, y);
            intensity.val[0] = 255; // blue
            intensity.val[1] = 0; // green
            intensity.val[2] = 0; // red
        }
    }
    myImage.copyTo(image);
    */
    
    
    /*
    cv::Vec3b intensity = image.at<cv::Vec3b>(image.cols / 2, image.rows / 2);
    uchar blue = intensity.val[0];
    uchar green = intensity.val[1];
    uchar red = intensity.val[2];
    NSLog(@"image blue=%d, green=%d, red=%d", blue, green, red);
    */
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (!canShoot) {
        return;
    }
    
    static UIImageView *iv;
    
    [self playSound:@"laser"];


    
    UITouch *t = touches.anyObject;
    CGPoint p = [t locationInView:self.view];
    
    CGFloat side = 75/2;
    // TODO: make it so the frame of the following view v fits within the bounds of the view controller view
    /*
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(p.x - (side/2), p.y - (side/2), side, side)];
    v.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:v];
    
    [UIView animateWithDuration:0.5 animations:^{
        v.alpha = 0.0;
    } completion:^(BOOL finished) {
        [v removeFromSuperview];
    }];
    */
    
    UIView * v = targetBox;
    
    CGRect fromRect = v.frame; // or whatever rectangle
    
    CGImageRef drawImage = CGImageCreateWithImageInRect(self.imageView.image.CGImage, fromRect);
    UIImage *newImage = [UIImage imageWithCGImage:drawImage];
    CGImageRelease(drawImage);
    
    CGSize viewSize = self.view.bounds.size;

    CGFloat widthRatio = currentFrame.cols / viewSize.width;
    CGFloat heightRatio = currentFrame.rows / viewSize.height;
    
    NSLog(@"widthRatio=%f, heightRatio=%f", widthRatio, heightRatio);
    
    cv::Rect r;
    r.x = v.frame.origin.x * widthRatio;
    r.y = v.frame.origin.y * heightRatio;
    r.width = v.frame.size.width * widthRatio;
    r.height = v.frame.size.height * heightRatio;
    
    
    cv::Mat subImage = currentFrame(r);
    
    if ([self isHit:subImage]) {
        [self broadcastMessage:@{@"action": @"hit"}];
    }
    
    
    
    
    //UIImage *uiSubImage = MatToUIImage(subImage);
    
//    cv::Mat hsvImage, colorImage, finalColorImage;
//    cv::cvtColor(subImage, hsvImage, cv::COLOR_BGR2HSV);
//    Scalar hsv_l(10,150,150);
//    Scalar hsv_h(179,255,255);
//    
//    inRange(hsvImage, hsv_l, hsv_h, colorImage);
    
    //cv::cvtColor(colorImage, finalColorImage, cv::COLOR_HSV2BGR);
    
    //int type = colorImage.type();
    //UIImage *uiSubImage = [self UIImageFromCVMat:subImage];
//    UIImage *uiSubImage = [self UIImageFromCVMat:colorImage];
//    
//    
//    if (!iv) {
//        iv = [[UIImageView alloc] initWithImage:uiSubImage];
//        iv.frame = self.view.frame;
//        [self.view addSubview:iv];
//    } else {
//        iv.image = uiSubImage;
//    }
    
    //iv.image = newImage;
    
//    iv.alpha = 1.0;
//    iv.hidden = NO;
//
//    
//    [UIView animateWithDuration:1.0 animations:^{
//        iv.alpha = 0.8;
//    } completion:^(BOOL finished) {
//        //[iv removeFromSuperview];
//        iv.hidden = YES;
//    }];
//    
//    
//    
//    NSLog(@"currentFrame: rows=%d, cols=%d", currentFrame.rows, currentFrame.cols);
    
}

- (void)playSound:(NSString*)name {
    static AVAudioPlayer * audioPlayer = nil;
    
    if (audioPlayer) {
        [audioPlayer stop];
    }
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                         pathForResource:name
                                         ofType:@"wav"]];
    NSError *error = nil;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [audioPlayer play];
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    //cv::cvtColor(cvMat, cvMat, CV_BGR2RGB);
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

- (void)connectWebsocket {

    self.socket = [[SocketIOClient alloc] initWithSocketURL:@"lazertag.herokuapp.com" options:@{@"log": @YES, @"forcePolling": @YES}];
    
    [self.socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"socket connected");
    }];
    
    [self.socket on:@"currentAmount" callback:^(NSArray* data, SocketAckEmitter* ack) {
        double cur = [[data objectAtIndex:0] floatValue];
        
        [self.socket emitWithAck:@"canUpdate" withItems:@[@(cur)]](0, ^(NSArray* data) {
            [self.socket emit:@"update" withItems:@[@{@"amount": @(cur + 2.50)}]];
        });
        
        [ack with:@[@"Got your currentAmount, ", @"dude"]];
    }];

    [self.socket on:@"message" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSDictionary *info = [data objectAtIndex:0];
        NSString *sender = [info valueForKey:@"sender"];
        NSLog(@"sender=%@", sender);
        NSString *action = [info valueForKey:@"action"];
        
        if ([action isEqualToString:@"hit"]) {
            if ([sender isEqualToString:[self senderId]] ) {
                score++;
                self.topLabel.text = [NSString stringWithFormat:@"%d", score];
            } else { // person hit
                canShoot = NO;
                [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timerExpired) userInfo:nil repeats:NO];
                [self playSound:@"hit"];
            }
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

            
        }
        
        /*
        [self.socket emitWithAck:@"canUpdate" withItems:@[@(cur)]](0, ^(NSArray* data) {
            [self.socket emit:@"update" withItems:@[@{@"amount": @(cur + 2.50)}]];
        });
        
        [ack with:@[@"Got your currentAmount, ", @"dude"]];
         */
    }];
    
    [self.socket connect];
    
}

- (void)timerExpired {
    canShoot = YES;
}

- (void)broadcastMessage:(NSDictionary*)data {
    NSMutableDictionary *mutableData = [NSMutableDictionary dictionaryWithDictionary:data];
    [mutableData setValue:[self senderId] forKey:@"sender"];
    [self.socket emit:@"message" withItems:@[mutableData]];
}

- (NSString*)senderId {
    return [UIDevice currentDevice].name;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (isCapturing)
    {
        [videoCamera stop];
    }
}

- (void)dealloc
{
    videoCamera.delegate = nil;
}

@end
