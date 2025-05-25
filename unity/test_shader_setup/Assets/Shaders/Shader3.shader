Shader "Custom/Shader3"
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

#define R iResolution
#define T _Time.y
#define M _Mouse
#define PI 3.1415927
#define PI2 6.2831855
            float2x2 rot(float a)
            {
                return transpose(float2x2(cos(a), sin(a), -sin(a), cos(a)));
            }

            float3 hue(float t, float f)
            {
                return f+f*cos(PI2*t*(float3(1, 0.75, 0.75)+float3(0.96, 0.57, 0.12)));
            }

            float hash21(float2 a)
            {
                return frac(sin(dot(a, float2(27.69, 32.58)))*43758.53);
            }

            float box(float2 p, float2 b)
            {
                float2 d = abs(p)-b;
                return length(max(d, 0.))+min(max(d.x, d.y), 0.);
            }

            static float2x2 r90;
            float2 pattern(float2 p, float sc)
            {
                float2 uv = p;
                float2 id = floor(p*sc);
                p = frac(p*sc)-0.5;
                float rnd = hash21(id);
                if (rnd>0.5)
                    p = mul(p,r90);
                    
                rnd = frac(rnd*32.54);
                if (rnd>0.4)
                    p = mul(p,r90);
                    
                if (rnd>0.8)
                    p = mul(p,r90);
                    
                rnd = frac(rnd*47.13);
                float tk = 0.075;
                float d = box(p-float2(0.6, 0.7), float2(0.25, 0.75))-0.15;
                float l = box(p-float2(0.7, 0.5), float2(0.75, 0.15))-0.15;
                float b = box(p+float2(0, 0.7), float2(0.05, 0.25))-0.15;
                float r = box(p+float2(0.6, 0), float2(0.15, 0.05))-0.15;
                d = abs(d)-tk;
                if (rnd>0.92)
                {
                    d = box(p-float2(-0.6, 0.5), float2(0.25, 0.15))-0.15;
                    l = box(p-float2(0.6, 0.6), ((float2)0.25))-0.15;
                    b = box(p+float2(0.6, 0.6), ((float2)0.25))-0.15;
                    r = box(p-float2(0.6, -0.6), ((float2)0.25))-0.15;
                    d = abs(d)-tk;
                }
                else if (rnd>0.6)
                {
                    d = length(p.x-0.2)-tk;
                    l = box(p-float2(-0.6, 0.5), float2(0.25, 0.15))-0.15;
                    b = box(p+float2(0.6, 0.6), ((float2)0.25))-0.15;
                    r = box(p-float2(0.3, 0), float2(0.25, 0.05))-0.15;
                }
                
                l = abs(l)-tk;
                b = abs(b)-tk;
                r = abs(r)-tk;
                float e = min(d, min(l, min(b, r)));
                if (rnd>0.6)
                {
                    r = max(r, -box(p-float2(0.2, 0.2), ((float2)tk*1.3)));
                    d = max(d, -box(p+float2(-0.2, 0.2), ((float2)tk*1.3)));
                }
                else 
                {
                    l = max(l, -box(p-float2(0.2, 0.2), ((float2)tk*1.3)));
                }
                d = min(d, min(l, min(b, r)));
                return float2(d, e);
            }

            float4 frag (v2f __vertex_output) : SV_Target
            {
                vertex_output = __vertex_output;
                float4 O = 0;
                float2 F = vertex_output.uv * _Resolution;
                float3 C = ((float3)0.);
                float2 uv = (2.*F-R.xy)/max(R.x, R.y);
                r90 = rot(1.5707);
                uv = mul(uv,rot(T*0.095));
                uv = float2(log(length(uv)), atan2(uv.y, uv.x)*6./PI2);
                float scale = 8.;
                for (float i = 0.;i<4.; i++)
                {
                    float ff = i*0.05+0.2;
                    uv.x += T*ff;
                    float px = fwidth(uv.x*scale);
                    float2 d = pattern(uv, scale);
                    float3 clr = hue(sin(uv.x+i*8.)*0.2+0.4, (0.5+i)*0.15);
                    C = lerp(C, ((float3)0.001), smoothstep(px, -px, d.y-0.04));
                    C = lerp(C, clr, smoothstep(px, -px, d.x));
                    scale *= 0.5;
                }
                C = pow(C, ((float3)0.4545));
                O = float4(C, 1.);
                if (_GammaCorrect) O.rgb = pow(O.rgb, 2.2);
                return O;
            }
            ENDCG
        }
    }
}
