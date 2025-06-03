Shader "Custom/RippleGeometry"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Amplitude ("Amplitude", Float) = 0.1
        _Frequency ("Frequency", Float) = 10.0
        _Speed ("Speed", Float) = 2.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            fixed4 _Color;
            float _Amplitude;
            float _Frequency;
            float _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                float time = _Time.y * _Speed;
                float displacement = sin(v.uv.x * _Frequency + time) * _Amplitude;
                v.vertex.y += displacement;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _Color;
            }
            ENDCG
        }
    }
}
