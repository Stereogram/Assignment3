//
//  Copyright © 2017 Borna Noureddin. All rights reserved.
//

#import "Renderer.h"
#import "ViewController.h"
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#include <chrono>
#include "GLESRenderer.hpp"

// Uniform index.
enum
{
    UNIFORM_MODELVIEW_MATRIX,
    UNIFORM_PROJECTION_MATRIX,
    UNIFORM_TEXTURE,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

static bool maze[5][5] = {
    {true, true, true, true, true},
    {false, true, false, true, false},
    {false, true, false, true, false},
    {false, true, false, true, false},
    {false, true, false, true, false}
};

@interface Renderer () {
    GLKView *theView;
    GLESRenderer glesRenderer;
    GLuint programObject;
    std::chrono::time_point<std::chrono::steady_clock> lastTime;

    GLKMatrix4 m, v, p;
    
    GLKMatrix3 normalMatrix;

    float rotAngle;
    GLuint crateTexture;
    GLuint floorTexture;
    GLuint leftTexture;
    GLuint rightTexture;
    GLuint frontTexture;
    GLuint backTexture;
    
    GLKVector3 cam;
    float camRot;
    
    float *quadVertices, *quadTexCoords, *quadNormals;
    int *quadIndices, quadNumIndices;
    
    float *cubeVertices, *cubeTexCoords, *cubeNormals;
    int *cubeIndices, cubeNumIndices;
    
}

@end

@implementation Renderer

- (void)reset
{
    cam.x = 0;
    cam.z = -2;
    cam.y = 0;
    camRot = 0;
}

- (void)move:(CGPoint) point
{
    cam.z += point.y;
    camRot += point.x;
}

- (void)dealloc
{
    glDeleteProgram(programObject);
}

- (void)setup:(GLKView *)view
{
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    
    if (!view.context) {
        NSLog(@"Failed to create ES context");
    }
    
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    theView = view;
    [EAGLContext setCurrentContext:view.context];
    if (![self setupShaders])
        return;
    rotAngle = 45.0f;

    cubeNumIndices = glesRenderer.GenCube(0.5f, &cubeVertices, &cubeNormals, &cubeTexCoords, &cubeIndices);
    quadNumIndices = glesRenderer.GenQuad(1.0f, &quadVertices, &quadNormals, &quadTexCoords, &quadIndices);
    
    glClearColor ( 0.0f, 0.0f, 0.0f, 0.0f );
    glEnable(GL_DEPTH_TEST);
    
    crateTexture = [self setupTexture:@"crate.jpg"];
    floorTexture = [self setupTexture:@"floor.jpg"];
    leftTexture = [self setupTexture:@"left.jpg"];
    rightTexture = [self setupTexture:@"right.jpg"];
    frontTexture = [self setupTexture:@"front.jpg"];
    backTexture = [self setupTexture:@"back.jpg"];
    glUseProgram(programObject);
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
    lastTime = std::chrono::steady_clock::now();
    
    [self reset];
    
}

- (void)update
{
    auto currentTime = std::chrono::steady_clock::now();
    auto elapsedTime = std::chrono::duration_cast<std::chrono::milliseconds>(currentTime - lastTime).count();
    lastTime = currentTime;
    

    rotAngle += 0.1f * elapsedTime;
    
    if (rotAngle >= 360.0f)
        rotAngle = 0.0f;

    // Perspective
    m = GLKMatrix4Translate(GLKMatrix4Identity, 0, 0, 0);
    m = GLKMatrix4Rotate(m, GLKMathDegreesToRadians(rotAngle), 0.0, 1.0, 0.0 );
    
    normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(m), NULL);

    float aspect = (float)theView.drawableWidth / (float)theView.drawableHeight;
    p = GLKMatrix4MakePerspective(60.0f * M_PI / 180.0f, aspect, 1.0f, 20.0f);

}

- (void)draw:(CGRect)drawRect;
{
    
    glUniformMatrix4fv(uniforms[UNIFORM_PROJECTION_MATRIX], 1, FALSE, (const float *)p.m);
    
    
    glViewport(0, 0, (int)theView.drawableWidth, (int)theView.drawableHeight);
    glClear ( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    
    glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(1);
    
    // draw cube
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), cubeVertices);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), cubeTexCoords);
    glBindTexture(GL_TEXTURE_2D, crateTexture);
    v = GLKMatrix4MakeTranslation(cam.x, 0, cam.z);
    v = GLKMatrix4Rotate(v, camRot, 0.0, 1.0, 0.0);
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, FALSE, (const float *)GLKMatrix4Multiply(v, m).m);
    glDrawElements(GL_TRIANGLES, cubeNumIndices, GL_UNSIGNED_INT, cubeIndices);
    
    for(int i = 0; i <= 5; i++)
    {
        for(int j = 0; j <= 5; j++)
        {
            if(maze[i][j])
            {
                glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), quadVertices);
                glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), quadTexCoords);
                m = GLKMatrix4MakeTranslation(i, 0, -j);
                m = GLKMatrix4RotateX(m, M_PI / -2.0);
                glBindTexture(GL_TEXTURE_2D, floorTexture);
                glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, FALSE, (const float *)GLKMatrix4Multiply(v, m).m);
                glDrawElements (GL_TRIANGLES, quadNumIndices, GL_UNSIGNED_INT, quadIndices);
            }
            
            if(i < 0 || !maze[i-1][j])
            {
                glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), quadVertices);
                glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), quadTexCoords);
                m = GLKMatrix4MakeTranslation(i, 0, -j);
                m = GLKMatrix4RotateY(m, M_PI / 2.0);
                glBindTexture(GL_TEXTURE_2D, leftTexture);
                glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, FALSE, (const float *)GLKMatrix4Multiply(v, m).m);
                glDrawElements (GL_TRIANGLES, quadNumIndices, GL_UNSIGNED_INT, quadIndices);
            }
            if(i + 1 >= 5 || !maze[i+1][j])
            {
                
                glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), quadVertices);
                glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), quadTexCoords);
                m = GLKMatrix4MakeTranslation(i, 0, -j);
                m = GLKMatrix4RotateY(m, M_PI / -2.0);
                glBindTexture(GL_TEXTURE_2D, rightTexture);
                glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, FALSE, (const float *)GLKMatrix4Multiply(v, m).m);
                glDrawElements (GL_TRIANGLES, quadNumIndices, GL_UNSIGNED_INT, quadIndices);
            }
            if(j - 1 < 0 || !maze[i][j-1])
            {
                if(j == 0 && i == 0)//entrance
                    continue;
                glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), quadVertices);
                glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), quadTexCoords);
                m = GLKMatrix4MakeTranslation(i, 0, -j);
                m = GLKMatrix4RotateY(m, M_PI);
                glBindTexture(GL_TEXTURE_2D, frontTexture);
                glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, FALSE, (const float *)GLKMatrix4Multiply(v, m).m);
                glDrawElements (GL_TRIANGLES, quadNumIndices, GL_UNSIGNED_INT, quadIndices);
            }
            if(j + 1 >= 5 || (i != 0 && j != 0) || !maze[i][j+1])
            {
                glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), quadVertices);
                glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), quadTexCoords);
                m = GLKMatrix4MakeTranslation(i, 0, -j);
                m = GLKMatrix4RotateY(m, M_PI);
                glBindTexture(GL_TEXTURE_2D, backTexture);
                glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, FALSE, (const float *)GLKMatrix4Multiply(v, m).m);
                glDrawElements (GL_TRIANGLES, quadNumIndices, GL_UNSIGNED_INT, quadIndices);
            }
        }
    }
    
    
    
    
    
    
    
}


- (bool)setupShaders
{
    // Load shaders
    char *vShaderStr = glesRenderer.LoadShaderFile([[[NSBundle mainBundle] pathForResource:[[NSString stringWithUTF8String:"Shader.vsh"] stringByDeletingPathExtension] ofType:[[NSString stringWithUTF8String:"Shader.vsh"] pathExtension]] cStringUsingEncoding:1]);
    char *fShaderStr = glesRenderer.LoadShaderFile([[[NSBundle mainBundle] pathForResource:[[NSString stringWithUTF8String:"Shader.fsh"] stringByDeletingPathExtension] ofType:[[NSString stringWithUTF8String:"Shader.fsh"] pathExtension]] cStringUsingEncoding:1]);
    programObject = glesRenderer.LoadProgram(vShaderStr, fShaderStr);
    if (programObject == 0)
        return false;
    
    // Set up uniform variables
    uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(programObject, "texSampler");
    uniforms[UNIFORM_MODELVIEW_MATRIX] = glGetUniformLocation(programObject, "modelViewMatrix");
    uniforms[UNIFORM_PROJECTION_MATRIX] = glGetUniformLocation(programObject, "projectionMatrix");

    return true;
}

// Load in and set up texture image (adapted from Ray Wenderlich)
- (GLuint)setupTexture:(NSString *)fileName
{
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte *spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);
    
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);
    return texName;
}


@end
