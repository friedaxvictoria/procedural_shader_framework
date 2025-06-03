Shader "Custom/Shader8"
{
    Properties
    {
        _MainTex ("iChannel0", 2D) = "white" {}
        _SecondTex ("iChannel1", 2D) = "white" {}
        _ThirdTex ("iChannel2", 2D) = "white" {}
        _FourthTex ("iChannel3", 2D) = "white" {}
        _Mouse ("Mouse", Vector) = (0.5, 0.5, 0.5, 0.5)
        [ToggleUI] _GammaCorrect ("Gamma Correction", Float) = 1
        _Resolution ("Resolution (Change if AA is bad)", Range(1, 1024)) = 1
    }
    SubShader
    {
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

            // Built-in properties
            sampler2D _MainTex;   float4 _MainTex_TexelSize;
            sampler2D _SecondTex; float4 _SecondTex_TexelSize;
            sampler2D _ThirdTex;  float4 _ThirdTex_TexelSize;
            sampler2D _FourthTex; float4 _FourthTex_TexelSize;
            float4 _Mouse;
            float _GammaCorrect;
            float _Resolution;

            // GLSL Compatability macros
            #define glsl_mod(x,y) (((x)-(y)*floor((x)/(y))))
            #define texelFetch(ch, uv, lod) tex2Dlod(ch, float4((uv).xy * ch##_TexelSize.xy + ch##_TexelSize.xy * 0.5, 0, lod))
            #define textureLod(ch, uv, lod) tex2Dlod(ch, float4(uv, 0, lod))
            #define iResolution float3(_Resolution, _Resolution, _Resolution)
            #define iFrame (floor(_Time.y / 60))
            #define iChannelTime float4(_Time.y, _Time.y, _Time.y, _Time.y)
            #define iDate float4(2020, 6, 18, 30)
            #define iSampleRate (44100)
            #define iChannelResolution float4x4(                      \
                _MainTex_TexelSize.z,   _MainTex_TexelSize.w,   0, 0, \
                _SecondTex_TexelSize.z, _SecondTex_TexelSize.w, 0, 0, \
                _ThirdTex_TexelSize.z,  _ThirdTex_TexelSize.w,  0, 0, \
                _FourthTex_TexelSize.z, _FourthTex_TexelSize.w, 0, 0)

            // Global access to uv data
            static v2f vertex_output;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv =  v.uv;
                return o;
            }

            float noise3(float3 x)
            {
                float3 p = floor(x), f = frac(x);
                f = f*f*(3.-2.*f);
#define hash3(p) frac(sin(1000.*dot(p, float3(1, 57, -13.7)))*4375.5454)
                return lerp(lerp(lerp(hash3(p+float3(0, 0, 0)), hash3(p+float3(1, 0, 0)), f.x), lerp(hash3(p+float3(0, 1, 0)), hash3(p+float3(1, 1, 0)), f.x), f.y), lerp(lerp(hash3(p+float3(0, 0, 1)), hash3(p+float3(1, 0, 1)), f.x), lerp(hash3(p+float3(0, 1, 1)), hash3(p+float3(1, 1, 1)), f.x), f.y), f.z);
            }

#define noise(x) (noise3(x)+noise3(x+11.5))/2.
            float4 frag (v2f __vertex_output) : SV_Target
            {
                vertex_output = __vertex_output;
                float4 O = 0;
                float2 U = vertex_output.uv * _Resolution;
                float2 R = iResolution.xy;
                float n = noise(float3(U*8./R.y, 0.1*_Time.y)), v = sin(6.28*10.*n), t = _Time.y;
                v = smoothstep(1., 0., 0.5*abs(v)/fwidth(v));
                O = lerp(exp(-33./R.y)*tex2D(_MainTex, (U+float2(1, sin(t)))/R), 0.5+0.5*sin(12.*n+float4(0, 2.1, -2.1, 0)), v);
                if (_GammaCorrect) O.rgb = pow(O.rgb, 2.2);
                return O;
            }
            ENDCG
        }
    }
}
