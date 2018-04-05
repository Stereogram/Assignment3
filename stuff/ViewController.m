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
    float AngleX;
    float Xpos, Ypos, Zpos;
    bool ToggleRotate;
    bool stationary;
    bool ToggleSize;
    
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
    ScaleX = 1;
    ScaleY = 1;
    ToggleSize = false;
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
    
     UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector (ThreeFingerTap:)];
    doubleTapRecognizer.numberOfTapsRequired = 3;
    doubleTapRecognizer.numberOfTouchesRequired =2;
    [self.view addGestureRecognizer:doubleTapRecognizer];
    // ### >>>
}
- (IBAction)NeRotate:(id)sender {
    
    AngleX -= 25;
    NSLog(@"%f", AngleX);
}

-(IBAction)ThreeFingerTap:(UITapGestureRecognizer*)doubleTapRecognizer {
    NSLog(@"testing if this double tap gesture is working");
    stationary = !stationary;
    
    if(stationary){
        RotatePo.hidden = !RotatePo.hidden;
        RotateNe.hidden = !RotateNe.hidden;
        Rotate.hidden = !Rotate.hidden;
        ToggleScale.hidden = !ToggleScale.hidden;
        Xne.hidden = !Xne.hidden;
        Xaxis.hidden = !Xaxis.hidden;
        Xpo.hidden = !Xpo.hidden;
        
        Yne.hidden = !Yne.hidden;
        Yaxis.hidden = !Yaxis.hidden;
        Ypo.hidden = !Ypo.hidden;
        
        Zne.hidden = !Zne.hidden;
        Zaxis.hidden = !Zaxis.hidden;
        Zpo.hidden = !Zpo.hidden;
        }
    
    
}

- (IBAction)TScale:(id)sender {
    ToggleSize = !ToggleSize;
    if (ToggleSize){
        ScaleX = 3;
        ScaleY = 3;
    } else if (ToggleSize == false)
    {
        ScaleX = 1;
        ScaleY = 1;
    }
    
    
}
- (IBAction)PoRotate:(id)sender {

    AngleX += 5;
    NSLog(@"%f",AngleX);
}

- (IBAction)NeXaxis:(id)sender {
    Xpos -= 0.1;
}

- (IBAction)PoXaxis:(id)sender {
    Xpos += 0.1;
}

- (IBAction)NeYaxis:(id)sender {
    Ypos -= 0.1;
}

- (IBAction)PoYaxis:(id)sender {
    Ypos += 0.1;
}

- (IBAction)NeZaxis:(id)sender {
    Zpos -= 0.1;
}

- (IBAction)PoZaxis:(id)sender {
    Zpos += 0.1;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)update
{
    
    [glesRenderer setRotate:AngleX];
    [glesRenderer setPosition:Xpos PositionY:Ypos PositionZ:Zpos];
    [glesRenderer setScale:ScaleX ScaleY:ScaleY]; //passes SizeX and SizeY to renderer
    [glesRenderer station:stationary];
    [glesRenderer update]; // ###
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [glesRenderer draw:rect]; // ###
}





@end
