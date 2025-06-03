Shader "Custom/ModularShader"
{
    Properties
    {
        _Color ("Base Color", Color) = (1,1,1,1)
        _TimeSpeed ("Time Speed", Float) = 1.0
        _TwistStrength ("Twist Strength", Float) = 2.0
        _RippleStrength ("Ripple Strength", Float) = 0.2
        _SpinSpeed ("Spin Speed", Float) = 1.0
        _UseSimpleNoise ("Use Simple Noise", Float) = 0
        _UsePerlinNoise ("Use Perlin Noise", Float) = 0
        _UseRipple ("Use Ripple Geometry", Float) = 0
        _UseTwist ("Use Twist Geometry", Float) = 0
        _UseSpin ("Use Spin Geometry", Float) = 0
        _UsePulse ("Use Pulsating Color", Float) = 0
        _UseVStripes ("Use Vertical Stripes", Float) = 0
        _UseHStripes ("Use Horizontal Stripes", Float) = 0
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
            float _TwistStrength;
            float _RippleStrength;
            float _SpinSpeed;
            float _UseSimpleNoise;
            float _UsePerlinNoise;
            float _UseRipple;
            float _UseTwist;
            float _UseSpin;
            float _UsePulse;
            float _UseVStripes;
            float _UseHStripes;

            float SimpleNoise(float2 p) {
                return frac(sin(dot(p, float2(12.9898,78.233))) * 43758.5453);
            }

            float PerlinNoise(float2 p) {
                return (SimpleNoise(p) + SimpleNoise(p * 2.0) * 0.5 + SimpleNoise(p * 4.0) * 0.25);
            }

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                float3 pos = IN.positionOS.xyz;

                float t = _Time.y * _TimeSpeed;

                if (_UseRipple > 0.5)
                    pos.y += sin(pos.x * 10 + t) * _RippleStrength;

                if (_UseTwist > 0.5)
                {
                    float angle = pos.y * _TwistStrength;
                    float c = cos(angle);
                    float s = sin(angle);
                    float2 xz = float2(c * pos.x - s * pos.z, s * pos.x + c * pos.z);
                    pos.x = xz.x;
                    pos.z = xz.y;
                }

                if (_UseSpin > 0.5)
                {
                    float angle = t * _SpinSpeed;
                    float c = cos(angle);
                    float s = sin(angle);
                    float2 xz = float2(c * pos.x - s * pos.z, s * pos.x + c * pos.z);
                    pos.x = xz.x;
                    pos.z = xz.y;
                }

                OUT.positionCS = TransformObjectToHClip(pos);
                OUT.uv = IN.uv;
                OUT.worldPos = TransformObjectToWorld(pos);
                return OUT;
            }

            float4 frag (Varyings IN) : SV_Target
            {
                float3 color = _Color.rgb;
                float t = _Time.y * _TimeSpeed;

                if (_UseSimpleNoise > 0.5)
                {
                    float n = SimpleNoise(IN.uv * 10.0 + t);
                    color *= n;
                }

                if (_UsePerlinNoise > 0.5)
                {
                    float n = PerlinNoise(IN.uv * 5.0 + t);
                    color *= n;
                }

                if (_UsePulse > 0.5)
                {
                    float pulse = abs(sin(t * 2.0));
                    color *= pulse;
                }

                if (_UseVStripes > 0.5)
                {
                    float stripe = step(0.5, frac(IN.uv.y * 10 + t));
                    color *= stripe;
                }

                if (_UseHStripes > 0.5)
                {
                    float stripe = step(0.5, frac(IN.uv.x * 10 + t));
                    color *= stripe;
                }

                return float4(color, 1.0);
            }
            ENDHLSL
        }
    }
}
