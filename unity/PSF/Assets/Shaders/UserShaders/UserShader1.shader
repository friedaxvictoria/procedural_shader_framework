Shader "Custom/UserShader1"
{
    Properties
    {
        _Color ("Base Color", Color) = (1,1,1,1)
        _TimeSpeed ("Time Speed", Float) = 1.0
        _RippleStrength ("Ripple Strength", Float) = 0.2

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
            float _RippleStrength;

            Varyings vert (Attributes IN)
            {
                Varyings OUT;

                float3 pos = IN.positionOS.xyz;
                float time = _Time.y * _TimeSpeed;

                pos = ApplyRippleGeometry(pos, time, _RippleStrength);

                OUT.positionCS = TransformObjectToHClip(pos);
                OUT.uv = IN.uv;
                OUT.worldPos = TransformObjectToWorld(pos);


                return OUT;
            }

            float4 frag (Varyings IN) : SV_Target
            {
                float time = _Time.y * _TimeSpeed;
                float3 color = _Color.rgb;

                color = ApplyHorizontalStripes(color, IN.uv, time);
                color = ApplyVerticalStripes(color, IN.uv, time);
                color = ApplyPerlinNoise(color, IN.uv, time);


                return float4(color, 1.0);
            }
            ENDHLSL
        }
    }
}
