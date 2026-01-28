uniform vec3 uColor;
varying vec3 vNormal;
varying vec3 vPosition;

#include /src/common/glsl/ambientLight.glsl
#include /src/common/glsl/directionLight.glsl
#include /src/common/glsl/pointLight.glsl

void main()
{
    vec3 normal = normalize(vNormal);
    vec3 color = uColor;
    vec3 viewDirection = normalize(vPosition - cameraPosition);
    // Light
    vec3 light = vec3(0.0);
    // ambientLight
    light += ambientLight(
      vec3(1.0), // Light color
      0.05       // Light intensity
      );

    // directionLight
    light += directionLight(
      vec3(0.1,0.1,1.0), // Light color
      1.0,               // Light intensity
      normal,            // normal
      vec3(0.0,0.0,3.0), // Light position
      viewDirection,     // view direction
      20.0
      );

    // pointLight
    light += pointLight(
      vec3(1.0,0.1,0.1), // Light color
      1.0,               // Light intensity
      normal,            // normal
      vec3(0.0,2.5,0.0), // Light position
      viewDirection,     // view direction
      20.0,
      vPosition          // position
      );

    light += pointLight(
      vec3(0.1,1.0,0.5), // Light color
      1.0,               // Light intensity
      normal,            // normal
      vec3(2.0,2.0,2.0), // Light position
      viewDirection,     // view direction
      20.0,
      vPosition          // position
      );
    color *= light;

    // Final color
    gl_FragColor = vec4(color, 1.0);
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}