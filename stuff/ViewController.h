//
//  ViewController.h
//  c8051intro3
//
//  Created by Borna Noureddin on 2017-12-20.
//  Copyright © 2017 Borna Noureddin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Renderer.h" // ###

//@interface ViewController : UIViewController
@interface ViewController : GLKViewController // ###
{
    
    IBOutlet UIButton *RotatePo; //Rotate + button
    IBOutlet UIButton *Rotate; // Rotate Button Label
    IBOutlet UIButton *RotateNe; //Rotate Negative Button
    IBOutlet UIButton *ToggleScale; //Toggle Scale Button
    
    IBOutlet UIButton *Xne; // Xnegative decrease
    IBOutlet UIButton *Xaxis;
    IBOutlet UIButton *Xpo; //Xpositive increase
    
    IBOutlet UIButton *Yne;
    IBOutlet UIButton *Yaxis;
    IBOutlet UIButton *Ypo;
    
    IBOutlet UIButton *Zne;
    IBOutlet UIButton *Zaxis;
    IBOutlet UIButton *Zpo;
    
}
- (IBAction)TScale:(id)sender;
- (IBAction)NeRotate:(id)sender;
- (IBAction)PoRotate:(id)sender;

- (IBAction)NeXaxis:(id)sender;
- (IBAction)PoXaxis:(id)sender;

- (IBAction)NeYaxis:(id)sender;
- (IBAction)PoYaxis:(id)sender;

- (IBAction)NeZaxis:(id)sender;
- (IBAction)PoZaxis:(id)sender;


@end

