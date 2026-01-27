uniform vec3 uDepthColor;
uniform vec3 uSurfaceColor;
uniform float uColorOffset;
uniform float uColorMultiplier;

varying float vElevation;
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

void main(){
	vec3 normal = normalize(vNormal);
  vec3 viewDirection = normalize(vPosition - cameraPosition);

	// Light
	vec3 light = vec3(0.);
	light += directionLight(
		vec3(1.0),
		1.0,
		normal,
		vec3(-1.0,0.5,0.0),
		viewDirection,
		30.0
		);

  float eleValue = (vElevation + uColorOffset) * uColorMultiplier ;
	eleValue = smoothstep(0.0,1.0,eleValue);
  vec3 mixedColor = mix(uDepthColor, uSurfaceColor, eleValue);

	mixedColor *= light;
  gl_FragColor = vec4(mixedColor,1.0);
	#include <tonemapping_fragment>
  #include <colorspace_fragment>
}