varying vec2 vUv;
uniform sampler2D uPerlinTexture;
uniform float uTime;

vec2 rotate2D (vec2 value,float angle){
  float s = sin(angle);
  float c = cos(angle);
  mat2 m = mat2(c,s,-s,c);
  return m * value;
}


void main(){
  vec3 newPosition = position;
  float angle = texture(uPerlinTexture,vec2(0.5,uv.y* 0.2 - uTime * 0.005)).r * 10.;
  newPosition.xz = rotate2D(newPosition.xz,angle);

  vec2 windOffset = vec2(
    texture(uPerlinTexture,vec2(0.25,uTime*0.01)).r-0.5,
    texture(uPerlinTexture,vec2(0.75,uTime*0.01)).r-0.5
  );

  windOffset *= pow(uv.y,3.0) * 10.;

  newPosition.xz += windOffset;

  vec4 modelPosition = modelMatrix * vec4(newPosition,1.);

  vec4 viewPosition = viewMatrix * modelPosition;
  vec4 projectedPosition = projectionMatrix * viewPosition;

  gl_Position = projectedPosition; 
  vUv = uv;
}