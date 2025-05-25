Shader "Custom/Animation/PulsatingColor"
{
    Properties
    {
        _Color ("Color", Color) = (1, 0.5, 0.5, 1)
        _PulseSpeed ("Pulse Speed", Float) = 2.0
        _Intensity ("Intensity", Float) = 0.5
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

            fixed4 _Color;
            float _PulseSpeed;
            float _Intensity;

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float brightness = 1.0 + sin(_Time.y * _PulseSpeed) * _Intensity;
                return _Color * brightness;
            }
            ENDCG
        }
    }
}
