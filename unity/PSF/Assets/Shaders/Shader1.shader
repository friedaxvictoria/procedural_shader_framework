Shader "Custom/Shader1"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {} // Needed for URP compatibility, even if unused
        _ColFreq("Color Frequency", Float) = 1.0
        _Opacity("Opacity", Float) = 0.1
        _Perspective("Perspective", Float) = 1.0
        _Steps("Steps", Float) = 100.0
        _ZSpeed("Z Speed", Float) = 1.0
        _Twist("Twist", Float) = 0.1
        _rgbShift("RGB Shift", Vector) = (0.0, 1.0, 2.0)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Transparent" }
        Pass
        {
            Name "ForwardLit"
            Blend SrcAlpha OneMinusSrcAlpha
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
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            // Passed from C# script
            float3 _iResolution;
            float _iTime;

            // Inspector properties
            float _ColFreq;
            float _Opacity;
            float _Perspective;
            float _Steps;
            float _ZSpeed;
            float _Twist;
            float3 _rgbShift;

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv;
                return OUT;
            }

            float4 frag(Varyings IN) : SV_Target
            {
                float2 res = _iResolution.xy;
                float2 fragCoord = IN.uv * res;
                float2 uv = (2.0 * fragCoord - res) / res.y;
                float3 dir = normalize(float3(uv, -_Perspective));
                float3 col = float3(0.0, 0.0, 0.0);
                float z = 0.0;
                float d = 0.0;

                for (float i = 0.0; i < _Steps; i++)
                {
                    float3 p = z * dir;
                    p.z -= _ZSpeed * _iTime;
                    float angle = p.z * _Twist;
                    float2x2 rot = float2x2(cos(angle), -sin(angle), sin(angle), cos(angle));
                    p.xy = mul(rot, p.xy);
                    float3 v = cos(p + sin(p.yzx / 0.3));
                    z += d = length(max(v, v.zxy * _Opacity)) / 6.0;
                    col += (cos(_ColFreq * p.z + _rgbShift) + 1.0) / d;
                }

                col = 1.0 - exp(-col / _Steps / 50.0);

                return float4(col, 1.0);
            }
            ENDHLSL
        }
    }
}
