
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"


void LightDirection_half(out half3 Direction, out half DistanceAtten, out half3 LightColor)
{
  #if SHADERGRAPH_PREVIEW
    Direction = half3(0,1,0);
    DistanceAtten = 1;
    LightColor = half3(1,1,1);
  #else
    Light light = GetMainLight();
    Direction = normalize(light.direction);
    DistanceAtten = light.distanceAttenuation;
    LightColor = light.color;
  #endif
}

