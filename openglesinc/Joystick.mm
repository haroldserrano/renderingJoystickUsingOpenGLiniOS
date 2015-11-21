//
//  Joystick.cpp
//  openglesinc
//
//  Created by Harold Serrano on 3/23/15.
//  Copyright (c) 2015 www.haroldserrano.com. All rights reserved.
//

#include "Joystick.h"
#include "lodepng.h"
#include <vector>


static GLubyte shaderText[MAX_SHADER_LENGTH];

Joystick::Joystick(float uJoystickXPosition, float uJoystickYPosition, const char* uBackgroundJoystickImage, float uJoystickBackgroundWidth,float uJoystickBackgroundHeight, const char* uJoystickImage,float uJoystickWidth,float uJoystickHeight,float uScreenWidth,float uScreenHeight){
    
    //1. screen width and height
    screenWidth=uScreenWidth;
    screenHeight=uScreenHeight;
    
    //2. Joystick driver & background width and height
    joystickDriverWidth=uJoystickWidth;
    joystickDriverHeight=uJoystickHeight;
    
    joystickBackgroundWidth=uJoystickBackgroundWidth;
    joystickBackgroundHeight=uJoystickBackgroundHeight;
    
    //3. set the names of both Joystick images
    joystickImage=uJoystickImage;
    joystickBackgroundImage=uBackgroundJoystickImage;
    
    //4. Joystick x and y position. Because our ortho matrix is in the range of [-1,1]. We need to convert from screen coordinates to ortho coordinates.
    joystickXPosition=uJoystickXPosition*2/screenWidth-1;
    joystickYPosition=uJoystickYPosition*(-2/screenHeight)+1;
    
    //5. calculate the boundaries of the Joystick
    left=joystickXPosition-joystickDriverWidth/screenWidth;
    right=joystickXPosition+joystickDriverWidth/screenWidth;
    
    top=joystickYPosition+joystickDriverHeight/screenHeight;
    bottom=joystickYPosition-joystickDriverHeight/screenHeight;
    
    //6. set the bool value to false
    isPressed=false;
    
    //7. set the vertex and UV coordinates for both joystick images
    setJoystickDriverVertexAndUVCoords();
    setJoystickBackgroundVertexAndUVCoords();
}

void Joystick::setupOpenGL(){
    
    //1. Load up the joystick driver OpenGL Buffers
    setupJoyStickDriverOpenGL();

    //2. Load up the joystick background OpenGL Buffers
    setupJoyStickBackgroundOpenGL();
    
}

void Joystick::setupJoyStickBackgroundOpenGL(){
    
    //load the shaders, compile them and link them
    
    loadShaders("JoystickBackgroundShader.vsh", "JoystickBackgroundShader.fsh",joystickBackgroundShaderprogramObject);
    
    //glEnable(GL_DEPTH_TEST);
    
    //1. Generate a Vertex Array Object
    
    glGenVertexArraysOES(1,&vertexArrayJoyStickBackgroundObject);
    
    //2. Bind the Vertex Array Object
    
    glBindVertexArrayOES(vertexArrayJoyStickBackgroundObject);
    
    //3. Generate a Vertex Buffer Object
    
    glGenBuffers(1, &vertexBufferJoyStickBackgroundObject);
    
    //4. Bind the Vertex Buffer Object
    
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferJoyStickBackgroundObject);
    
    //5a. Dump the data into the Buffer
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(joystickBackgroundVertices)+sizeof(joystickBackgroundUVCoords), NULL, GL_STATIC_DRAW);
    
    //5b. Load vertex data with glBufferSubData
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(joystickBackgroundVertices), joystickBackgroundVertices);
    
    //5c. Load uv data with glBufferSubData
    glBufferSubData(GL_ARRAY_BUFFER, sizeof(joystickBackgroundVertices), sizeof(joystickBackgroundUVCoords), joystickBackgroundUVCoords);
    
    
    //6. Get the location of the shader attribute called "position"
    positionJoystickBackgroundLocation=glGetAttribLocation(joystickBackgroundShaderprogramObject, "position");
    
    //8. Get the location of the shader attribute called "texCoords"
    uvJoystickBackgroundLocation=glGetAttribLocation(joystickBackgroundShaderprogramObject, "texCoord");
    
    //8. Get Location of uniforms
    joystickBackgroundModelViewProjectionUniformLocation = glGetUniformLocation(joystickBackgroundShaderprogramObject,"modelViewProjectionMatrix");
    
    //9. Enable both attribute locations
    
    //9a. Enable the position attribute
    glEnableVertexAttribArray(positionJoystickBackgroundLocation);
    
    //9c. Enable the UV attribute
    glEnableVertexAttribArray(uvJoystickBackgroundLocation);
    
    //10. Link the buffer data to the shader attribute locations
    
    //10a. Link the buffer data to the shader's position location
    glVertexAttribPointer(positionJoystickBackgroundLocation, 3, GL_FLOAT, GL_FALSE, 0, (const GLvoid *) 0);
    
    //10b. Link the buffer data to the shader's UV location
    glVertexAttribPointer(uvJoystickBackgroundLocation, 2, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)sizeof(joystickBackgroundVertices));
    
    /*Since we are going to start the rendering process by using glDrawElements*/
    
    //11. Create a new buffer for the indices
    GLuint elementBuffer;
    glGenBuffers(1, &elementBuffer);
    
    //12. Bind the new buffer to binding point GL_ELEMENT_ARRAY_BUFFER
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, elementBuffer);
    
    //13. Load the buffer with the indices found in weapon_index array
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(joystickBackgroundIndex), joystickBackgroundIndex, GL_STATIC_DRAW);
    
    //SET UNPRESSED Joystick TEXTURE
    //14. Activate GL_TEXTURE0
    glActiveTexture(GL_TEXTURE0);
    
    //15 Generate a texture buffer
    glGenTextures(1, &textureID[0]);
    
    //16 Bind texture0
    glBindTexture(GL_TEXTURE_2D, textureID[0]);
    
    //17. Decode image into its raw image data. "joyStickBackground.png" is our formatted image.
    if(convertImageToRawImage("joyStickBackground.png")){
        
        //if decompression was successful, set the texture parameters
        
        //17a. set the texture wrapping parameters
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        //17b. set the texture magnification/minification parameters
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        
        //17c. load the image data into the current bound texture buffer
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, imageWidth, imageHeight, 0,
                     GL_RGBA, GL_UNSIGNED_BYTE, &image[0]);
        
    }
    
    image.clear();
    
    //18. Get the location of the Uniform Sampler2D
    joystickBackgroundTextureUniformLocation=glGetUniformLocation(joystickBackgroundShaderprogramObject, "JoystickBackgroundTextureMap");
    
    //19. Unbind the VAO
    glBindVertexArrayOES(0);
    
    //20. Sets the transformation
    setJoyStickBackgroundTransformation();
    
}

void Joystick::setupJoyStickDriverOpenGL(){
    
    
    //load the shaders, compile them and link them
    
    loadShaders("JoystickDriverShader.vsh", "JoystickDriverShader.fsh",joystickDriverShaderprogramObject);
    
    //glEnable(GL_DEPTH_TEST);
    
    //1. Generate a Vertex Array Object
    
    glGenVertexArraysOES(1,&vertexArrayJoyStickDriverObject);
    
    //2. Bind the Vertex Array Object
    
    glBindVertexArrayOES(vertexArrayJoyStickDriverObject);
    
    //3. Generate a Vertex Buffer Object
    
    glGenBuffers(1, &vertexBufferJoyStickDriverObject);
    
    //4. Bind the Vertex Buffer Object
    
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferJoyStickDriverObject);
    
    //5a. Dump the data into the Buffer
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(joystickDriverVertices)+sizeof(joystickDriverUVCoords), NULL, GL_STATIC_DRAW);
    
    //5b. Load vertex data with glBufferSubData
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(joystickDriverVertices), joystickDriverVertices);
    
    //5c. Load uv data with glBufferSubData
    glBufferSubData(GL_ARRAY_BUFFER, sizeof(joystickDriverVertices), sizeof(joystickDriverUVCoords), joystickDriverUVCoords);
    
    //6. Get the location of the shader attribute called "position"
    positionJoystickDriverLocation=glGetAttribLocation(joystickDriverShaderprogramObject, "position");
    
    //8. Get the location of the shader attribute called "texCoords"
    uvJoystickDriverLocation=glGetAttribLocation(joystickDriverShaderprogramObject, "texCoord");
    
    //8. Get Location of uniforms
    joystickDriverModelViewProjectionUniformLocation = glGetUniformLocation(joystickDriverShaderprogramObject,"modelViewProjectionMatrix");
    
    //9. Enable both attribute locations
    
    //9a. Enable the position attribute
    glEnableVertexAttribArray(positionJoystickDriverLocation);
    
    //9c. Enable the UV attribute
    glEnableVertexAttribArray(uvJoystickDriverLocation);
    
    //10. Link the buffer data to the shader attribute locations
    
    //10a. Link the buffer data to the shader's position location
    glVertexAttribPointer(positionJoystickDriverLocation, 3, GL_FLOAT, GL_FALSE, 0, (const GLvoid *) 0);
    
    //10b. Link the buffer data to the shader's UV location
    glVertexAttribPointer(uvJoystickDriverLocation, 2, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)sizeof(joystickDriverVertices));
    
    /*Since we are going to start the rendering process by using glDrawElements*/
    
    //11. Create a new buffer for the indices
    GLuint elementBuffer;
    glGenBuffers(1, &elementBuffer);
    
    //12. Bind the new buffer to binding point GL_ELEMENT_ARRAY_BUFFER
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, elementBuffer);
    
    //13. Load the buffer with the indices found in weapon_index array
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(joystickDriverIndex), joystickDriverIndex, GL_STATIC_DRAW);
    
    //SET UNPRESSED Joystick TEXTURE
    //14. Activate GL_TEXTURE1
    glActiveTexture(GL_TEXTURE1);
    
    //15 Generate a texture buffer
    glGenTextures(1, &textureID[1]);
    
    //16 Bind texture0
    glBindTexture(GL_TEXTURE_2D, textureID[1]);
    
    //17. Decode image into its raw image data. "joystickDriver.png" is our formatted image.
    if(convertImageToRawImage("joystickDriver.png")){
        
        //if decompression was successful, set the texture parameters
        
        //17a. set the texture wrapping parameters
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        //17b. set the texture magnification/minification parameters
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        
        //17c. load the image data into the current bound texture buffer
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, imageWidth, imageHeight, 0,
                     GL_RGBA, GL_UNSIGNED_BYTE, &image[0]);
        
    }
    
    image.clear();
    
    //18. Get the location of the Uniform Sampler2D
    joystickDriverTextureUniformLocation=glGetUniformLocation(joystickDriverShaderprogramObject, "JoystickDriverTextureMap");
    
    //19. Unbind the VAO
    glBindVertexArrayOES(0);
    
    //20. Sets the transformation
    setJoyStickDriverTransformation();
    
}

void Joystick::update(float touchXPosition,float touchYPosition){
    
    //Set the shader program
    glUseProgram(joystickDriverShaderprogramObject);
    
    //Bind the VAO
    glBindVertexArrayOES(vertexArrayJoyStickDriverObject);
    
    
    //1. check if the touch is within the boundaries of the joystick
    
    if (touchXPosition>=left && touchXPosition<=right) {
        
        if (touchYPosition>=bottom && touchYPosition<=top) {
            
            //2. if so, set the bool value to true
            isPressed=true;

            //3. Set the joystick to an identity matrix
            joyStickDriverModelSpace=GLKMatrix4Identity;
            
            //4. translate the Joystick to the touch position
            joyStickDriverModelSpace=GLKMatrix4Translate(joyStickDriverModelSpace, touchXPosition, touchYPosition, 0.0);
            
            //5. Transform the model-world-view space to the projection space
            joyStickDriverModelWorldViewProjectionSpace = GLKMatrix4Multiply(joyStickDriverProjectionSpace, joyStickDriverModelSpace);
            
            //6. Assign the model-world-view-projection matrix data to the uniform location:modelviewProjectionUniformLocation
            glUniformMatrix4fv(joystickDriverModelViewProjectionUniformLocation, 1, 0, joyStickDriverModelWorldViewProjectionSpace.m);
  
            //7. Calculate the difference in position between the origin of the joystick and touch position
            displacementInXDirection=touchXPosition-joystickXPosition;
            displacementInYDirection=joystickYPosition-touchYPosition;
            
        }
    }
    
    else{
        
        //8. else, set it to false
        isPressed=false;
   
    }
    
    //unbind the VAO
    glBindVertexArrayOES(0);
    
}

void Joystick::draw(){
    
    //1. Enable blending and depth test
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glDisable(GL_DEPTH_TEST);
    
    //2. Set the shader program for the joystick background image
    glUseProgram(joystickBackgroundShaderprogramObject);
    
    //3. Bind the VAO for the joystick background
    glBindVertexArrayOES(vertexArrayJoyStickBackgroundObject);
    
    //4. Activate the texture unit for the joystick background image
    glActiveTexture(GL_TEXTURE0);
    
    //5 Bind the texture object
    glBindTexture(GL_TEXTURE_2D, textureID[0]);
    
    //6. Specify the value of the UV Map uniform
    glUniform1i(joystickDriverTextureUniformLocation, 0);
    
    //7. Start the rendering process
    glDrawElements(GL_TRIANGLES, sizeof(joystickBackgroundIndex)/4, GL_UNSIGNED_INT,(void*)0);

    
    //8. Set the shader program for the joystick driver image
    glUseProgram(joystickDriverShaderprogramObject);
    
    //9. Bind the VAO for the joystick driver
    glBindVertexArrayOES(vertexArrayJoyStickDriverObject);

    //10. Activate the texture unit for the joystick driver image
    glActiveTexture(GL_TEXTURE1);
    
    //11 Bind the texture object
    glBindTexture(GL_TEXTURE_2D, textureID[1]);
    
    //12. Specify the value of the UV Map uniform
    glUniform1i(joystickDriverTextureUniformLocation, 1);
    
    //13. Start the rendering process
    glDrawElements(GL_TRIANGLES, sizeof(joystickDriverIndex)/4, GL_UNSIGNED_INT,(void*)0);
    
    //14. Disable the VAO
    glBindVertexArrayOES(0);
    
    //15. Disable the blending and enable depth testing
    glDisable(GL_BLEND);
    glEnable(GL_DEPTH_TEST);

}


void Joystick::setJoyStickBackgroundTransformation(){
    
    //1. Set up the model space for the Joystick background image
    joyStickBackgroundModelSpace=GLKMatrix4Identity;
    
    //2. translate the Joystick background image
    joyStickBackgroundModelSpace=GLKMatrix4Translate(joyStickBackgroundModelSpace, joystickXPosition, joystickYPosition, 0.0);
    
    
    //3. Set the projection space to a ortho space
    joyStickBackgroundProjectionSpace = GLKMatrix4MakeOrtho(-1.0, 1.0, -1.0, 1.0, -1.0, 1.0);
    
    
    //4. Transform the model-world-view space to the projection space
    joyStickBackgroundModelWorldViewProjectionSpace = GLKMatrix4Multiply(joyStickBackgroundProjectionSpace, joyStickBackgroundModelSpace);
    
    
    //5. Assign the model-world-view-projection matrix data to the uniform location:modelviewProjectionUniformLocation
    glUniformMatrix4fv(joystickBackgroundModelViewProjectionUniformLocation, 1, 0, joyStickBackgroundModelWorldViewProjectionSpace.m);
    
}

void Joystick::setJoyStickDriverTransformation(){
    
    //1. Set up the model space the Joystick driver image
    joyStickDriverModelSpace=GLKMatrix4Identity;
    
    //2. translate the Joystick driver image
    joyStickDriverModelSpace=GLKMatrix4Translate(joyStickDriverModelSpace, joystickXPosition, joystickYPosition, 0.0);
    
    
    //3. Set the projection space to a ortho space
    joyStickDriverProjectionSpace = GLKMatrix4MakeOrtho(-1.0, 1.0, -1.0, 1.0, -1.0, 1.0);
    
    
    //4. Transform the model-world-view space to the projection space
    joyStickDriverModelWorldViewProjectionSpace = GLKMatrix4Multiply(joyStickDriverProjectionSpace, joyStickDriverModelSpace);
    
    
    //5. Assign the model-world-view-projection matrix data to the uniform location:modelviewProjectionUniformLocation
    glUniformMatrix4fv(joystickDriverModelViewProjectionUniformLocation, 1, 0, joyStickDriverModelWorldViewProjectionSpace.m);
    
}

void Joystick::setJoystickBackgroundVertexAndUVCoords(){
    
    
    //1. set the width, height and depth for the joystick background image rectangle
    float width=joystickBackgroundWidth/screenWidth;
    float height=joystickBackgroundHeight/screenHeight;
    float depth=0.0;
    
    //2. Set the value for each vertex into an array
    
    //Upper-Right Corner vertex of rectangle
    joystickBackgroundVertices[0]=width;
    joystickBackgroundVertices[1]=height;
    joystickBackgroundVertices[2]=depth;
    
    //Lower-Right corner vertex of rectangle
    joystickBackgroundVertices[3]=width;
    joystickBackgroundVertices[4]=-height;
    joystickBackgroundVertices[5]=depth;
    
    //Lower-Left corner vertex of rectangle
    joystickBackgroundVertices[6]=-width;
    joystickBackgroundVertices[7]=-height;
    joystickBackgroundVertices[8]=depth;
    
    //Upper-Left corner vertex of rectangle
    joystickBackgroundVertices[9]=-width;
    joystickBackgroundVertices[10]=height;
    joystickBackgroundVertices[11]=depth;
    
    
    //3. Set the value for each uv coordinate into an array
    
    joystickBackgroundUVCoords[0]=1.0;
    joystickBackgroundUVCoords[1]=0.0;
    
    joystickBackgroundUVCoords[2]=1.0;
    joystickBackgroundUVCoords[3]=1.0;
    
    joystickBackgroundUVCoords[4]=0.0;
    joystickBackgroundUVCoords[5]=1.0;
    
    joystickBackgroundUVCoords[6]=0.0;
    joystickBackgroundUVCoords[7]=0.0;
    
    //4. set the value for each index into an array
    
    joystickBackgroundIndex[0]=0;
    joystickBackgroundIndex[1]=1;
    joystickBackgroundIndex[2]=2;
    
    joystickBackgroundIndex[3]=2;
    joystickBackgroundIndex[4]=3;
    joystickBackgroundIndex[5]=0;
    
}

void Joystick::setJoystickDriverVertexAndUVCoords(){
    
    //1. set the width, height and depth for the joystick driver image rectangle
    float width=joystickDriverWidth/screenWidth;
    float height=joystickDriverHeight/screenHeight;
    float depth=0.0;
    
    //2. Set the value for each vertex into an array
    
    //Upper-Right Corner vertex of rectangle
    joystickDriverVertices[0]=width;
    joystickDriverVertices[1]=height;
    joystickDriverVertices[2]=depth;
    
    //Lower-Right corner vertex of rectangle
    joystickDriverVertices[3]=width;
    joystickDriverVertices[4]=-height;
    joystickDriverVertices[5]=depth;
    
    //Lower-Left corner vertex of rectangle
    joystickDriverVertices[6]=-width;
    joystickDriverVertices[7]=-height;
    joystickDriverVertices[8]=depth;
    
    //Upper-Left corner vertex of rectangle
    joystickDriverVertices[9]=-width;
    joystickDriverVertices[10]=height;
    joystickDriverVertices[11]=depth;
    
    
    //3. Set the value for each uv coordinate into an array
    
    joystickDriverUVCoords[0]=1.0;
    joystickDriverUVCoords[1]=0.0;
    
    joystickDriverUVCoords[2]=1.0;
    joystickDriverUVCoords[3]=1.0;
    
    joystickDriverUVCoords[4]=0.0;
    joystickDriverUVCoords[5]=1.0;
    
    joystickDriverUVCoords[6]=0.0;
    joystickDriverUVCoords[7]=0.0;
    
    //4. set the value for each index into an array
    
    joystickDriverIndex[0]=0;
    joystickDriverIndex[1]=1;
    joystickDriverIndex[2]=2;
    
    joystickDriverIndex[3]=2;
    joystickDriverIndex[4]=3;
    joystickDriverIndex[5]=0;
    
}

void Joystick::resetPosition(){
    
    //reset the position of the joystick driver to initial position
    update(joystickXPosition, joystickYPosition);
}

bool Joystick::getJoystickIsPress(){
    
    //return the state of the Joystick
    return isPressed;
    
}

float Joystick::getDisplacementInXDirection(){
    
    //get displacement of joystick driver in x direction
    return displacementInXDirection;
}

float Joystick::getDisplacementInYDirection(){

    //get displacement of joystick driver in y direction    
    return displacementInYDirection;
}



bool Joystick::convertImageToRawImage(const char *uTexture){
    
    bool success=false;
    
    //The method decode() is the method rensponsible for decompressing the formated image.
    //The result is stored in "image".
    
    unsigned error = lodepng::decode(image, imageWidth, imageHeight,uTexture);
    
    //if there's an error, display it
    if(error){
        
        cout << "Couldn't decode the image. decoder error " << error << ": " << lodepng_error_text(error) << std::endl;
        
    }else{
        
        //Flip and invert the image
        unsigned char* imagePtr=&image[0];
        
        int halfTheHeightInPixels=imageHeight/2;
        int heightInPixels=imageHeight;
        
        
        //Assume RGBA for 4 components per pixel
        int numColorComponents=4;
        
        //Assuming each color component is an unsigned char
        int widthInChars=imageWidth*numColorComponents;
        
        unsigned char *top=NULL;
        unsigned char *bottom=NULL;
        unsigned char temp=0;
        
        for( int h = 0; h < halfTheHeightInPixels; ++h )
        {
            top = imagePtr + h * widthInChars;
            bottom = imagePtr + (heightInPixels - h - 1) * widthInChars;
            
            for( int w = 0; w < widthInChars; ++w )
            {
                // Swap the chars around.
                temp = *top;
                *top = *bottom;
                *bottom = temp;
                
                ++top;
                ++bottom;
            }
        }
        
        success=true;
    }
    
    return success;
}



void Joystick::loadShaders(const char* uVertexShaderProgram, const char* uFragmentShaderProgram,GLuint& uProgramObject){
    
    // Temporary Shader objects
    GLuint VertexShader;
    GLuint FragmentShader;
    
    //1. Create shader objects
    VertexShader = glCreateShader(GL_VERTEX_SHADER);
    FragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
	
    
    //2. Load both vertex & fragment shader files
    
    //2a. Usually you want to check the return value of the loadShaderFile function, if
    //it returns true, then the shaders were found, else there was an error.
    
    if(loadShaderFile(uVertexShaderProgram, VertexShader)==false){
        
        glDeleteShader(VertexShader);
        glDeleteShader(FragmentShader);
        fprintf(stderr, "The shader at %s could not be found.\n", uVertexShaderProgram);
        
    }else{
        
        fprintf(stderr,"Vertex Shader was loaded successfully\n");
        
    }
    
    if(loadShaderFile(uFragmentShaderProgram, FragmentShader)==false){
        
        glDeleteShader(VertexShader);
        glDeleteShader(FragmentShader);
        fprintf(stderr, "The shader at %s could not be found.\n", uFragmentShaderProgram);
    }else{
        
        fprintf(stderr,"Fragment Shader was loaded successfully\n");
        
    }
    
    //3. Compile both shader objects
    glCompileShader(VertexShader);
    glCompileShader(FragmentShader);
    
    //3a. Check for errors in the compilation
    GLint testVal;
    
    //3b. Check if vertex shader object compiled successfully
    glGetShaderiv(VertexShader, GL_COMPILE_STATUS, &testVal);
    if(testVal == GL_FALSE)
    {
        char infoLog[1024];
        glGetShaderInfoLog(VertexShader, 1024, NULL, infoLog);
        fprintf(stderr, "The shader at %s failed to compile with the following error:\n%s\n", uVertexShaderProgram, infoLog);
        glDeleteShader(VertexShader);
        glDeleteShader(FragmentShader);
        
    }else{
        fprintf(stderr,"Vertex Shader compiled successfully\n");
    }
    
    //3c. Check if fragment shader object compiled successfully
    glGetShaderiv(FragmentShader, GL_COMPILE_STATUS, &testVal);
    if(testVal == GL_FALSE)
    {
        char infoLog[1024];
        glGetShaderInfoLog(FragmentShader, 1024, NULL, infoLog);
        fprintf(stderr, "The shader at %s failed to compile with the following error:\n%s\n", uFragmentShaderProgram, infoLog);
        glDeleteShader(VertexShader);
        glDeleteShader(FragmentShader);
        
    }else{
        fprintf(stderr,"Fragment Shader compiled successfully\n");
    }
    
    
    //4. Create a shader program object
    uProgramObject = glCreateProgram();
    
    //5. Attach the shader objects to the shader program object
    glAttachShader(uProgramObject, VertexShader);
    glAttachShader(uProgramObject, FragmentShader);
    
    //6. Link both shader objects to the program object
    glLinkProgram(uProgramObject);
    
    //6a. Make sure link had no errors
    glGetProgramiv(uProgramObject, GL_LINK_STATUS, &testVal);
    if(testVal == GL_FALSE)
    {
        char infoLog[1024];
        glGetProgramInfoLog(uProgramObject, 1024, NULL, infoLog);
        fprintf(stderr,"The programs %s and %s failed to link with the following errors:\n%s\n",
                uVertexShaderProgram, uFragmentShaderProgram, infoLog);
        glDeleteProgram(uProgramObject);
        
    }else{
        fprintf(stderr,"Shaders linked successfully\n");
    }
    
	
    // These are no longer needed
    glDeleteShader(VertexShader);
    glDeleteShader(FragmentShader);
    
    //7. Use the program
    glUseProgram(uProgramObject);
}


#pragma mark - Load, compile and link shaders to program

bool Joystick::loadShaderFile(const char *szFile, GLuint shader)
{
    GLint shaderLength = 0;
    FILE *fp;
	
    // Open the shader file
    fp = fopen(szFile, "r");
    if(fp != NULL)
    {
        // See how long the file is
        while (fgetc(fp) != EOF)
            shaderLength++;
		
        // Allocate a block of memory to send in the shader
        //assert(shaderLength < MAX_SHADER_LENGTH);   // make me bigger!
        if(shaderLength > MAX_SHADER_LENGTH)
        {
            fclose(fp);
            return false;
        }
		
        // Go back to beginning of file
        rewind(fp);
		
        // Read the whole file in
        if (shaderText != NULL)
            fread(shaderText, 1, shaderLength, fp);
		
        // Make sure it is null terminated and close the file
        shaderText[shaderLength] = '\0';
        fclose(fp);
    }
    else
        return false;
	
    // Load the string
    loadShaderSrc((const char *)shaderText, shader);
    
    return true;
}

// Load the shader from the source text
void Joystick::loadShaderSrc(const char *szShaderSrc, GLuint shader)
{
    GLchar *fsStringPtr[1];
    
    fsStringPtr[0] = (GLchar *)szShaderSrc;
    glShaderSource(shader, 1, (const GLchar **)fsStringPtr, NULL);
}

#pragma mark - Tear down of OpenGL
void Joystick::teadDownOpenGL(){
    
    glDeleteBuffers(1, &vertexBufferJoyStickBackgroundObject);
    glDeleteVertexArraysOES(1, &vertexArrayJoyStickBackgroundObject);
    
    
    if (joystickBackgroundShaderprogramObject) {
        glDeleteProgram(joystickBackgroundShaderprogramObject);
        joystickBackgroundShaderprogramObject = 0;
        
    }
    
}