//
//  Joystick.h
//  openglesinc
//
//  Created by Harold Serrano on 3/29/15.
//  Copyright (c) 2015 www.roldie.com. All rights reserved.
//

#ifndef __openglesinc__Joystick__
#define __openglesinc__Joystick__

#include <iostream>
#include <math.h>
#include <vector>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#define MAX_SHADER_LENGTH   8192

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

#define OPENGL_ES

using namespace std;

class Joystick{
    
private:
    
    GLuint textureID[16];   //Array for textures
    GLuint joystickDriverShaderprogramObject;   //program object used to link shaders
    GLuint joystickBackgroundShaderprogramObject;   //program object used to link shaders
    
    GLuint vertexArrayJoyStickBackgroundObject; //Vertex Array Object
    GLuint vertexBufferJoyStickBackgroundObject; //Vertex Buffer Object
    
    GLuint vertexArrayJoyStickDriverObject; //Vertex Array Object
    GLuint vertexBufferJoyStickDriverObject; //Vertex Buffer Object
    
    float aspect; //widthDisplay/heightDisplay ratio
   
    GLint joystickBackgroundModelViewProjectionUniformLocation;  //OpenGL location for our MVP uniform
    GLint joystickDriverModelViewProjectionUniformLocation;  //OpenGL location for our MVP uniform
    
    GLint joystickDriverTextureUniformLocation; //OpenGL location for the Texture Map
    GLint joystickBackgroundTextureUniformLocation; //OpenGL location for the Texture Map
    
    GLint joystickDriverStateUniformLocation;  //Uniform location for the current Joystick driver state
    
    //Matrices for several transformation
    GLKMatrix4 joyStickDriverProjectionSpace;
    GLKMatrix4 joyStickDriverModelSpace;
    GLKMatrix4 joyStickDriverModelWorldViewProjectionSpace;
    
    //Matrices for several transformation
    GLKMatrix4 joyStickBackgroundProjectionSpace;
    GLKMatrix4 joyStickBackgroundModelSpace;
    GLKMatrix4 joyStickBackgroundModelWorldViewProjectionSpace;

    
    float screenWidth;  //Width of current device display
    float screenHeight; //Height of current device display
    
    GLuint positionJoystickBackgroundLocation; //attribute "position" location
    GLuint uvJoystickBackgroundLocation; //attribute "uv"location

    GLuint positionJoystickDriverLocation; //attribute "position" location
    GLuint uvJoystickDriverLocation; //attribute "uv"location

    //Used for decommpressing the .png image into raw data
    vector<unsigned char> image;
    unsigned int imageWidth, imageHeight;
    
    //joystick images
    const char* joystickImage;
    const char* joystickBackgroundImage;
    
    float joystickXPosition;  //Joystick x position
    float joystickYPosition;  //Joystick y position
    
    float joystickDriverWidth;  //Joystick width dimension
    float joystickDriverHeight; //Joystick height dimension
    
    float joystickBackgroundWidth;  //Joystick Background width dimension
    float joystickBackgroundHeight; //Joystick Background height dimension

    //joystick boundaries
    float left;
    float right;
    float bottom;
    float top;
    
    //joystick vertex, uv coords and index arrays
    float joystickDriverVertices[12]={0};
    float joystickDriverUVCoords[8]={0};
    int joystickDriverIndex[6]={0};
    
    //joystick Background vertex, uv coords and index arrays
    
    float joystickBackgroundVertices[12]={0};
    float joystickBackgroundUVCoords[8]={0};
    int joystickBackgroundIndex[6]={0};
    
    //has the Joystick been pressed
    bool isPressed;
    
    
    //joystick driver displacement
    float displacementInXDirection;
    float displacementInYDirection;
    
public:
    
    //Constructor
    Joystick(float uJoystickXPosition, float uJoystickYPosition, const char* uBackgroundJoystickImage, float uJoystickBackgroundWidth,float uJoystickBackgroundHeight, const char* uJoystickImage,float uJoystickWidth,float uJoystickHeight,float uScreenWidth,float uScreenHeight);
    
    ~Joystick();
    
    void setupOpenGL(); //Initialize the OpenGL
    void setupJoyStickDriverOpenGL();
    void setupJoyStickBackgroundOpenGL();
    
    void teadDownOpenGL(); //Destroys the OpenGL
    
    //loads the shaders
    void loadShaders(const char* uVertexShaderProgram, const char* uFragmentShaderProgram,GLuint& uProgramObject);
    
    //Set the transformation for the object
    void setJoyStickBackgroundTransformation();
    void setJoyStickDriverTransformation();
    
    //updates the mesh
    void update(float touchXPosition,float touchYPosition);
    
    //draws the mesh
    void draw();
    
    //files used to loading the shader
    bool loadShaderFile(const char *szFile, GLuint shader);
    void loadShaderSrc(const char *szShaderSrc, GLuint shader);
    
    //method to decompress image
    bool convertImageToRawImage(const char *uTexture);
    
    //Joystick dimensions
    void setJoystickDriverVertexAndUVCoords();
    void setJoystickBackgroundVertexAndUVCoords();
    
    //get if Joystick was pressed
    bool getJoystickIsPress();
    
    //Joystick driver displacement
    float getDisplacementInXDirection();
    float getDisplacementInYDirection();
    
    void resetPosition();
    
    //degree to rad
    inline float degreesToRad(float angle){return (angle*M_PI/180);};
    
};



#endif /* defined(__openglesinc__Joystick__) */
