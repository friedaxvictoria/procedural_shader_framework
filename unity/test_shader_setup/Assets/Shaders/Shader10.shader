Shader "Custom/Shader10"
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

#define A(v) ((float2x2)cos(m.v+radians(float4(0, -90, 90, 0))))
#define W(v) length(float3(p.yz-v(p.x+float2(0, pi_2)+t), 0))-lt
#define P(v) length(p-float3(0, v(t), v(t+pi_2)))-pt
            float4 frag (v2f __vertex_output) : SV_Target
            {
                vertex_output = __vertex_output;
                float4 C = 0;
                float2 U = vertex_output.uv * _Resolution;
                float lt = 0.1, pt = 0.3, pi = 3.1416, pi2 = pi*2., pi_2 = pi/2., t = _Time.y*pi, s = 1., d = 0., i = d;
                float2 R = iResolution.xy, m = (_Mouse.xy-0.5*R)/R.y*4.;
                float3 o = float3(0, 0, -7), u = normalize(float3((U-0.5*R)/R.y, 1)), c = ((float3)0), k = c, p;
                if (_Mouse.z<1.)
                    m = -float2(t/20.-pi_2, 0);
                    
                float2x2 v = A(y), h = A(x);
                for (;i++<50.; )
                {
                    p = o+u*d;
                    p.yz = mul(p.yz,v);
                    p.xz = mul(p.xz,h);
                    p.x -= 3.;
                    if (p.y<-1.5)
                        p.y = 2./p.y;
                        
                    k.x = min(max(p.x+lt, W(sin)), P(sin));
                    k.y = min(max(p.x+lt, W(cos)), P(cos));
                    s = min(s, min(k.x, k.y));
                    if (s<0.001||d>100.)
                        break;
                        
                    d += s*0.5;
                }
                c = max(cos(d*pi2)-s*sqrt(d)-k, 0.);
                c.gb += 0.1;
                C = float4(c*0.4+c.brg*0.6+c*c, 1);
                if (_GammaCorrect) C.rgb = pow(C.rgb, 2.2);
                return C;
            }
            ENDCG
        }
    }
}
