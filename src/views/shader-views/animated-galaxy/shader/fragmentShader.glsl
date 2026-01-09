varying vec3 vColor;

void main(){
  // Diffuse point
  // float strength = distance(gl_PointCoord,vec2(0.5));
  // strength = 1.0 - strength * 2.0;

  // Light point
  float strength = distance(gl_PointCoord,vec2(0.5));
  strength = pow(1.0 - strength,10.0);

  // final
  vec3 color = mix(vec3(0.0),vColor,strength);

  gl_FragColor = vec4(color,1.0);

}