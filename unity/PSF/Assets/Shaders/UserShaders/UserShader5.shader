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

            #define MAX_OBJECTS 8

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            // #include "Assets/Shaders/Includes/ModularShaderLib.hlsl"
            #include "Assets/Shaders/Includes/sdf_functions.hlsl"
            #include "Assets/Shaders/Includes/basics_functions.hlsl"
            #include "Assets/Shaders/Includes/lighting_functions.hlsl"
            #include "Assets/Shaders/Includes/animation_functions.hlsl"





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
                float3x3 mat = float3x3( 1,0,0, 0,1,0, 0,0,1 );
                float3 hitpos;
                float hitID;
                float3 normal;
                float3 colorOut;


                computeUV_float(IN.uv, uv);
                addSphere_float(float3(-1,0,0), 2, 0, float3(0.2,0.2,0.2), float3(0.1,0.1,0.8), 2, 1, index);
                addCube_float(float3(5,0,-5), 2, 0, index, float3(0.2,0.2,0.2), float3(0.8,0.2,0.2), 2, 1, index);
                raymarch_float(index, uv, mat, hitpos, normal);


                //applyPhongLighting_float(hitpos, _LightPosition, normal, colorOut);
                float3 rd = normalize(float3(uv, -1));
                float3 L = normalize(_LightPosition - hitpos);

                _dolphinColor(hitpos, normal, rd,  0.1, 0.1, 0, float3(0.2,0.2,0.2), 1, L, colorOut);


                
                return float4(colorOut,1);
            }
            ENDHLSL
        }
    }
}
