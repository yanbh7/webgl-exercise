uniform vec3 uDepthColor;
uniform vec3 uSurfaceColor;
uniform float uColorOffset;
uniform float uColorMultiplier;

varying float vElevation;
varying vec3 vNormal;
varying vec3 vPosition;

#include /src/common/glsl/ambientLight.glsl
#include /src/common/glsl/directionLight.glsl
#include /src/common/glsl/pointLight.glsl

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