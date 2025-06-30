#ifndef MATERIAL_FUNCTIONS
#define MATERIAL_FUNCTIONS

#include "helper_functions.hlsl"
#include "global_variables.hlsl"



void createDefaultMaterialParams_float(float index, float3 baseColorIn, float3 specularColorIn, float specularStrengthIn,
float shininessIn,  out float indexOut)
{
    for (int i = 0; i <= 10; i++)
    {
        if (i == index)
        {
            _baseColorFloat[i] = baseColorIn;
            _specularColorFloat[i] = specularColorIn;
            _specularStrengthFloat[i] = specularStrengthIn;
            _shininessFloat[i] = shininessIn;

            /*
            _roughnessFloat[i] = roughnessIn;
            _metallicFloat[i] = metallicIn;
            _rimPowerFloat[i] = rimPowerIn;
            _fakeSpecularPowerFloat[i] = fakeSpecularPowerIn;
            _fakeSpecularColorFloat[i] = fakeSpecularColorIn;

            _iorFloat[i] = iorIn;
            _refractionStrengthFloat[i] = refractionStrengthIn;
            _refractionTintFloat[i] = refractionTintIn;*/
            break;
        }
    }
    indexOut = index + 1;
}

#endif