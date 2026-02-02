varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;

uniform sampler2D uDayTexture;
uniform sampler2D uNightTexture;
uniform sampler2D uSpecularTexture;
uniform vec3 uSunDirection;
uniform vec3 uAtmosphereDayColor;
uniform vec3 uAtmosphereTwilightColor;

void main()
{
    vec3 viewDirection = normalize(vPosition - cameraPosition);
    vec3 normal = normalize(vNormal);
    vec3 color = vec3(0.0);

    // sun direction
    vec3 sunDirection = uSunDirection;
    float sunOrientation = dot(sunDirection, normal);

    // Day / night color
    float dayMix = smoothstep(-0.25, 0.5,sunOrientation);
    vec3 dayColor = texture(uDayTexture,vUv).rgb;
    vec3 nightColor = texture(uNightTexture,vUv).rgb;
    color = mix(nightColor,dayColor,dayMix);

    // Specular coluds color
    vec2 specularCloudsColor = texture(uSpecularTexture,vUv).rg;
    // Clouds
    float coludsMix = smoothstep(0.5,1.0,specularCloudsColor.g);
    coludsMix *= dayMix;
    color = mix(color,vec3(1.0),coludsMix);

    // Fresnel
    float fresnel = dot(viewDirection,normal) + 1.0;
    fresnel = pow(fresnel,2.0);

    // Atmosphere
    float atmosphereDayMix = smoothstep(-0.5, 1.0,sunOrientation);
    vec3 atmosphereColor = mix(uAtmosphereDayColor,uAtmosphereTwilightColor,atmosphereDayMix);
    color = mix(color,atmosphereColor,fresnel * atmosphereDayMix);

    // speculare
    vec3 reflection = reflect(-sunDirection, normal);
    float speculare = -dot(reflection, viewDirection);

    speculare = max(speculare,0.0);
    speculare = pow(speculare,32.0);
    speculare *= specularCloudsColor.r;

    vec3 speculaColor = mix(vec3(1.0),atmosphereColor,fresnel);
    color += speculare*speculaColor;

    // Final color
    gl_FragColor = vec4(color, 1.0);
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}