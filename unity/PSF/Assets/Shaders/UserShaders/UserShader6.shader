Shader "Custom/UserShader6"
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
            #include "Assets/Shaders/Includes/sdf_functions.hlsl"
            #include "Assets/Shaders/Includes/basics_functions.hlsl"
            #include "Assets/Shaders/Includes/lighting_functions.hlsl"
            #include "Assets/Shaders/Includes/animation_functions.hlsl"
            #include "Assets/Shaders/Includes/water_surface.hlsl"
            #include "Assets/Shaders/Includes/tween_functions.hlsl"







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


                computeFragmentCoordinates_float(IN.uv, 11, 11, uv);
                

               

                addTorus_float(0, float3(-2,2,-2), 2, 0.35, float3(0,1,0), 45, float3(0.4,0.1,0.8), float3(0.4,0.1,0.8), 2, 1, 0, index);
                addTorus_float(index, float3(0,0,0), 2, 0.35, float3(0,1,0), 45, float3(0.4,0.1,0.8), float3(0.4,0.1,0.8), 2, 1, 0, index);
                addTorus_float(index, float3(2,-0.5,2), 2, 0.35, float3(0,1,0), 45, float3(0.4,0.1,0.8), float3(0.4,0.1,0.8), 2, 1, 0, index);
                addTorus_float(index, float3(4,-1,4), 2, 0.35, float3(0,1,0), 45, float3(0.4,0.1,0.8), float3(0.4,0.1,0.8), 2, 1, 0, index);

               

                addDolphin_float(index, float3(3,-0.5,8), 2, 1.52, float3(0, 1, 0), 45, float3(0.2,0.5,0.2), float3(0.2,0.5,0.2), 1, 1, index);
                //addDolphin_float(index, float3(3.5,-0.5,8), 1, 2, float3(0, 1, 0), 60, float3(0.5,0.5,0.2), float3(0.2,0.5,0.2), 1, 1, index);
                //addDolphin_float(index, float3(4,-0.5,8), 1, 2, float3(0, 1, 0), 30, float3(0.2,0.5,0.5), float3(0.2,0.5,0.2), 1, 1, index);



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
