//
//  Copyright © 2017 Borna Noureddin. All rights reserved.
//

#ifndef Renderer_h
#define Renderer_h
#import <GLKit/GLKit.h>

@interface Renderer : NSObject

- (void)setup:(GLKView *)view;
- (void)update;
- (void)draw:(CGRect)drawRect;
- (void)move:(CGPoint)point;
- (void)reset;
- (void)setScale:(float)x ScaleY:(float)y;
- (void)setRotate:(float)xr;
- (void)setPosition:(float)xPo PositionY:(float)yPo PositionZ:(float)zPo;
- (void)station:(bool)st;
@end

#endif /* Renderer_h */
