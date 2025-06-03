Shader "Custom/Shader4"
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

#define hash(x) frac(sin(x)*43758.547)
            float3 pal(float t)
            {
                return 0.5+0.5*cos(6.28*(1.*t+float3(0., 0.1, 0.1)));
            }

            float stepNoise(float x, float n)
            {
                const float factor = 0.3;
                float i = floor(x);
                float f = x-i;
                float u = smoothstep(0.5-factor, 0.5+factor, f);
                float res = lerp(floor(hash(i)*n), floor(hash(i+1.)*n), u);
                res /= (n-1.)*0.5;
                return res-1.;
            }

            float3 path(float3 p)
            {
                float3 o = ((float3)0.);
                o.x += stepNoise(p.z*0.05, 5.)*5.;
                o.y += stepNoise(p.z*0.07, 3.975)*5.;
                return o;
            }

            float diam2(float2 p, float s)
            {
                p = abs(p);
                return (p.x+p.y-s)*rsqrt(3.);
            }

            float3 erot(float3 p, float3 ax, float t)
            {
                return lerp(dot(ax, p)*ax, p, cos(t))+cross(ax, p)*sin(t);
            }

            float4 frag (v2f __vertex_output) : SV_Target
            {
                vertex_output = __vertex_output;
                float4 fragColor = 0;
                float2 fragCoord = vertex_output.uv * _Resolution;
                float2 uv = (fragCoord-0.5*iResolution.xy)/iResolution.y;
                float3 col = ((float3)0.);
                float3 ro = float3(0., 0., -1.), rt = ((float3)0.);
                ro.z += _Time.y*5.;
                rt.z += _Time.y*5.;
                ro += path(ro);
                rt += path(rt);
                float3 z = normalize(rt-ro);
                float3 x = float3(z.z, 0., -z.x);
                float i = 0., e = 0., g = 0.;
                float3 rd = mul(transpose(float3x3(x, cross(z, x), z)),erot(normalize(float3(uv, 1.)), float3(0., 0., 1.), stepNoise(_Time.y+hash(uv.x*uv.y*_Time.y)*0.05, 6.)));
                for (;i++<99.; )
                {
                    float3 p = ro+rd*g;
                    p -= path(p);
                    float r = 0.;
                    ;
                    float3 pp = p;
                    float sc = 1.;
                    for (float j = 0.;j++<4.; )
                    {
                        r = clamp(r+abs(dot(sin(pp*3.), cos(pp.yzx*2.))*0.3-0.1)/sc, -0.5, 0.5);
                        pp = erot(pp, normalize(float3(0.1, 0.2, 0.3)), 0.785+j);
                        pp += pp.yzx+j*50.;
                        sc *= 1.5;
                        pp *= 1.5;
                    }
                    float h = abs(diam2(p.xy, 7.))-3.-r;
                    p = erot(p, float3(0., 0., 1.), path(p).x*0.5+p.z*0.2);
                    float t = length(abs(p.xy)-0.5)-0.1;
                    h = min(t, h);
                    g += e = max(0.001, t==h ? abs(h) : h);
                    col += (t==h ? float3(0.3, 0.2, 0.1)*(100.*exp(-20.*frac(p.z*0.25+_Time.y)))*glsl_mod(floor(p.z*4.)+glsl_mod(floor(p.y*4.), 2.), 2.) : ((float3)0.1))*0.0325/exp(i*i*e);
                    ;
                }
                col = lerp(col, float3(0.9, 0.9, 1.1), 1.-exp(-0.01*g*g*g));
                fragColor = float4(col, 1.);
                if (_GammaCorrect) fragColor.rgb = pow(fragColor.rgb, 2.2);
                return fragColor;
            }
            ENDCG
        }
    }
}
