<div class="container">
    <h1 class="main-heading">Tutorial: Shrine</h1>
    <blockquote class="author">by Utku Alkan</blockquote>
</div>

This tutorial builds a magical shrine. The scene features a mystical floating torus, orbiting spheres, hovering octahedrons, tall prism pillars, animated ellipsoid "eggs," and even a glowing dolphin spirit.

---

## Step-by-Step

### 1. Initialize Fragment Shader

```hlsl
float4 frag (Varyings IN) : SV_Target
{
    float2 uv;
    float index;
    float3x3 camMat = float3x3(1,0,0, 0,1,0, 0,0,1);

    float4 hitPos, hitPos1, hitPos2;
    float hitID, hitID1, hitID2;
    float3 normal, normal1, normal2;
    float3 rayDir, rayDir1, rayDir2;

    float3 colorOut1, colorOut2, colorOut3, colorOut;

    // temp variables
    float temp;
    float3 size_temp;
    float radius_temp;
    float3 position_temp;
    float3 color_temp;

    rotateViaMouse_float(camMat);
    computeFragmentCoordinates_float(IN.uv, 10, 10, uv);
```

### 2. Shrine Base Platform

```hlsl
addRoundBox_float(0, float3(0, -2, 0), float3(6, 0.5, 6), 0.3, float3(0, 1, 0), 0, 
    float3(0.1, 0.1, 0.1), float3(0.5, 0.5, 0.5), 0.1, 64, 0, index);
```

### 3. Central Torus

```hlsl
addTorus_float(index, float3(0, 2, 0), 1.0, 0.25, float3(0, 1, 0), 0, 
    float3(0.2, 0.5, 1), float3(1, 1, 1), 0.5, 128, 0, index);
```

### 4. Orbiting Spheres Around Torus

```hlsl
for (int i = 0; i < 6; ++i)
{
    float angle = i * 3.14159 * 2.0 / 6.0;
    float3 pos = float3(cos(angle) * 2.0, 2.0, sin(angle) * 2.0);

    orbitObjectAroundPoint_float(pos, float3(0, 2, 0), float3(0, 1, 0), 0, 0.5, 0, pos, angle);

    addSphere_float(index, pos, 0.3, float3(0,1,0), 0, 
        float3(0.8, 0.2, 0.2), float3(1,1,1), 0.4, 64, 0, index);
}
```

### 5. Floating Octahedron Crystals

```hlsl
// Right crystal
tween3D_float(float3(2.5, 3, 0), float3(2.5, 5, 0), 2.0, TWEEN_SINE_INOUT, 0.0, true, position_temp);
addOctahedron_float(index, position_temp, 0.6, float3(1, 0, 0), 0.4, 
    float3(0.3, 1.0, 0.9), float3(1, 1, 1), 0.7, 96, 0, index);

// Left crystal
tween3D_float(float3(-2.5, 3, 0), float3(-2.5, 5, 0), 2.0, TWEEN_SINE_INOUT, 0.0, true, position_temp);
addOctahedron_float(index, position_temp, 0.6, float3(1, 0, 0), -0.4, 
    float3(0.3, 1.0, 0.9), float3(1, 1, 1), 0.7, 96, 0, index);
```

### 6. Hexagonal Pillars at Corners

```hlsl
addHexPrism_float(index, float3(3, 0, 3), 2, float3(0, 1, 0), 0, 
    float3(0.2, 0.2, 0.6), float3(1, 1, 1), 0.4, 64, 0, index);

addHexPrism_float(index, float3(-3, 0, 3), 2, float3(0, 1, 0), 0, 
    float3(0.2, 0.2, 0.6), float3(1, 1, 1), 0.4, 64, 0, index);

addHexPrism_float(index, float3(3, 0, -3), 2, float3(0, 1, 0), 0, 
    float3(0.2, 0.2, 0.6), float3(1, 1, 1), 0.4, 64, 0, index);

addHexPrism_float(index, float3(-3, 0, -3), 2, float3(0, 1, 0), 0, 
    float3(0.2, 0.2, 0.6), float3(1, 1, 1), 0.4, 64, 0, index);
```

### 7. Floating Ellipsoid "Eggs"

```hlsl
tween1D_float(0.1, 2, 2.0, TWEEN_SINE_INOUT, 0.0, true, temp);

addEllipsoid_float(index, float3(0, 2, 2), float3(0.6, temp, 0.6), float3(0, 1, 0), 0.2, 
    float3(1.0, 0.8, 0.4), float3(1, 1, 1), 0.5, 64, 0, index);

addEllipsoid_float(index, float3(0, 2, -2), float3(0.6, temp, 0.6), float3(0, 1, 0), -0.2, 
    float3(1.0, 0.8, 0.4), float3(1, 1, 1), 0.5, 64, 0, index);
```

### 8. Dolphin Spirit

```hlsl
addDolphin_float(index, float3(0, 3.5, 5), 0, 1, float3(0, 1, 0), 0, 
    float3(0.7, 0.9, 1.0), float3(1, 1, 1), 0.8, 96, index);
```

### 9. Raymarching, Lighting, and Water

```hlsl
raymarch_float(1, camMat, index, uv, hitPos1, normal1, hitID1, rayDir1);
computeWater_float(1, camMat, uv, hitPos2, normal2, hitID2, rayDir2);

getMinimum_float(hitPos1, normal1, hitID1, hitPos2, normal2, hitID2, hitPos, normal, hitID);

pointLight_float(hitPos, normal, hitID, rayDir1, _LightPosition, float3(1,1,1), 5, 0.05, colorOut1);
sunriseLight_float(hitPos, normal, hitID, rayDir1, colorOut3);
applyToonLighting_float(hitPos, normal, hitID, _LightPosition, colorOut2);

colorOut = colorOut1 + colorOut2 + colorOut3;

return float4(colorOut, 1);
```

---

## The Result

This shrine scene brings together symmetrical geometry and elegant animation.
    <figure markdown="span">
    ![Unity Shrine](../images/userShaders/shrine.gif){ width="900" }
    </figure>


## The Whole Code
??? "Shrine User Shader"
    ```hlsl
    Shader "Custom/Shrine"
    {
        Properties
        {
            _LightPosition ("Light Position", Vector) = (5.0, 5.0, 5.0)
        }

        SubShader
        {
            Tags { "RenderType"="Opaque" }
            LOD 300

            Pass
            {
                HLSLPROGRAM
                #pragma vertex vert
                #pragma fragment frag


                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.tudresden.proceduralshaderframeworkpackage/Runtime/scripts/sdf_functions.hlsl"
                #include "Packages/com.tudresden.proceduralshaderframeworkpackage/Runtime/scripts/basics_functions.hlsl"
                #include "Packages/com.tudresden.proceduralshaderframeworkpackage/Runtime/scripts/lighting_functions.hlsl"
                #include "Packages/com.tudresden.proceduralshaderframeworkpackage/Runtime/scripts/animation_functions.hlsl"
                #include "Packages/com.tudresden.proceduralshaderframeworkpackage/Runtime/scripts/water_surface.hlsl"
                #include "Packages/com.tudresden.proceduralshaderframeworkpackage/Runtime/scripts/tween_functions.hlsl"


                struct Attributes
                {
                    float4 positionOS : POSITION;
                    float2 uv : TEXCOORD0;
                };

                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float2 uv : TEXCOORD0;
                    float3 worldPos : TEXCOORD1;
                };

                float4 _Color;
                float _TimeSpeed;
                float3 _LightPosition;

                Varyings vert (Attributes IN)
                {
                    Varyings OUT;

                    float3 pos = IN.positionOS.xyz;
                    float time = _Time.y * _TimeSpeed;



                    OUT.positionCS = TransformObjectToHClip(pos);
                    OUT.uv = IN.uv;
                    OUT.worldPos = TransformObjectToWorld(pos);

                    return OUT;
                }


                float4 frag (Varyings IN) : SV_Target
                {
                    float2 uv;
                    float index;
                    float3x3 camMat = float3x3( 1,0,0, 0,1,0, 0,0,1 );


                    float4 hitPos;
                    float4 hitPos1;
                    float4 hitPos2;

                    float hitID;
                    float hitID1;
                    float hitID2;


                    float3 normal;
                    float3 normal1;
                    float3 normal2;

                    float3 rayDir;
                    float3 rayDir1;
                    float3 rayDir2;


                    float3 colorOut1;
                    float3 colorOut2;
                    float3 colorOut3;

                    float3 colorOut;


                    // all temps
                    float temp;
                    float3 size_temp;
                    float radius_temp;
                    float3 position_temp;
                    float3 color_temp;


                    rotateViaMouse_float(camMat);

                    computeFragmentCoordinates_float(IN.uv, 10, 10, uv);
                    
                
                    // Base platform
                    addRoundBox_float(0, float3(0, -2, 0), float3(6, 0.5, 6), 0.3, float3(0, 1, 0), 0, float3(0.1, 0.1, 0.1), float3(0.5, 0.5, 0.5), 0.1, 64, 0, index);

                    // Torus in center
                    addTorus_float(index, float3(0, 2, 0), 1.0, 0.25, float3(0, 1, 0), 0, float3(0.2, 0.5, 1), float3(1, 1, 1), 0.5, 128, 0, index);

                    // Floating spheres orbiting torus
                    for (int i = 0; i < 6; ++i)
                    {

                        float angle = i * 3.14159 * 2.0 / 6.0;
                        float3 pos = float3(cos(angle) * 2.0, 2.0, sin(angle) * 2.0);

                        orbitObjectAroundPoint_float(pos, float3(0, 2, 0), float3(0, 1, 0), 0, 0.5, 0, pos, angle);

                        addSphere_float(index, pos, 0.3, float3(0,1,0), 0, float3(0.8, 0.2, 0.2), float3(1,1,1), 0.4, 64, 0, index);
                    }

                    // Octahedron crystals hovering above

                    tween3D_float(float3(2.5, 3, 0), float3(2.5, 5, 0), 2.0, TWEEN_SINE_INOUT, 0.0, true, position_temp);
                    addOctahedron_float(index, position_temp, 0.6, float3(1, 0, 0), 0.4, float3(0.3, 1.0, 0.9), float3(1, 1, 1), 0.7, 96, 0, index);

                    tween3D_float(float3(-2.5, 3, 0), float3(-2.5, 5, 0), 2.0, TWEEN_SINE_INOUT, 0.0, true, position_temp);
                    addOctahedron_float(index, position_temp, 0.6, float3(1, 0, 0), -0.4, float3(0.3, 1.0, 0.9), float3(1, 1, 1), 0.7, 96, 0, index);

                    // Hex prism pillars at corners
                    addHexPrism_float(index, float3(3, 0, 3), 2, float3(0, 1, 0), 0, float3(0.2, 0.2, 0.6), float3(1, 1, 1), 0.4, 64, 0, index);
                    addHexPrism_float(index, float3(-3, 0, 3), 2, float3(0, 1, 0), 0, float3(0.2, 0.2, 0.6), float3(1, 1, 1), 0.4, 64, 0, index);
                    addHexPrism_float(index, float3(3, 0, -3), 2, float3(0, 1, 0), 0, float3(0.2, 0.2, 0.6), float3(1, 1, 1), 0.4, 64, 0, index);
                    addHexPrism_float(index, float3(-3, 0, -3), 2, float3(0, 1, 0), 0, float3(0.2, 0.2, 0.6), float3(1, 1, 1), 0.4, 64, 0, index);

                    // Floating ellipsoid eggs
                    tween1D_float(0.1, 2, 2.0, TWEEN_SINE_INOUT, 0.0, true, temp);

                    addEllipsoid_float(index, float3(0, 2, 2), float3(0.6, temp, 0.6), float3(0, 1, 0), 0.2, float3(1.0, 0.8, 0.4), float3(1, 1, 1), 0.5, 64, 0, index);
                    addEllipsoid_float(index, float3(0, 2, -2), float3(0.6, temp, 0.6), float3(0, 1, 0), -0.2, float3(1.0, 0.8, 0.4), float3(1, 1, 1), 0.5, 64, 0, index);

                    // Dolphin spirit
                    addDolphin_float(index, float3(0, 3.5, 5), 0, 1, float3(0, 1, 0), 0, float3(0.7, 0.9, 1.0), float3(1, 1, 1), 0.8, 96, index);



                    raymarch_float(1, camMat, index, uv, hitPos1, normal1, hitID1, rayDir1);
                    computeWater_float(1, camMat, uv, hitPos2, normal2, hitID2, rayDir2);

                    getMinimum_float(hitPos1, normal1, hitID1, hitPos2, normal2, hitID2, hitPos, normal, hitID);


                    pointLight_float(hitPos, normal, hitID, rayDir1, _LightPosition, float3(1,1,1), 5, 0.05,  colorOut1);
                    sunriseLight_float(hitPos, normal, hitID, rayDir1, colorOut3);
                    applyToonLighting_float(hitPos, normal, hitID, _LightPosition, colorOut2);

                    colorOut = colorOut1 + colorOut2 + colorOut3;


                    return float4(colorOut,1);
                }
                ENDHLSL
            }
        }
    }
    ```