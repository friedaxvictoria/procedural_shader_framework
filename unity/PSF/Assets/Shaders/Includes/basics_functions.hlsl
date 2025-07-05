#ifndef BASICS_FUNCTIONS
#define BASICS_FUNCTIONS

#include "helper_functions.hlsl"
#include "global_variables.hlsl"

void computeUV_float(float2 fragCoord, out float2 uv)
{
    uv = fragCoord.xy* 2 - 1;

    //necessary because instantiations are not used in compiled code --> define in the beginning for default value that can be overridden
    _rayOrigin = float3(0, 0, 7);
}

void combinedColour_float(float3 hitPos1, float3 hitPos2, float3 colour1, float3 colour2, out float3 colour)
{
    float dist1 = distance(hitPos1, _rayOrigin);
    float dist2 = distance(hitPos2, _rayOrigin);
    if (dist1 < dist2)
    {
        colour = colour1;
    }
    else
    {
        colour = colour2;
    }
}

void getMinimum_float(float3 hitPos1, float3 hitPos2, float3 normal1, float3 normal2, float hitIndex1, float hitIndex2, out float3 hitPos, out float3 normal, out float hitIndex)
{
    if (hitPos1.z < hitPos2.z && hitPos1.z != 0)
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

#endif