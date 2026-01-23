uniform vec3 uColor;
varying vec3 vNormal;
varying vec3 vPosition;

vec3 ambientLight(vec3 lightColor,float lightIntensity) {
  return lightColor * lightIntensity;
}

vec3 directionLight(vec3 lightColor,float lightIntensity,vec3 normal, vec3 lightPosition,vec3 viewDirection,float specularPower) {
  vec3 lightDirection = normalize(lightPosition);
  vec3 lightReflection = reflect(- lightDirection,normal);

  float shading = dot(normal,lightPosition);
  shading = max(0.0,shading);

  float specular = -dot(lightReflection, viewDirection);
  specular = max(0.0,specular);
  specular = pow(specular,specularPower);
  // return vec3(specular);
  return lightColor * lightIntensity * (shading + specular);
}

vec3 pointLight(vec3 lightColor,float lightIntensity,vec3 normal, vec3 lightPosition,vec3 viewDirection,float specularPower,vec3 position) {
  vec3 lightDelta = lightPosition - position;
  float lightDistance = length(lightDelta);
  vec3 lightDirection = normalize(lightDelta);
  vec3 lightReflection = reflect(- lightDirection,normal);

  float shading = dot(normal,lightPosition);
  shading = max(0.0,shading);

  float specular = -dot(lightReflection, viewDirection);
  specular = max(0.0,specular);
  specular = pow(specular,specularPower);
  // decay
  float decay = 1.0 - lightDistance * 0.3;
  decay = max(0.,decay);
  // return vec3(specular);
  return lightColor * lightIntensity * decay * (shading + specular);
}
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