Shader "Custom/UserShader3"
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

            // #define MAX_OBJECTS 10

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Assets/Shaders/Includes/ModularShaderLib.hlsl"

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

                ObjectInput inputs[10];

                for (int i = 0; i < 10; ++i) {
                    inputs[i].type = -1;                      // Mark as unused
                    inputs[i].position = float3(0, 0, 0);
                    inputs[i].size = float3(0, 0, 0);
                    inputs[i].radius = 0.0;
                    inputs[i].color = float3(0, 0, 0);
                }

                inputs[0].type = 0;
                inputs[0].position = float3(0, 0, 0);
                inputs[0].size = float3(0, 0, 0);
                inputs[0].radius = 1.0;
                inputs[0].color = float3(0.2, 0.2, 1.0);

                inputs[1].type = 1;
                inputs[1].position = float3(1.9, 0.0, 0.0);
                inputs[1].size = float3(1.0, 1.0, 1.0);
                inputs[1].radius = 0.2;
                inputs[1].color = float3(0.2, 1.0, 0.2);

                inputs[2].type = 1;
                inputs[2].position = float3(-1.9, 0.0, 0.0);
                inputs[2].size = float3(1.0, 1.0, 1.0);
                inputs[2].radius = 0.2;
                inputs[2].color = float3(0.2, 1.0, 0.2);

                inputs[3].type = 2;
                inputs[3].position = float3(-2, 0, 0.0);
                inputs[3].size = float3(0.5, 2.5, 0.75);
                inputs[3].radius = 0.1;
                inputs[3].color = float3(1.0, 0.2, 0.2);

                inputs[4].type = 2;
                inputs[4].position = float3(2, 0, 0.0);
                inputs[4].size = float3(0.5, 2.5, 0.75);
                inputs[4].radius = 0.1;
                inputs[4].color = float3(1.0, 0.2, 0.2);

                inputs[5].type = 1;
                inputs[5].position = float3(0, 1.9, 0.0);
                inputs[5].size = float3(1.0, 1.0, 1.0);
                inputs[5].radius = 0.2;
                inputs[5].color = float3(0.2, 1.0, 0.2);

                inputs[6].type = 1;
                inputs[6].position = float3(0, -1.9, 0.0);
                inputs[6].size = float3(1.0, 1.0, 1.0);
                inputs[6].radius = 0.2;
                inputs[6].color = float3(0.2, 1.0, 0.2);

                inputs[7].type = 0;
                inputs[7].position = float3(5.0, 5.0, 0.0);
                inputs[7].size = float3(0, 0, 0);
                inputs[7].radius = 1;
                inputs[7].color = float3(1.0, 1.0, 0);

                float4 colorOut;



                // ApplyWaterEffect(IN.uv, colorOut);
                IntegrationFlexible(IN.uv, colorOut, inputs, 8, _LightPosition, 1);


                
                return colorOut;
            }
            ENDHLSL
        }
    }
}
