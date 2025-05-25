Shader "Custom/TwistGeometry"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _TwistStrength ("Twist Strength", Float) = 0.5
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalRenderPipeline" }
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float4 positionCS : SV_POSITION;
            };

            float4 _Color;
            float _TwistStrength;

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                float3 pos = IN.positionOS.xyz;

                // Scale strength to a reasonable range
                float angle = pos.y * _TwistStrength * 3.1415;
                float s = sin(angle);
                float c = cos(angle);

                // Rotate xz
                float x = c * pos.x - s * pos.z;
                float z = s * pos.x + c * pos.z;

                pos.x = x;
                pos.z = z;

                OUT.positionCS = TransformObjectToHClip(pos);
                OUT.uv = IN.uv;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                return half4(_Color.rgb, 1.0);
            }
            ENDHLSL
        }
    }
}
