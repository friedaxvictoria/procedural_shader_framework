#ifndef MATERIAL_FUNCTIONS
#define MATERIAL_FUNCTIONS

#include "helper_functions.hlsl"
#include "global_variables.hlsl"

/*void createDefaultMaterialParams_half(half index, half3 baseColorIn, half3 specularColorIn, half specularStrengthIn,
half shininessIn, half roughnessIn, half metallicIn, half rimPowerIn, half fakeSpecularPowerIn, half3 fakeSpecularColorIn,
half iorIn, half refractionStrengthIn, half3 refractionTintIn, out half indexOut)*/

void createDefaultMaterialParams_half(half index, half3 baseColorIn, half3 specularColorIn, half specularStrengthIn,
half shininessIn, out half indexOut)
{
    for (int i = 0; i <= 10; i++)
    {
        if (i == index)
        {
            _baseColorHalf[i] = baseColorIn;
            _specularColorHalf[i] = specularColorIn;
            _specularStrengthHalf[i] = specularStrengthIn;
            _shininessHalf[i] = shininessIn;

            /*
            _roughnessHalf[i] = roughnessIn;
            _metallicHalf[i] = metallicIn;
            _rimPowerHalf[i] = rimPowerIn;
            _fakeSpecularPowerHalf[i] = fakeSpecularPowerIn;
            _fakeSpecularColorHalf[i] = fakeSpecularColorIn;

            _iorHalf[i] = iorIn;
            _refractionStrengthHalf[i] = refractionStrengthIn;
            _refractionTintHalf[i] = refractionTintIn;*/
            break;
        }
    }
    indexOut = index + 1;
}

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