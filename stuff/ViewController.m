//
//  ViewController.m
//  c8051intro3
//
//  Created by Borna Noureddin on 2017-12-20.
//  Copyright © 2017 Borna Noureddin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController() {
    Renderer *glesRenderer; // ###
    CGPoint start;
    float ScaleX, ScaleY;
    float AngleX, AngleY;
    bool ToggleRotate;
    bool stationary;
    bool ToggleSize;
    IBOutlet UIButton *btn1;
    IBOutlet UIButton *btn2;
}
@end


@implementation ViewController

- (IBAction)handleTap:(UITapGestureRecognizer *)tap
{
    [glesRenderer reset];
}

- (IBAction)handlePan:(UIPanGestureRecognizer* )sender
{
    CGPoint vel = [sender velocityInView:self.view];
    [glesRenderer move:CGPointMake(vel.x/500.0f, vel.y/500.0f)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    stationary = false;
    // Do any additional setup after loading the view, typically from a nib.
    // ### <<<
    glesRenderer = [[Renderer alloc] init];
    GLKView *view = (GLKView *)self.view;
    [glesRenderer setup:view];
    ToggleSize = 0;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tap];

    
    UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.minimumNumberOfTouches = 1;
    [self.view addGestureRecognizer:pan];
    
     UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector (ThreeFingerTap:)];
    tap.numberOfTapsRequired = 3;
    // ### >>>
}

-(void)ThreeFingerTap:(UITapGestureRecognizer*)sender {
    NSLog(@"testing if this double tap gesture is working");
    stationary = !stationary;
    
    if(stationary){
        btn1.hidden = !btn1.hidden;
        btn2.hidden = !btn2.hidden;
        
    }
    
    
}

- (IBAction)ToggleScale:(id)sender {
    ToggleSize = !ToggleSize;
    if (ToggleSize){
        ScaleX = 30;
        ScaleY = 30;
        
    } else if (ToggleSize == false)
    {
        ScaleX = 10;
        ScaleY = 10;
        
    }
    
    
}
- (IBAction)ToggleRotate:(id)sender {
    ToggleRotate = !ToggleRotate;
    if(ToggleRotate){
        
        
    } else if (!ToggleRotate){
        
        
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)update
{
    [glesRenderer setScale:ScaleX ScaleY:ScaleY]; //passes SizeX and SizeY to renderer
    [glesRenderer update]; // ###
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [glesRenderer draw:rect]; // ###
}


@end
