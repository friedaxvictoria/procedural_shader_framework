Shader "Custom/UserShader5"
{
    Properties
    {
        _Color ("Base Color", Color) = (1,1,1,1)
        _TimeSpeed ("Time Speed", Float) = 1.0

        // Built-in properties
        _MainTex ("iChannel0", 2D) = "white" {}
        _SecondTex ("iChannel1", 2D) = "white" {}
        _ThirdTex ("iChannel2", 2D) = "white" {}
        _FourthTex ("iChannel3", 2D) = "white" {}
        _Mouse ("Mouse", Vector) = (0.5, 0.5, 0.5, 0.5)
        [ToggleUI] _GammaCorrect ("Gamma Correction", Float) = 1
        _Resolution ("Resolution (Change if AA is bad)", Range(1, 1024)) = 1


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
            // #include "Assets/Shaders/Includes/ModularShaderLib.hlsl"
            #include "Assets/Shaders/Includes/sdf_functions.hlsl"
            #include "Assets/Shaders/Includes/basics_functions.hlsl"
            #include "Assets/Shaders/Includes/lighting_functions.hlsl"
            #include "Assets/Shaders/Includes/animation_functions.hlsl"
            #include "Assets/Shaders/Includes/water_surface.hlsl"






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
                float4 hitPos2;

                float hitID;
                float3 normal;

                float3 colorOut1;
                float3 colorOut2;

                float3 colorOut;
                float3 rayDir;


                // all temps
                float temp;
                float3 size_temp;
                float radius_temp;
                float3 position_temp;
                float3 color_temp;

                computeUV_float(IN.uv, uv);

                addSphere_float(float3(-2,0,-5), float3(2,2,2), 0, float3(0.8,0.1,0.1), 0, float3(0.8,0.1,0.1), float3(0.1,0.1,0.8), 2, 1, 0, index);




                translateObject_float(float3(5,0,-5), float3(-4,-8,0), 5, 1, position_temp);
                orbitObjectAroundPoint_float(position_temp, float3(3,3,-2), float3(1,2,0), 0.2, 0.8, 0.1, position_temp, temp);
                // shake_float(position_temp, 0.4, 1, position_temp);

                pulseObject_float(float3(2,2,2), 0, 2, 1, 0, size_temp, radius_temp);

                cycleColor_float(float3(0.8,0.1,0.1), 0.5, color_temp);

                addCube_float(position_temp, size_temp, radius_temp, index, float3(0.8,0.1,0.1), 0, float3(0.2,0.2,0.8), color_temp, 2, 1, 0, index);





                addTorus_float(float3(0,4.5,0), 2, 0.2, index, float3(0.8,0.1,0.1), 45, float3(0.2,0.5,0.2), float3(0.8,0.1,0.1), 2, 1, 0, index);
                addTorus_float(float3(-4.5,4.5,0), 2, 0.2, index, float3(0.8,0.1,0.1), 0, float3(0.2,0.5,0.2), float3(0.8,0.1,0.1), 2, 1, 0, index);
                addTorus_float(float3(-1.5,4.5,0), 2, 0.2, index, float3(0.8,0.1,0.1), 90, float3(0.2,0.5,0.2), float3(0.8,0.1,0.1), 2, 1, 0, index);
                addTorus_float(float3(4.5,4.5,0), 2, 0.2, index, float3(0.8,0.1,0.1), 0, float3(0.2,0.5,0.2), float3(0.8,0.1,0.1), 2, 1, 0, index);


                raymarch_float(1, index, uv, camMat, hitPos1, normal, rayDir);

                //pointLight_float(hitPos1, normal, _LightPosition, float3(1,1,1), colorOut1);
                //sunriseLight_float(hitPos1, normal, rayDir, colorOut2);

                applyRimLighting_float(hitPos1, _LightPosition, normal, colorOut1);
                applyToonLighting_float(hitPos1, _LightPosition, normal, colorOut2);


                // float3 rd = normalize(float3(uv, -1));
                // float3 L = normalize(_LightPosition - hitPos1);
                // _dolphinColor(hitPos1, normal, rd,  0.1, 0.1, 0, 1, L, colorOut1);


                colorOut = colorOut1 + colorOut2;

                // computeWater_float(uv, camMat, colorOut2, hitPos2);







                







                
                return float4(colorOut,1);
            }
            ENDHLSL
        }
    }
}
