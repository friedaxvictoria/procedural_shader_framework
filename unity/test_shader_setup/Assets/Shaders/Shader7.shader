Shader "Custom/Shader7"
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

#define moblur 4
#define harmonic 25
#define triangle 1
            float3 circle(float2 uv, float rr, float cc, float ss)
            {
                uv = mul(uv,transpose(float2x2(cc, ss, -ss, cc)));
                if (rr<0.)
                    uv.y = -uv.y;
                    
                rr = abs(rr);
                float r = length(uv)-rr;
                float pix = fwidth(r);
                float c = smoothstep(0., pix, abs(r));
                float l = smoothstep(0., pix, abs(uv.x)+step(uv.y, 0.)+step(rr, uv.y));
                return float3(c, c*l, c*l);
            }

            float3 ima(float2 uv, float th0)
            {
                float3 col = ((float3)1.);
                float2 uv0 = uv;
                th0 -= max(0., uv0.x-1.5)*2.;
                th0 -= max(0., uv0.y-1.5)*2.;
#ifndef triangle_
                float lerpy = 1.;
#else
                float lerpy = smoothstep(-0.6, 0.2, cos(th0*0.1));
#endif
                for (int i = 1;i<harmonic; i += 2)
                {
                    float th = th0*float(i);
                    float fl = glsl_mod(float(i), 4.)-2.;
                    float cc = cos(th)*fl, ss = sin(th);
                    float trir = -fl/float(i*i);
                    float sqrr = 1./float(i);
                    float rr = lerp(trir, sqrr, lerpy);
                    col = min(col, circle(uv, rr, cc, ss));
                    uv.x += rr*ss;
                    uv.y -= rr*cc;
                }
                float pix = fwidth(uv0.x);
                if (uv.y>0.&&frac(uv0.y*10.)<0.5)
                    col.yz = min(col.yz, smoothstep(0., pix, abs(uv.x)));
                    
                if (uv.x>0.&&frac(uv0.x*10.)<0.5)
                    col.yz = min(col.yz, smoothstep(0., pix, abs(uv.y)));
                    
                if (uv0.x>=1.5)
                    col.xy = ((float2)smoothstep(0., fwidth(uv.y), abs(uv.y)));
                    
                if (uv0.y>=1.5)
                    col.xy = ((float2)smoothstep(0., fwidth(uv.x), abs(uv.x)));
                    
                return col;
            }

            float4 frag (v2f __vertex_output) : SV_Target
            {
                vertex_output = __vertex_output;
                float4 fragColor = 0;
                float2 fragCoord = vertex_output.uv * _Resolution;
                float2 uv = fragCoord.xy/iResolution.yy;
                uv.y = 1.-uv.y;
                uv *= 5.;
                uv -= 1.5;
                float th0 = _Time.y*2.;
                float dt = 2./60./float(moblur);
                float3 col = ((float3)0.);
                for (int mb = 0;mb<moblur; ++mb)
                {
                    col += ima(uv, th0);
                    th0 += dt;
                }
                col = pow(col*(1./float(moblur)), ((float3)1./2.2));
                fragColor = float4(col, 1.);
                if (_GammaCorrect) fragColor.rgb = pow(fragColor.rgb, 2.2);
                return fragColor;
            }
            ENDCG
        }
    }
}
