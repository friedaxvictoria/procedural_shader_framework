<div class="container">
    <h1 class="main-heading">Tutorial: Car</h1>
    <blockquote class="author">by Utku Alkan</blockquote>
</div>

This tutorial walks you through building a stylized car. The scene features a red car with windows and wheels, smoothly driving across a platform, with additional details like lighting and subtle shake using `shakeObject_float` (currently there is no shake).

> Both visual scripting and standard scripting are explained. To keep the visual results of the ShaderGraph a bit clearer, all nodes were folded and do not show the visual preview.

Once the UPM ist installed, this example can be [downloaded](../../unity.md#user-shaders). To change whether the ShaderGraph or the ShaderLab shader is applied to the material, drag-and-drop the desired one onto the corresponding material.

---

## Step-by-Step

### 1. Initialize Fragment Shader

=== "1. Visual Scripting"
    <figure markdown="span">
        ![Unity Car: Initialisiation](../images/car/carInit.png){ width="500" }
    </figure>

=== "1. Standard Scripting"
    ```hlsl
    float4 frag (Varyings IN) : SV_Target
    {
        float2 uv;
        float index;
        float3x3 camMat = float3x3( 1,0,0, 0,1,0, 0,0,1 );

        float4 hitPos1;
        float hitID1;
        float3 normal1;
        float3 rayDir1;

        float3 colorOut1, colorOut2, colorOut3, colorOut;

        // temp variables
        float temp;
        float3 size_temp;
        float radius_temp;
        float3 position_temp;
        float3 color_temp;

        float3 carRoot;
        float3 offset;

        rotateViaMouse_float(camMat);
        computeFragmentCoordinates_float(IN.uv, 10, 10, uv);
    ```

### 2. Static Ground

=== "2. Visual Scripting"
    <figure markdown="span">
        ![Unity Car: Ground](../images/car/carGround.png){ width="300" }
    </figure>

=== "2. Standard Scripting"
    ```hlsl
    addRoundBox_float(0, float3(0, -1.8, 0), float3(20, 0.5, 4), 0.3, float3(0,1,0), 0, 
    float3(0.15, 0.15, 0.15), float3(0.3, 0.3, 0.3), 0.1, 32, 0, index);
    ```



### 3. Car Motion (Tweened)

=== "3. Visual Scripting"
    <figure markdown="span">
        ![Unity Car: Tweening](../images/car/carTweening.png){ width="300" }
    </figure>

=== "3. Standard Scripting"
    ```hlsl
    tween3D_float(float3(-10, 0, 0), float3(10, 0, 0), 6.0, TWEEN_QUARTIC_INOUT, 0.0, true, carRoot);
    ```

### 4. Car Body & Roof

=== "4. Visual Scripting"
    <figure markdown="span">
        ![Unity Car: Body](../images/car/carBody.png){ width="500" }
    </figure>

=== "4. Standard Scripting"
    ```hlsl
    addRoundBox_float(index, carRoot + float3(0, -0.5, 0), float3(2.0, 0.4, 1.0), 0.2, float3(0,1,0), 0, 
        float3(0.8, 0.1, 0.1), float3(1,1,1), 0.4, 64, 0, index);  // body

    addRoundBox_float(index, carRoot + float3(0.5, 0.1, 0), float3(1.3, 0.4, 0.9), 0.1, float3(0,1,0), 0, 
        float3(0.8, 0.1, 0.1), float3(1,1,1), 0.4, 64, 0, index);  // roof
    ```

### 5. Car Front & Windshield
=== "5. Visual Scripting"
    Left Out

=== "5. Standard Scripting"
    ```hlsl
    addRoundBox_float(index, carRoot + float3(-0.75, -0.02, 0), float3(0.5, 0.3, 0.9), 0.1, float3(0,0,1), 45, 
        float3(0.8, 0.1, 0.1), float3(1,1,1), 0.4, 64, 0, index);

    addRoundBox_float(index, carRoot + float3(-0.76, -0.02, 0), float3(0.46, 0.3, 0.8), 0.1, float3(0,0,1), 45, 
        float3(0.3,0.5,1.0), float3(1,1,1), 0.4, 64, 0, index);
    ```

### 6. Windows (Left and Right)

=== "6. Visual Scripting"
    <figure markdown="span">
        ![Unity Car: Windows](../images/car/carWindows.png){ width="700" }
    </figure>

=== "6. Standard Scripting"
    ```hlsl
    // Left windows
    addEllipsoid_float(index, carRoot + float3(0, 0.18, 0.9), float3(0.5, 0.2, 0.01), float3(0,1,0), 0, 
        float3(0.3,0.5,1.0), float3(1,1,1), 0.2, 64, 0, index);

    addEllipsoid_float(index, carRoot + float3(1.1, 0.18, 0.9), float3(0.5, 0.2, 0.01), float3(0,1,0), 0, 
        float3(0.3,0.5,1.0), float3(1,1,1), 0.2, 64, 0, index);

    // Right windows
    addEllipsoid_float(index, carRoot + float3(0, 0.18, -0.9), float3(0.5, 0.2, 0.01), float3(0,1,0), 0, 
        float3(0.3,0.5,1.0), float3(1,1,1), 0.2, 64, 0, index);

    addEllipsoid_float(index, carRoot + float3(1.1, 0.18, -0.9), float3(0.5, 0.2, 0.01), float3(0,1,0), 0, 
        float3(0.3,0.5,1.0), float3(1,1,1), 0.2, 64, 0, index);
    ```

### 7. Wheels with Shake Animation (currently intensity 0)

=== "7. Visual Scripting"
    <figure markdown="span">
        ![Unity Car: Wheels](../images/car/carWheels.png){ width="700" }
    </figure>

=== "7. Standard Scripting"
    ```hlsl
    float wheelY = -0.9;
    float wheelRadius = 0.3;
    float wheelThickness = 0.1;

    shakeObject_float(carRoot, 0, 0.02, position_temp);

    addTorus_float(index, position_temp + float3(1.2, wheelY, 0.95), wheelRadius, wheelThickness, float3(0,0,1), 90, 
        float3(0.1,0.1,0.1), float3(0.3,0.3,0.3), 0.1, 32, 0, index);

    addTorus_float(index, position_temp + float3(-1, wheelY, 0.95), wheelRadius, wheelThickness, float3(0,0,1), 90, 
        float3(0.1,0.1,0.1), float3(0.3,0.3,0.3), 0.1, 32, 0, index);

    addTorus_float(index, position_temp + float3(1.2, wheelY, -0.95), wheelRadius, wheelThickness, float3(0,0,1), 90, 
        float3(0.1,0.1,0.1), float3(0.3,0.3,0.3), 0.1, 32, 0, index);

    addTorus_float(index, position_temp + float3(-1, wheelY, -0.95), wheelRadius, wheelThickness, float3(0,0,1), 90, 
        float3(0.1,0.1,0.1), float3(0.3,0.3,0.3), 0.1, 32, 0, index);
    ```

### 8. Light Poles

=== "8. Visual Scripting"
    <figure markdown="span">
        ![Unity Car: Light Boxes](../images/car/carLightBoxes.png){ width="500" }
    </figure>

=== "8. Standard Scripting"
    ```hlsl
    addRoundBox_float(index, float3(17, 2, 3.7), float3(0.2, 4, 0.2), 0.1, float3(0,1,0), 0, float3(0.2, 0.2, 0.2), float3(1,1,1), 0.3, 32, 0, index);
    addRoundBox_float(index, float3(17, 2, -3.7), float3(0.2, 4, 0.2), 0.1, float3(0,1,0), 0, float3(0.2, 0.2, 0.2), float3(1,1,1), 0.3, 32, 0, index);
    ```

### 9. Raymarching and Lighting

=== "9. Visual Scripting"
    <figure markdown="span">
        ![Unity Car: Lighting](../images/car/carLights.png){ width="500" }
    </figure>

=== "9. Standard Scripting"
    ```hlsl
    raymarch_float(1, camMat, index, uv, hitPos1, normal1, hitID1, rayDir1);

    pointLight_float(hitPos1, normal1, hitID1, rayDir1, float3(17, 6.5, 3.7), float3(1,1,0), 4, 0.01,  colorOut1);
    pointLight_float(hitPos1, normal1, hitID1, rayDir1, float3(17, 6.5, -3.7), float3(1,1,0), 4, 0.01,  colorOut2);

    applyToonLighting_float(hitPos1, normal1, hitID1, _LightPosition, colorOut3);

    colorOut = colorOut1 + colorOut2 + colorOut3;

    return float4(colorOut,1);
    ```

---

## The Result

The final animated car moves back and forth, featuring stylized wheels, body, lights, and a toon-shaded finish.
    <figure markdown="span">
    ![Unity Car](../images/userShaders/car.gif){ width="900" }
    </figure>

The finished ShaderGraph:
    <figure markdown="span">
    ![Unity Car: Final ShaderGraph](../images/car/carFinalResults.png){ width="900" }
    </figure>

## The Whole Code
??? "Car User Shader"
    ```hlsl
    Shader "Custom/Car"
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

                    float4 hitPos1;
                    float hitID1;
                    float3 normal1;
                    float3 rayDir1;


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

                    float3 carRoot;
                    float3 offset;

                    // Static Ground
                    addRoundBox_float(0, float3(0, -1.8, 0), float3(20, 0.5, 4), 0.3, float3(0,1,0), 0, float3(0.15, 0.15, 0.15), float3(0.3, 0.3, 0.3), 0.1, 32, 0, index);

                    // Car motion tween
                    tween3D_float(float3(-10, 0, 0), float3(10, 0, 0), 6.0, TWEEN_QUARTIC_INOUT, 0.0, true, carRoot);

                    // Car Body
                    addRoundBox_float(index, carRoot + float3(0, -0.5, 0), float3(2.0, 0.4, 1.0), 0.2, float3(0,1,0), 0, float3(0.8, 0.1, 0.1), float3(1,1,1), 0.4, 64, 0, index);

                    // Car Roof
                    addRoundBox_float(index, carRoot + float3(0.5, 0.1, 0), float3(1.3, 0.4, 0.9), 0.1, float3(0,1,0), 0, float3(0.8, 0.1, 0.1), float3(1,1,1), 0.4, 64, 0, index);

                    // Car Front
                    addRoundBox_float(index, carRoot + float3(-0.75, -0.02, 0), float3(0.5, 0.3, 0.9), 0.1, float3(0,0,1), 45, float3(0.8, 0.1, 0.1), float3(1,1,1), 0.4, 64, 0, index);
                    addRoundBox_float(index, carRoot + float3(-0.76, -0.02, 0), float3(0.46, 0.3, 0.8), 0.1, float3(0,0,1), 45, float3(0.3,0.5,1.0), float3(1,1,1), 0.4, 64, 0, index);


                    // Left Window
                    addEllipsoid_float(index, carRoot + float3(0, 0.18, 0.9), float3(0.5, 0.2, 0.01), float3(0,1,0), 0, float3(0.3,0.5,1.0), float3(1,1,1), 0.2, 64, 0, index);
                    addEllipsoid_float(index, carRoot + float3(1.1, 0.18, 0.9), float3(0.5, 0.2, 0.01), float3(0,1,0), 0, float3(0.3,0.5,1.0), float3(1,1,1), 0.2, 64, 0, index);

                    // Right Window
                    addEllipsoid_float(index, carRoot + float3(0, 0.18, -0.9), float3(0.5, 0.2, 0.01), float3(0,1,0), 0, float3(0.3,0.5,1.0), float3(1,1,1), 0.2, 64, 0, index);
                    addEllipsoid_float(index, carRoot + float3(1.1, 0.18, -0.9), float3(0.5, 0.2, 0.01), float3(0,1,0), 0, float3(0.3,0.5,1.0), float3(1,1,1), 0.2, 64, 0, index);


                    // Wheels
                    float wheelY = -0.9;
                    float wheelRadius = 0.3;
                    float wheelThickness = 0.1;

                    shakeObject_float(carRoot, 0, 0.02, position_temp);

                    addTorus_float(index, position_temp + float3(1.2, wheelY, 0.95), wheelRadius, wheelThickness, float3(0,0,1), 90, float3(0.1,0.1,0.1), float3(0.3,0.3,0.3), 0.1, 32, 0, index);
                    addTorus_float(index, position_temp + float3(-1, wheelY, 0.95), wheelRadius, wheelThickness, float3(0,0,1), 90, float3(0.1,0.1,0.1), float3(0.3,0.3,0.3), 0.1, 32, 0, index);
                    addTorus_float(index, position_temp + float3(1.2, wheelY, -0.95), wheelRadius, wheelThickness, float3(0,0,1), 90, float3(0.1,0.1,0.1), float3(0.3,0.3,0.3), 0.1, 32, 0, index);
                    addTorus_float(index, position_temp + float3(-1, wheelY, -0.95), wheelRadius, wheelThickness, float3(0,0,1), 90, float3(0.1,0.1,0.1), float3(0.3,0.3,0.3), 0.1, 32, 0, index);

                    addRoundBox_float(index, float3(17, 2, 3.7), float3(0.2, 4, 0.2), 0.1, float3(0,1,0), 0, float3(0.2, 0.2, 0.2), float3(1,1,1), 0.3, 32, 0, index);
                    addRoundBox_float(index, float3(17, 2, -3.7), float3(0.2, 4, 0.2), 0.1, float3(0,1,0), 0, float3(0.2, 0.2, 0.2), float3(1,1,1), 0.3, 32, 0, index);


                    raymarch_float(1, camMat, index, uv, hitPos1, normal1, hitID1, rayDir1);

                    pointLight_float(hitPos1, normal1, hitID1, rayDir1, float3(17, 6.5, 3.7), float3(1,1,0), 4, 0.01,  colorOut1);
                    pointLight_float(hitPos1, normal1, hitID1, rayDir1, float3(17, 6.5, -3.7), float3(1,1,0), 4, 0.01,  colorOut2);
                    
                    applyToonLighting_float(hitPos1, normal1, hitID1, _LightPosition, colorOut3);

                    colorOut = colorOut1 + colorOut2 + colorOut3;

                    return float4(colorOut,1);
                }
                ENDHLSL
            }
        }
    }
    ```