#ifndef BASICS_FUNCTIONS
#define BASICS_FUNCTIONS

#include "helper_functions.hlsl"
#include "global_variables.hlsl"

void computeUV_float(float2 fragCoord, out float2 uv)
{
    uv = fragCoord.xy * 2 - 1;

    //necessary because instantiations are not used in compiled code --> define in the beginning for default value that can be overridden
    _rayOrigin = float3(0, 0, 7);
    _raymarchStoppingCriterium = 50;
}

// after lighting function
void combinedColour_float(float4 hitPos1, float4 hitPos2, float3 colour1, float3 colour2, out float3 colour)
{
    if (hitPos1.w > _raymarchStoppingCriterium && hitPos2.w > _raymarchStoppingCriterium)
    {
        colour = float3(0, 0, 0);
    }
    else if (hitPos1.w < hitPos2.w)
    {
        colour = colour1;
    }
    else
    {
        colour = colour2;
    }
}


// before lighting function
void getMinimum_float(float4 hitPos1, float4 hitPos2, float3 normal1, float3 normal2, float hitIndex1, float hitIndex2, out float4 hitPos, out float3 normal, out float hitIndex)
{
    if (hitPos1.w < hitPos2.w && hitPos1.w < _raymarchStoppingCriterium)
    {
        hitPos = hitPos1;
        normal = normal1;
        hitIndex = hitIndex1;
    }
    else
    {
        hitPos = hitPos2;
        normal = normal2;
        hitIndex = hitIndex2;
    }
}

// inspo: https://www.shadertoy.com/view/fl3fRf 
void changingColor_float(float3 seedColor, float speed, out float3 color)
{
    float3 rootColor = asin(2 * seedColor - 1);
    color = 0.5 + 0.5 * sin(_Time.y * speed * rootColor);
}

#endif