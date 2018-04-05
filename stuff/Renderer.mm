//
//  Copyright © 2017 Borna Noureddin. All rights reserved.
//

#import "Renderer.h"
#import "ViewController.h"
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#include <chrono>
#include "GLESRenderer.hpp"
#include <vector>

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
    float RX; //Rotation
    float camRot;
    float SizeX, SizeY;
    float mXpos, mYpos, mZpos;
    
    std::vector<GLKVector3> vertices;
    std::vector<GLKVector2> uvs;
    std::vector<GLKVector3> normals;
    
    std::vector<unsigned short> modelindices;
    std::vector<unsigned short> cubeindices;
    
    
    GLuint modelvertexbuffer;
    GLuint modeluvbuffer;
    GLuint modelnormalbuffer;
    GLuint modelelementbuffer;
    
    GLuint cubevertexbuffer;
    GLuint cubeuvbuffer;
    GLuint cubenormalbuffer;
    GLuint cubeelementbuffer;

    
    
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

    if(!glesRenderer.LoadOBJ([[[NSBundle mainBundle] pathForResource:[[NSString stringWithUTF8String:"cube.obj"] stringByDeletingPathExtension] ofType:[[NSString stringWithUTF8String:"cube.obj"] pathExtension]] cStringUsingEncoding:1], vertices, uvs, normals, cubeindices))
    {
        NSLog(@"failed to load");
    }
    
    glGenBuffers(1, &cubevertexbuffer);
    glBindBuffer(GL_ARRAY_BUFFER, cubevertexbuffer);
    glBufferData(GL_ARRAY_BUFFER, vertices.size() * sizeof(GLKVector3), &vertices[0], GL_STATIC_DRAW);
    
    glGenBuffers(1, &cubeuvbuffer);
    glBindBuffer(GL_ARRAY_BUFFER, cubeuvbuffer);
    glBufferData(GL_ARRAY_BUFFER, uvs.size() * sizeof(GLKVector2), &uvs[0], GL_STATIC_DRAW);
    
    glGenBuffers(1, &cubenormalbuffer);
    glBindBuffer(GL_ARRAY_BUFFER, cubenormalbuffer);
    glBufferData(GL_ARRAY_BUFFER, normals.size() * sizeof(GLKVector3), &normals[0], GL_STATIC_DRAW);
    
    // Generate a buffer for the indices as well
    glGenBuffers(1, &cubeelementbuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, cubeelementbuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, cubeindices.size() * sizeof(unsigned short), &cubeindices[0] , GL_STATIC_DRAW);
    
    vertices.clear();
    uvs.clear();
    normals.clear();
    
    if(!glesRenderer.LoadOBJ([[[NSBundle mainBundle] pathForResource:[[NSString stringWithUTF8String:"rat.obj"] stringByDeletingPathExtension] ofType:[[NSString stringWithUTF8String:"rat.obj"] pathExtension]] cStringUsingEncoding:1], vertices, uvs, normals, modelindices))
    {
        NSLog(@"failed to load");
    }
    
    glGenBuffers(1, &modelvertexbuffer);
    glBindBuffer(GL_ARRAY_BUFFER, modelvertexbuffer);
    glBufferData(GL_ARRAY_BUFFER, vertices.size() * sizeof(GLKVector3), &vertices[0], GL_STATIC_DRAW);
    
    glGenBuffers(1, &modeluvbuffer);
    glBindBuffer(GL_ARRAY_BUFFER, modeluvbuffer);
    glBufferData(GL_ARRAY_BUFFER, uvs.size() * sizeof(GLKVector2), &uvs[0], GL_STATIC_DRAW);
    
    glGenBuffers(1, &modelnormalbuffer);
    glBindBuffer(GL_ARRAY_BUFFER, modelnormalbuffer);
    glBufferData(GL_ARRAY_BUFFER, normals.size() * sizeof(GLKVector3), &normals[0], GL_STATIC_DRAW);
    
    // Generate a buffer for the indices as well
    glGenBuffers(1, &modelelementbuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, modelelementbuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, modelindices.size() * sizeof(unsigned short), &modelindices[0] , GL_STATIC_DRAW);
    
    vertices.clear();
    uvs.clear();
    normals.clear();
    
    
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
-(void)setRotate:(float)xr{
    
    RX = xr;
}
-(void)setScale:(float)x ScaleY:(float)y{
    
    SizeX = x;
    SizeY = y;
    
}

-(void)setPosition:(float)xPo PositionY:(float)yPo PositionZ:(float)zPo{
    
    mXpos = xPo;
    mYpos = yPo;
    mZpos = zPo;
    
}

- (void)drawModel;
{
    glUniformMatrix4fv(uniforms[UNIFORM_PROJECTION_MATRIX], 1, FALSE, (const float *)p.m);
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, FALSE, (const float *)GLKMatrix4Multiply(v, m).m);
    
    // 1st attribute buffer : vertices
    glEnableVertexAttribArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, modelvertexbuffer);
    glVertexAttribPointer(
                          0,                  // attribute
                          3,                  // size
                          GL_FLOAT,           // type
                          GL_FALSE,           // normalized?
                          0,                  // stride
                          (void*)0            // array buffer offset
                          );
    
    // 2nd attribute buffer : UVs
    glEnableVertexAttribArray(1);
    glBindBuffer(GL_ARRAY_BUFFER, modeluvbuffer);
    glVertexAttribPointer(
                          1,                                // attribute
                          2,                                // size
                          GL_FLOAT,                         // type
                          GL_FALSE,                         // normalized?
                          0,                                // stride
                          (void*)0                          // array buffer offset
                          );
    
    // 3rd attribute buffer : normals
    glEnableVertexAttribArray(2);
    glBindBuffer(GL_ARRAY_BUFFER, modelnormalbuffer);
    glVertexAttribPointer(
                          2,                                // attribute
                          3,                                // size
                          GL_FLOAT,                         // type
                          GL_FALSE,                         // normalized?
                          0,                                // stride
                          (void*)0                          // array buffer offset
                          );
    
    // Index buffer
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, modelelementbuffer);
    
    
    // Draw the triangles !
    glDrawElements(
                   GL_TRIANGLES,      // mode
                   modelindices.size(),    // count
                   GL_UNSIGNED_SHORT,   // type
                   (void*)0           // element array buffer offset
                   );
    
    glDisableVertexAttribArray(0);
    glDisableVertexAttribArray(1);
    glDisableVertexAttribArray(2);

}

- (void)drawCube;
{
    glUniformMatrix4fv(uniforms[UNIFORM_PROJECTION_MATRIX], 1, FALSE, (const float *)p.m);
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, FALSE, (const float *)GLKMatrix4Multiply(v, m).m);
    
    // 1st attribute buffer : vertices
    glEnableVertexAttribArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, cubevertexbuffer);
    glVertexAttribPointer(
                          0,                  // attribute
                          3,                  // size
                          GL_FLOAT,           // type
                          GL_FALSE,           // normalized?
                          0,                  // stride
                          (void*)0            // array buffer offset
                          );
    
    // 2nd attribute buffer : UVs
    glEnableVertexAttribArray(1);
    glBindBuffer(GL_ARRAY_BUFFER, cubeuvbuffer);
    glVertexAttribPointer(
                          1,                                // attribute
                          2,                                // size
                          GL_FLOAT,                         // type
                          GL_FALSE,                         // normalized?
                          0,                                // stride
                          (void*)0                          // array buffer offset
                          );
    
    // 3rd attribute buffer : normals
    glEnableVertexAttribArray(2);
    glBindBuffer(GL_ARRAY_BUFFER, cubenormalbuffer);
    glVertexAttribPointer(
                          2,                                // attribute
                          3,                                // size
                          GL_FLOAT,                         // type
                          GL_FALSE,                         // normalized?
                          0,                                // stride
                          (void*)0                          // array buffer offset
                          );
    
    // Index buffer
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, cubeelementbuffer);
    
    
    // Draw the triangles !
    glDrawElements(
                   GL_TRIANGLES,      // mode
                   cubeindices.size(),    // count
                   GL_UNSIGNED_SHORT,   // type
                   (void*)0           // element array buffer offset
                   );
    
    glDisableVertexAttribArray(0);
    glDisableVertexAttribArray(1);
    glDisableVertexAttribArray(2);
    
}

- (void)draw:(CGRect)drawRect;
{
    
    glUniformMatrix4fv(uniforms[UNIFORM_PROJECTION_MATRIX], 1, FALSE, (const float *)p.m);
    
    
    glViewport(0, 0, (int)theView.drawableWidth, (int)theView.drawableHeight);
    glClear ( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    
    
    glBindTexture(GL_TEXTURE_2D, crateTexture);
    m = GLKMatrix4Scale(m, 0.2, 0.2, 0.2);
    [self drawCube];
    
    
    glBindTexture(GL_TEXTURE_2D, crateTexture);//lol wooden mouse
    m = GLKMatrix4Translate(GLKMatrix4Identity, 0, 0, 0);
    m = GLKMatrix4RotateX(m, 0);
    m = GLKMatrix4Scale(m, 0.2, 0.2, 0.2);
    [self drawModel];
   
    v = GLKMatrix4MakeTranslation(cam.x, 0, cam.z);
    v = GLKMatrix4Rotate(v, camRot, 0.0, 1.0, 0.0);
    m = GLKMatrix4Identity;
    for(int i = 0; i <= 5; i++)
    {
        for(int j = 0; j <= 5; j++)
        {
            if(maze[i][j])
            {
                m = GLKMatrix4MakeTranslation(i, -0.5, -j);
                m = GLKMatrix4Scale(m, 1, 0.1, 1);
                glBindTexture(GL_TEXTURE_2D, floorTexture);
                glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, FALSE, (const float *)GLKMatrix4Multiply(v, m).m);
                [self drawCube];
            }
            
            if(i < 0 || !maze[i-1][j])
            {
                m = GLKMatrix4MakeTranslation(i-0.5, 0, -j);
                m = GLKMatrix4RotateY(m, M_PI / 2.0);
                m = GLKMatrix4Scale(m, 1, 1, 0.1);
                glBindTexture(GL_TEXTURE_2D, leftTexture);
                glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, FALSE, (const float *)GLKMatrix4Multiply(v, m).m);
                [self drawCube];
            }
            if(i + 1 >= 5 || !maze[i+1][j])
            {
                m = GLKMatrix4MakeTranslation(i+0.5, 0, -j);
                m = GLKMatrix4RotateY(m, M_PI / 2.0);
                m = GLKMatrix4Scale(m, 1, 1, 0.1);
                glBindTexture(GL_TEXTURE_2D, rightTexture);
                glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, FALSE, (const float *)GLKMatrix4Multiply(v, m).m);
                [self drawCube];            }
            if(j - 1 < 0 || !maze[i][j-1])
            {
                if(j == 0 && i == 0)//entrance
                    continue;
                m = GLKMatrix4MakeTranslation(i, 0, -j-0.5);
                m = GLKMatrix4RotateY(m, M_PI);
                m = GLKMatrix4Scale(m, 1, 1, 0.1);
                glBindTexture(GL_TEXTURE_2D, frontTexture);
                glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, FALSE, (const float *)GLKMatrix4Multiply(v, m).m);
                [self drawCube];
            }
            if(j + 1 >= 5 || (i != 0 && j != 0) || !maze[i][j+1])
            {
                m = GLKMatrix4MakeTranslation(i, 0, -j+0.5);
                m = GLKMatrix4RotateY(m, M_PI);
                m = GLKMatrix4Scale(m, 1, 1, 0.1);
                glBindTexture(GL_TEXTURE_2D, backTexture);
                glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, FALSE, (const float *)GLKMatrix4Multiply(v, m).m);
                [self drawCube];
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

