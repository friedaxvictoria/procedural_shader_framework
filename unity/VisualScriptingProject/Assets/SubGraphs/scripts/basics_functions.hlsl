#ifndef BASICS_FUNCTIONS
#define BASICS_FUNCTIONS

#include "global_variables.hlsl"

//CUSTOM NODE FUNCTIONS
void computeUV_float(float2 fragCoord, float scaleUp, float scaleRight, out float2 uv)
{
    uv = fragCoord.xy * 2 - 1;
    if (scaleRight>scaleUp)
        uv.x *= scaleRight / scaleUp;
    else
        uv.y *= scaleUp / scaleRight;
}

//use after lighting function
void combinedColor_float(float4 hitPosition1, float3 color1, float4 hitPosition2, float3 color2, out float3 color)
{
    if (hitPosition1.w > _raymarchStoppingCriterium && hitPosition2.w > _raymarchStoppingCriterium)
        color = float3(0, 0, 0);
    else if (hitPosition1.w < hitPosition2.w)
        color = color1;
    else
        color = color2;
}


//use before lighting function
void getMinimum_float(float4 hitPosition1, float3 normal1, float hitIndex1, float4 hitPosition2, float3 normal2, float hitIndex2, out float4 hitPosition, out float3 normal, out float hitIndex)
{
    if (hitPosition1.w < hitPosition2.w && hitPosition1.w < _raymarchStoppingCriterium)
    {
        hitPosition = hitPosition1;
        normal = normal1;
        hitIndex = hitIndex1;
    }
    else
    {
        hitPosition = hitPosition2;
        normal = normal2;
        hitIndex = hitIndex2;
    }
}

#endif