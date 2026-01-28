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