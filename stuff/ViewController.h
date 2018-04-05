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
    
}
- (IBAction)TScale:(id)sender;
- (IBAction)NeRotate:(id)sender;
- (IBAction)PoRotate:(id)sender;


@end

