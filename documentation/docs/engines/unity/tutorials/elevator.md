<div class="container">
    <h1 class="main-heading">Tutorial: Elevator</h1>
    <blockquote class="author">by Utku Alkan</blockquote>
</div>

This tutorial walks you through building an elevator scene. The scene includes a moving elevator, walls, a simple passenger, lighting, and animated motion via `tween1D_float`.

---

## Step-by-Step

### 1. Set up the fragment shader structure

In the fragment shader, create all your variables and initialize things like camera matrix and fragment coordinates:

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

    float liftHeight;
    float3 elevatorPos;

    rotateViaMouse_float(camMat);
    computeFragmentCoordinates_float(IN.uv, 10, 10, uv);
```

### 2. Animate the elevator using `tween1D_float`

```hlsl
tween1D_float(-2.4, 5.0, 4.0, TWEEN_SINE_INOUT, 0.0, true, liftHeight);
elevatorPos = float3(0, liftHeight - 1.0, 0);
```

### 3. Shaft base (ground)

```hlsl
addRoundBox_float(0, float3(0, -4, 0), float3(3, 0.5, 3), 0.3, float3(0,1,0), 0, 
    float3(0.12, 0.12, 0.12), float3(0.4, 0.4, 0.4), 0.1, 32, 0, index);
```

### 4. Shaft walls (back, left, right, top)

```hlsl
addRoundBox_float(index, float3(0, 1, -1.5), float3(1.5, 5, 0.05), 0.1, float3(0,1,0), 0, 
    float3(0.1,0.1,0.1), float3(0.2,0.2,0.2), 0.1, 32, 0, index);  // back

addRoundBox_float(index, float3(-1.5, 1, 0), float3(0.05, 5, 1.5), 0.1, float3(0,1,0), 0, 
    float3(0.1,0.1,0.1), float3(0.2,0.2,0.2), 0.1, 32, 0, index);  // left

addRoundBox_float(index, float3(1.5, 1, 0), float3(0.05, 5, 1.5), 0.1, float3(0,1,0), 0, 
    float3(0.1,0.1,0.1), float3(0.2,0.2,0.2), 0.1, 32, 0, index);  // right

addRoundBox_float(index, float3(0, 5.9, 0), float3(1.5, 0.05, 1.5), 0.1, float3(0,1,0), 0, 
    float3(0.1,0.1,0.1), float3(0.2,0.2,0.2), 0.1, 32, 0, index);  // ceiling
```

### 5. Elevator platform and interior

```hlsl
addRoundBox_float(index, elevatorPos + float3(0, -0.2, 0), float3(1.4, 0.1, 1.2), 0.1, float3(0,1,0), 0, 
    float3(0.5,0.5,0.5), float3(1,1,1), 0.3, 64, 0, index);
```

### 6. Elevator walls (left, right, back)

```hlsl
addRoundBox_float(index, elevatorPos + float3(-0.7, 0.65, 0), float3(0.05, 0.7, 1.1), 0.05, float3(0,1,0), 0, 
    float3(0.2,0.2,0.2), float3(1,1,1), 0.2, 64, 0, index);  // left

addRoundBox_float(index, elevatorPos + float3(0.7, 0.65, 0), float3(0.05, 0.7, 1.1), 0.05, float3(0,1,0), 0, 
    float3(0.2,0.2,0.2), float3(1,1,1), 0.2, 64, 0, index);  // right

addRoundBox_float(index, elevatorPos + float3(0, 0.65, -0.55), float3(0.65, 0.7, 0.05), 0.05, float3(0,1,0), 0, 
    float3(0.2,0.2,0.2), float3(1,1,1), 0.2, 64, 0, index);  // back
```

### 7. Elevator ceiling

```hlsl
addRoundBox_float(index, elevatorPos + float3(0, 1.3, 0), float3(0.65, 0.05, 1.1), 0.05, float3(0,1,0), 0, 
    float3(0.3,0.3,0.3), float3(1,1,1), 0.2, 64, 0, index);
```

### 8. Button panel inside elevator

```hlsl
addSphere_float(index, elevatorPos + float3(0.6, 0.4, 0.4), 0.05, float3(0,1,0), 0, 
    float3(1.0, 0.9, 0.3), float3(1.0, 1.0, 0.8), 0.6, 64, 0, index);

addSphere_float(index, elevatorPos + float3(0.6, 0.25, 0.4), 0.05, float3(0,1,0), 0, 
    float3(0.9, 0.3, 0.2), float3(1.0, 0.7, 0.7), 0.6, 64, 0, index);
```

### 9. Passenger in the elevator

```hlsl
// Body
addSphere_float(index, elevatorPos + float3(0, 0.4, 0), 0.15, float3(0,1,0), 0, 
    float3(0.2,0.2,0.6), float3(1,1,1), 0.3, 64, 0, index);

// Head
addSphere_float(index, elevatorPos + float3(0, 0.6, 0), 0.1, float3(0,1,0), 0, 
    float3(1.0, 0.8, 0.6), float3(1,1,1), 0.3, 64, 0, index);

// Legs as a sphere like a snowman
addSphere_float(index, elevatorPos + float3(0, 0.15, 0), 0.2, float3(0,1,0), 0, 
    float3(0, 0.2, 0.6), float3(1,1,1), 0.3, 64, 0, index);

// Feet
addSphere_float(index, elevatorPos + float3(0.15, -0.05, 0), 0.06, float3(0,1,0), 0, 
    float3(1.0, 0.8, 0.6), float3(1,1,1), 0.3, 64, 0, index);

addSphere_float(index, elevatorPos + float3(-0.15, -0.05, 0), 0.06, float3(0,1,0), 0, 
    float3(1.0, 0.8, 0.6), float3(1,1,1), 0.3, 64, 0, index);

// Hands
addSphere_float(index, elevatorPos + float3(0.14, 0.45, 0), 0.06, float3(0,1,0), 0, 
    float3(1.0, 0.8, 0.6), float3(1,1,1), 0.3, 64, 0, index);

addSphere_float(index, elevatorPos + float3(-0.14, 0.45, 0), 0.06, float3(0,1,0), 0, 
    float3(1.0, 0.8, 0.6), float3(1,1,1), 0.3, 64, 0, index);
```

### 10. Perform raymarching and lighting

```hlsl
raymarch_float(1, camMat, index, uv, hitPos1, normal1, hitID1, rayDir1);

pointLight_float(hitPos1, normal1, hitID1, rayDir1, _LightPosition, float3(1,1,1), 5, 0.05, colorOut1);
sunriseLight_float(hitPos1, normal1, hitID1, rayDir1, colorOut3);
applyToonLighting_float(hitPos1, normal1, hitID1, _LightPosition, colorOut2);

colorOut = colorOut1 + colorOut2 + colorOut3;

return float4(colorOut, 1);
```

---

## The Result

The final view:
    <figure markdown="span">
    ![Unity Elevator](../images/userShaders/elevator.gif){ width="900" }
    </figure>


## The Whole Code
??? "Elevator User Shader"
    ```hlsl
    Shader "Custom/Elevator"
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
                    float3x3 camMat = float3x3( 1,0,0, 0,1,0, 0,0,1);


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

                    float3 elevatorPos;
                    float liftHeight;

                    rotateViaMouse_float(camMat);

                    computeFragmentCoordinates_float(IN.uv, 10, 10, uv);

                    // Tween elevator position
                    tween1D_float(-2.4, 5.0, 4.0, TWEEN_SINE_INOUT, 0.0, true, liftHeight);
                    elevatorPos = float3(0, liftHeight - 1.0, 0);

                    // Shaft base (ground)
                    addRoundBox_float(0, float3(0, -4, 0), float3(3, 0.5, 3), 0.3, float3(0,1,0), 0, float3(0.12, 0.12, 0.12), float3(0.4, 0.4, 0.4), 0.1, 32, 0, index);

                    // Shaft walls (back, left, right, top)
                    addRoundBox_float(index, float3(0, 1, -1.5), float3(1.5, 5, 0.05), 0.1, float3(0,1,0), 0, float3(0.1,0.1,0.1), float3(0.2,0.2,0.2), 0.1, 32, 0, index);  // back wall
                    addRoundBox_float(index, float3(-1.5, 1, 0), float3(0.05, 5, 1.5), 0.1, float3(0,1,0), 0, float3(0.1,0.1,0.1), float3(0.2,0.2,0.2), 0.1, 32, 0, index);  // left wall
                    addRoundBox_float(index, float3(1.5, 1, 0), float3(0.05, 5, 1.5), 0.1, float3(0,1,0), 0, float3(0.1,0.1,0.1), float3(0.2,0.2,0.2), 0.1, 32, 0, index);   // right wall
                    addRoundBox_float(index, float3(0, 5.9, 0), float3(1.5, 0.05, 1.5), 0.1, float3(0,1,0), 0, float3(0.1,0.1,0.1), float3(0.2,0.2,0.2), 0.1, 32, 0, index);   // ceiling

                    // Elevator platform
                    addRoundBox_float(index, elevatorPos + float3(0, -0.2, 0), float3(1.4, 0.1, 1.2), 0.1, float3(0,1,0), 0, float3(0.5,0.5,0.5), float3(1,1,1), 0.3, 64, 0, index);

                    // Elevator walls => left, right, back only
                    addRoundBox_float(index, elevatorPos + float3(-0.7, 0.65, 0), float3(0.05, 0.7, 1.1), 0.05, float3(0,1,0), 0, float3(0.2, 0.2, 0.2), float3(1,1,1), 0.2, 64, 0, index);  // left
                    addRoundBox_float(index, elevatorPos + float3(0.7, 0.65, 0), float3(0.05, 0.7, 1.1), 0.05, float3(0,1,0), 0, float3(0.2, 0.2, 0.2), float3(1,1,1), 0.2, 64, 0, index);   // right
                    addRoundBox_float(index, elevatorPos + float3(0, 0.65, -0.55), float3(0.65, 0.7, 0.05), 0.05, float3(0,1,0), 0, float3(0.2, 0.2, 0.2), float3(1,1,1), 0.2, 64, 0, index); // back

                    // Elevator ceiling
                    addRoundBox_float(index, elevatorPos + float3(0, 1.3, 0), float3(0.65, 0.05, 1.1), 0.05, float3(0,1,0), 0, float3(0.3,0.3,0.3), float3(1,1,1), 0.2, 64, 0, index);


                    // Button panel (right side interior)
                    addSphere_float(index, elevatorPos + float3(0.6, 0.4, 0.4), 0.05, float3(0,1,0), 0, float3(1.0, 0.9, 0.3), float3(1.0, 1.0, 0.8), 0.6, 64, 0, index);
                    addSphere_float(index, elevatorPos + float3(0.6, 0.25, 0.4), 0.05, float3(0,1,0), 0, float3(0.9, 0.3, 0.2), float3(1.0, 0.7, 0.7), 0.6, 64, 0, index);

                    // passenger
                    addSphere_float(index, elevatorPos + float3(0, 0.4, 0), 0.15, float3(0,1,0), 0, float3(0.2, 0.2, 0.6), float3(1,1,1), 0.3, 64, 0, index); // body
                    addSphere_float(index, elevatorPos + float3(0, 0.6, 0), 0.1, float3(0,1,0), 0, float3(1.0, 0.8, 0.6), float3(1,1,1), 0.3, 64, 0, index); // head
                    addSphere_float(index, elevatorPos + float3(0, 0.15, 0), 0.2, float3(0,1,0), 0, float3(0, 0.2, 0.6), float3(1,1,1), 0.3, 64, 0, index); // legs as sphere
                    addSphere_float(index, elevatorPos + float3(0.15, -0.05, 0), 0.06, float3(0,1,0), 0, float3(1.0, 0.8, 0.6), float3(1,1,1), 0.3, 64, 0, index); // feet
                    addSphere_float(index, elevatorPos + float3(-0.15, -0.05, 0), 0.06, float3(0,1,0), 0, float3(1.0, 0.8, 0.6), float3(1,1,1), 0.3, 64, 0, index); // feet

                    addSphere_float(index, elevatorPos + float3(0.14, 0.45, 0), 0.06, float3(0,1,0), 0, float3(1.0, 0.8, 0.6), float3(1,1,1), 0.3, 64, 0, index); // hands
                    addSphere_float(index, elevatorPos + float3(-0.14, 0.45, 0), 0.06, float3(0,1,0), 0, float3(1.0, 0.8, 0.6), float3(1,1,1), 0.3, 64, 0, index); // hands


                    raymarch_float(1, camMat, index, uv, hitPos1, normal1, hitID1, rayDir1);

                    pointLight_float(hitPos1, normal1, hitID1, rayDir1, _LightPosition, float3(1,1,1), 5, 0.05,  colorOut1);
                    sunriseLight_float(hitPos1, normal1, hitID1, rayDir1, colorOut3);
                    applyToonLighting_float(hitPos1, normal1, hitID1, _LightPosition, colorOut2);


                    colorOut = colorOut1 + colorOut2 + colorOut3;


                    return float4(colorOut,1);
                }
                ENDHLSL
            }
        }
    }
    ```