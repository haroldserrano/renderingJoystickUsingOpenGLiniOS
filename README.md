# Rendering a joystick using OpenGL ES 2.0 in iOS

## Introduction
Adding a joystick to your mobile game is quite simple. A joystick is composed of two elements. These elements are the **base** and a **stick**. In mobile games, only the stick is allowed to move whenever a touch is detected. The displacement of the stick is used to determine the angle and by how much to move a game character.

### Objective
In this project you are going to learn how to add a joystick to a mobile game. At the end of this project you will have implemented a joystick as shown in figure 1.

##### Figure 1. A joystick in a mobile game
![](https://dl.dropboxusercontent.com/u/107789379/CGDemy/blogimages/joystickWithWeapon.png "Joystick in a mobile game")

This is a hands-on project. Download the [XCode template project](https://dl.dropboxusercontent.com/u/107789379/haroldserrano/MakeOpenGLProject/Adding%20a%20joystick%20to%20a%20game/Template-Skeleton.zip) and feel free to code along.

### Things to know
I recommend you to read the following projects before moving on:

* [How to apply textures to a game character using OpenGL ES.](http://www.haroldserrano.com/blog/how-to-apply-textures-to-a-character-in-ios)

## Implementing a joystick
A joystick is composed of two elements. These elements are the *base* and *stick*. Figure 2 shows both of these elements side by side. The left image represents the base of the joystick. This element will be stationary. The image on the right represents the stick. In a mobile game, the stick is placed on top of the base. Only the stick is allowed to move within the area of the joystick.

##### Figure 2. Elements of a Joystick
![joystick elements](https://dl.dropboxusercontent.com/u/107789379/CGDemy/blogimages/joyStickImageTextures.png)

### Joystick Class
We will implement a C++ class representing our joystick. our **Joystick** class will contain all the necessary methods required to render the object on the screen. 

Up to now, our game characters and buttons have required the generation of only one OpenGL buffer. One buffer has been sufficient to load vertex and UV data. 

Generating one OpenGL buffer will not suffice for a joystick. A joystick is composed of two elements, each performing different behaviors, and requiring their own texture image. 

Therefore, the joystick class will treat each element separately. The joystick class will create two different OpenGL buffers. It will create two sets of space transformations and it will load two different set of textures. 

### Setting the dimension of the joystick
To load the right vertex coordinates we need to know the desired joystick’s dimension. This data is acquired in the constructor method of the Joystick class.

Open up the **Joystick.mm** file and head to the constructor method **Joystick()**. Copy what is shown in listing 1.

##### Listing 1. Joystick Constructor
<pre>
<code class=“language-c”>
Joystick::Joystick(float uJoystickXPosition, float uJoystickYPosition, const char* uBackgroundJoystickImage, float uJoystickBackgroundWidth,float uJoystickBackgroundHeight, const char* uJoystickImage,float uJoystickWidth,float uJoystickHeight,float uScreenWidth,float uScreenHeight){

//1. screen width and height
screenWidth=uScreenWidth;
screenHeight=uScreenHeight;

//2. Joystick driver & background width and height
joystickDriverWidth=uJoystickWidth;
joystickDriverHeight=uJoystickHeight;

joystickBackgroundWidth=uJoystickBackgroundWidth;
joystickBackgroundHeight=uJoystickBackgroundHeight;

//3. set the reference of both Joystick element images
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

//7. set the vertex and UV coordinates for both joystick elements
setJoystickBackgroundVertexAndUVCoords();
setJoystickDriverVertexAndUVCoords();

}
</code>
</pre>

In this method we set the dimensions, position and texture reference for both elements (lines 1-4). We also calculate the touch boundaries of the joystick as shown in line 5. After that, we simply call two methods in charge of calculating the vertices and UV coordinates for each element (line 7).

Open up the **Joystick.mm** file and head to the  **setJoystickBackgroundVertexAndUVCoords()** method. Copy what is shown in listing 2.

##### Listing 2. Setting the vertices and UV coordinates
<pre>
<code class=“language-c”>
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
</code>
</pre>

Keep in mind that we need to determine the vertices and UV coordinates for each element. Listing 2 shows the method that determines the vertices and UV coordinates of the joystick’s base.

In line 1, we simply scale the joystick’s base dimension with the screen dimension. 

The vertices of the base are simply the vertices of a unit  square, scaled by the dimensions of the joystick. These vertices are set in line 2. 

Lines 3-4 simply sets the UV coordinates and index value for the joystick’s base.

The same logic is applied in determining the vertices and UV coordinates for the stick. If interested take a look at the **setJoystickDriverVertexAndUVCoords()** method.

### Loading data into OpenGL Buffers

Once we have the vertices and UV coordinates for each element, we are ready to [load them into OpenGL buffers](http://www.haroldserrano.com/blog/loading-vertex-normal-and-uv-data-onto-opengl-buffers).

We load data into the OpenGL buffers using these two methods 
**setupJoyStickDriverOpenGL()** and **setupJoyStickBackgroundOpenGL()**.

Open up the **Joystick.mm** file. Look for the **setupJoyStickBackgroundOpenGL()** method and go to lines 5a-5c. Copy what is shown in listing 3.

##### Listing 3. Loading up the vertices and UV coords into openGL buffers for the Joystick base
<pre>
<code class=“language-c”>
void Joystick::setupJoyStickBackgroundOpenGL(){

//...

//5a. Dump the data into the Buffer

glBufferData(GL_ARRAY_BUFFER, sizeof(joystickBackgroundVertices)+sizeof(joystickBackgroundUVCoords), NULL, GL_STATIC_DRAW);

//5b. Load vertex data with glBufferSubData
glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(joystickBackgroundVertices), joystickBackgroundVertices);

//5c. Load uv data with glBufferSubData
glBufferSubData(GL_ARRAY_BUFFER, sizeof(joystickBackgroundVertices), sizeof(joystickBackgroundUVCoords), joystickBackgroundUVCoords);

//...

}
</code>
</pre>

In line 5a, we simply allocate memory for our buffer. Line 5b and 5c loads the vertex and UV data into the buffer, respectively.

The same process is done for the stick. 

Open up the **Joystick.mm** file. Look for the **setupJoyStickDriverOpenGL()** method and go to lines 5a-5c. Copy what is shown in listing 4.

##### Listing 4. Loading up the vertices and UV coords into openGL buffers for the stick
<pre>
<code class=“language-c”>
void Joystick::setupJoyStickDriverOpenGL(){

//...

//5a. Dump the data into the Buffer

glBufferData(GL_ARRAY_BUFFER, sizeof(joystickDriverVertices)+sizeof(joystickDriverUVCoords), NULL, GL_STATIC_DRAW);

//5b. Load vertex data with glBufferSubData
glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(joystickDriverVertices), joystickDriverVertices);

//5c. Load uv data with glBufferSubData
glBufferSubData(GL_ARRAY_BUFFER, sizeof(joystickDriverVertices), sizeof(joystickDriverUVCoords), joystickDriverUVCoords);

//...

}
</code>
</pre>

### Loading the textures
Each joystick element contains its own image-texture. Therefore, we need to activate a *texture-unit* and texture buffer for each element.

Let’s load the image-texture for the joystick base.

Open up the **Joystick.mm** file. Look for the **setupJoyStickBackgroundOpenGL()** method. Go to lines 14-18. Copy what is shown in listing 5.

##### Listing 5. Loading the Joystick Background texture
<pre>
<code class=“language-c”>
void Joystick::setupJoyStickBackgroundOpenGL(){

//...

//SET Joystick base TEXTURE
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

//...

}
</code>
</pre>

In this method we activate a *texture-unit* (line 14). We then create and bind a *texture buffer* as shown in lines 15-16. We decompress the image into raw format and set the texture parameters in lines 17-17c. We then get a reference to the image by getting the location of the *uniform sampler2D* as shown in line 18.

The same process is done for the stick. However, instead of using **GL\_TEXTURE0** as the texture-unit, we use **GL\_TEXTURE1** instead.

Open up the **Joystick.mm** file. Look for the **setupJoyStickDriverOpenGL()** method. Go to lines 14-18. Copy what is shown in listing 6.

##### Listing 6. Loading the Joystick Driver texture
<pre>
<code class=“language-c”>
void Joystick::setupJoyStickDriverOpenGL(){

//...

//SET Joystick driver TEXTURE
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
  
//...
}
</code>
</pre>


### Setting the Projective space

The space transformation for the joystick is quite simple. The joystick does not need to be rotate, only translated. Thus, it’s *model* space is simply set as an *Identity* matrix. The *Identity* matrix is then translated to a particular location. 

The *World* and *Camera* space are omitted from this transformation. We do not need to take them into account and are thus treated as *Identity* matrices. Or in this case, not used at all.

> If we were to take the *camera* space into account, a camera rotation, would result into a joystick rotation as well.

The *Projective* space of the joystick is set to an *Orthogonal* view. The reason is because the joystick will be shown as a two-dimensional object and not as a three-dimensional one.

Open up file **Joystick.mm**. Go to the *setJoyStickBackgroundTransformation()* method and copy what is shown in listing 7.

##### Listing 7. Setting the space transformation for the joystick base
<pre>
<code class=“language-c”>
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
</code>
</pre>

The joystick background’s *model* space is translated to the desire *x* and *y* position on the screen (lines 1-2).

We set the *Perspective* space of the background to a *orthogonal view* ranging from [-1,1], as shown in line 3.

The *Model-World-Camera-Projection space* is then calculated in line 4.

The same process is done for the stick.

Open up file **Joystick.mm**. Go to the *setJoyStickDriverTransformation()* method and copy what is shown in listing 8.

##### Listing 8. Setting the space transformation for the stick
<pre>
<code class=“language-c”>
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
</code>
</pre>

### Rendering the Joystick
Rendering the joystick requires two steps. We render each element at a time. We first enable the shaders and the appropriate *vertex array objects*. We then activate the appropriate texture units and render our element. Then we repeat the process for the second element.

Open up file **Joystick.mm**. Go to the *draw()* method and copy what is shown in listing 9.

##### Listing 9. Rendering the Joystick
<pre>
<code class=“language-c”>
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
</code>
</pre>

During our rendering phase, we first render the joystick base then we render the stick.

In line 1 we enable the *blending* operation. Blending allows incoming pixels to be blend in with pixels already stored in the framebuffer. It makes the joystick’s pixels blend in with any other 3D model’s pixels.

Since we are rendering two elements, each with their own shaders and *Vertex Array Objects*, we need to activate the appropriate shader program (line 2). We then bind the *Vertex Array Object* for the element (line 3). The appropriate *texture-unit* is enabled along with the texture object (line 4-5). The rendering for the joystick base is then performed in line 7.

The same process is performed for the stick element. We activate  the corresponding shader program, *VAO*, *texture-unit*, etc. 

### Updating the Joystick
The only place in code where we do not take care of the joystick base is in the *update()* method. In this method, we check if a touch coordinate is within the area of the joystick. If it is, the stick is moved to that coordinate. This creates the illusion that you are moving the stick. 

We calculate the stick’s displacement, from its natural position to its new position, and feed this value to a game character.

Open up file **Joystick.mm**. Go to the *update()* method and copy what is shown in listing 10.

##### Listing 10. Updating the Joystick
<pre>
<code class=“language-c”>
void Joystick::update(float touchXPosition,float touchYPosition){

//Set the shader program
glUseProgram(joystickDriverShaderprogramObject);

//Bind the VAO
glBindVertexArrayOES(vertexArrayJoyStickDriverObject);

//1. check if the touch is within the boundaries of the joystick

if (touchXPosition>=left && touchXPosition&lt=right) {

  if (touchYPosition>=bottom && touchYPosition&lt=top) {

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
}else{

//8. else, set it to false
isPressed=false;

}

//unbind the VAO
glBindVertexArrayOES(0);

}
</code>
</pre>

In this method, any update to our stick element occurs only if the touch coordinate is within the boundaries of the joystick (line 1). If the touch occurred within the boundaries, we set a new space transformation for the stick as shown in lines (3-6).
We then calculate the displacement of the stick in line 7.

### Implementing the Shaders
The shaders for each element is very basic. In the vertex shader, we simply transform each vertex by the correct space transformation. The Fragment shader simply samples the texture image.

If you want to look at the shaders, they are implemented in the following files: 

* JoystickDriverShader.vsh
* JoystickDriverShader.fsh
* JoystickBackgroundShader.vsh
* JoystickBackgroundShader.fsh

If you are not familiar with shaders, please take a look at this [post](http://www.haroldserrano.com/blog/what-is-a-shader-in-computer-graphics).

### Creating a Joystick instance
Finally, we need to create an instance of our joystick class.

Open up the *ViewController.mm* file. Go to the *viewDidLoad()* method and look for line 14. Copy what is shown in listing 11.

##### Listing 11. Creating a Joystick instance
<pre>
<code class=“language-c”>

//14. create an instance of the Joystick class
joystick=new Joystick(80,250,"joyStickBackground.png",100,100,"joystickDriver.png",60,60,self.view.bounds.size.height,self.view.bounds.size.width);

//15. begin the OpenGL setup for the joystick
joystick->setupOpenGL();

</code>
</pre>

In line 14, we simply create an instance by providing the joystick coordinates, dimensions and image references. Line 15 starts the OpenGL setup.

### Final Result
Run the project. You should see a 3D model with two buttons and a joystick as shown in figure 3. You should be able to rotate the 3D model with the joystick.

##### Figure 3. A 3D model with a joystick and two buttons
![mobile game with joystick](https://dl.dropboxusercontent.com/u/107789379/CGDemy/blogimages/joystickWithWeapon.png "Joystick in a mobile game")

###Credits
[Harold Serrano](http://www.haroldserrano.com) Author of this repository and post

###Questions
If you have any questions about this repository, feel free to contact me at http://www.haroldserrano.com/contact/
