Shader "Custom/Animation/WigglingVertices"
{
    Properties
    {
        _Color ("Color", Color) = (0.5, 1, 0.5, 1)
        _WiggleSpeed ("Wiggle Speed", Float) = 3.0
        _WiggleAmount ("Wiggle Amount", Float) = 0.1
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
            float _WiggleSpeed;
            float _WiggleAmount;

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
                float3 pos = v.vertex.xyz;
                pos.y += sin(pos.x * 5.0 + _Time.y * _WiggleSpeed) * _WiggleAmount;
                o.vertex = UnityObjectToClipPos(float4(pos, 1.0));
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
