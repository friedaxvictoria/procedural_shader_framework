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