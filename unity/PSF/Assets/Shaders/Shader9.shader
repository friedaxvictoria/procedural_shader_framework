Shader "Custom/Shader9"
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

            float heightMap(in float2 p)
            {
                p *= 3.;
                float2 h = float2(p.x+p.y*0.57735, p.y*1.1547);
                float2 fh = floor(h);
                float2 f = h-fh;
                h = fh;
                float c = frac((h.x+h.y)/3.);
                h = c<0.666 ? c<0.333 ? h : h+1. : h+step(f.yx, f);
                p -= float2(h.x-h.y*0.5, h.y*0.8660254);
                c = frac(cos(dot(h, float2(41, 289)))*43758.547);
                p -= p*step(c, 0.5)*2.;
                p -= float2(-1, 0);
                c = dot(p, p);
                p -= float2(1.5, 0.8660254);
                c = min(c, dot(p, p));
                p -= float2(0, -1.73205);
                c = min(c, dot(p, p));
                return sqrt(c);
            }

            float map(float3 p)
            {
                float c = heightMap(p.xy);
                c = cos(c*6.283159)+cos(c*6.283159*2.);
                c = clamp(c*0.6+0.5, 0., 1.);
                return 1.-p.z-c*0.025;
            }

            float3 getNormal(float3 p, inout float edge, inout float crv)
            {
                float2 e = float2(0.01, 0);
                float d1 = map(p+e.xyy), d2 = map(p-e.xyy);
                float d3 = map(p+e.yxy), d4 = map(p-e.yxy);
                float d5 = map(p+e.yyx), d6 = map(p-e.yyx);
                float d = map(p)*2.;
                edge = abs(d1+d2-d)+abs(d3+d4-d)+abs(d5+d6-d);
                edge = smoothstep(0., 1., sqrt(edge/e.x*2.));
                crv = clamp((d1+d2+d3+d4+d5+d6-d*3.)*32.+0.6, 0., 1.);
                e = float2(0.0025, 0);
                d1 = map(p+e.xyy), d2 = map(p-e.xyy);
                d3 = map(p+e.yxy), d4 = map(p-e.yxy);
                d5 = map(p+e.yyx), d6 = map(p-e.yyx);
                return normalize(float3(d1-d2, d3-d4, d5-d6));
            }

            float calculateAO(in float3 p, in float3 n)
            {
                float sca = 2., occ = 0.;
                for (float i = 0.;i<5.; i++)
                {
                    float hr = 0.01+i*0.5/4.;
                    float dd = map(n*hr+p);
                    occ += (hr-dd)*sca;
                    sca *= 0.7;
                }
                return clamp(1.-occ, 0., 1.);
            }

            float n3D(float3 p)
            {
                const float3 s = float3(7, 157, 113);
                float3 ip = floor(p);
                p -= ip;
                float4 h = float4(0., s.yz, s.y+s.z)+dot(ip, s);
                p = p*p*(3.-2.*p);
                h = lerp(frac(sin(glsl_mod(h, 6.283159))*43758.547), frac(sin(glsl_mod(h+s.x, 6.283159))*43758.547), p.x);
                h.xy = lerp(h.xz, h.yw, p.y);
                return lerp(h.x, h.y, p.z);
            }

            float3 envMap(float3 rd, float3 sn)
            {
                float3 sRd = rd;
                rd.xy -= _Time.y*0.25;
                rd *= 3.;
                float c = n3D(rd)*0.57+n3D(rd*2.)*0.28+n3D(rd*4.)*0.15;
                c = smoothstep(0.4, 1., c);
                float3 col = float3(c, c*c, c*c*c*c);
                return lerp(col, col.yzx, sRd*0.25+0.25);
            }

            float2 hash22(float2 p)
            {
                float n = sin(glsl_mod(dot(p, float2(41, 289)), 6.283159));
                return frac(float2(262144, 32768)*n)*0.75+0.25;
            }

            float Voronoi(in float2 p)
            {
                float2 g = floor(p), o;
                p -= g;
                float3 d = ((float3)1);
                for (int y = -1;y<=1; y++)
                {
                    for (int x = -1;x<=1; x++)
                    {
                        o = float2(x, y);
                        o += hash22(g+o)-p;
                        d.z = dot(o, o);
                        d.y = max(d.x, min(d.y, d.z));
                        d.x = min(d.x, d.z);
                    }
                }
                return max(d.y/1.2-d.x*1., 0.)/1.2;
            }

            float4 frag (v2f __vertex_output) : SV_Target
            {
                vertex_output = __vertex_output;
                float4 fragColor = 0;
                float2 fragCoord = vertex_output.uv * _Resolution;
                float3 rd = normalize(float3(2.*fragCoord-iResolution.xy, iResolution.y));
                float tm = _Time.y/2.;
                float2 a = sin(float2(1.570796, 0)+sin(tm/4.)*0.3);
                rd.xy = mul(transpose(float2x2(a, -a.y, a.x)),rd.xy);
                float3 ro = float3(tm, cos(tm/4.), 0.);
                float3 lp = ro+float3(cos(tm/2.)*0.5, sin(tm/2.)*0.5, -0.5);
                float d, t = 0.;
                for (int j = 0;j<32; j++)
                {
                    d = map(ro+rd*t);
                    t += d*0.7;
                    if (d<0.001)
                        break;
                        
                }
                float edge, crv;
                float3 sp = ro+rd*t;
                float3 sn = getNormal(sp, edge, crv);
                float3 ld = lp-sp;
                float c = heightMap(sp.xy);
                float3 fold = cos(float3(1, 2, 4)*c*6.283159);
                float c2 = heightMap((sp.xy+sp.z*0.025)*6.);
                c2 = cos(c2*6.283159*3.);
                c2 = clamp(c2+0.5, 0., 1.);
                float3 oC = ((float3)1);
                if (fold.x>0.)
                    oC = float3(1, 0.05, 0.1)*c2;
                    
                if (fold.x<0.05&&fold.y<0.)
                oC = float3(1, 0.7, 0.45)*(c2*0.25+0.75);
                else if (fold.x<0.)
                    oC = float3(1, 0.8, 0.4)*c2;
                    
                float p1 = 1.-smoothstep(0., 0.1, fold.x*0.5+0.5);
                float p2 = 1.-smoothstep(0., 0.1, Voronoi(sp.xy*4.+float2(tm, cos(tm/4.))));
                p1 = (p2+0.25)*p1;
                oC += oC.yxz*p1*p1;
                float lDist = max(length(ld), 0.001);
                float atten = 1./(1.+lDist*0.125);
                ld /= lDist;
                float diff = max(dot(ld, sn), 0.);
                float spec = pow(max(dot(reflect(-ld, sn), -rd), 0.), 16.);
                float fre = pow(clamp(dot(sn, rd)+1., 0., 1.), 3.);
                crv = crv*0.9+0.1;
                float ao = calculateAO(sp, sn);
                float3 col = oC*(diff+0.5)+float3(1., 0.7, 0.4)*spec*2.+float3(0.4, 0.7, 1)*fre;
                col += (oC*0.5+0.5)*envMap(reflect(rd, sn), sn)*6.;
                col *= 1.-edge*0.85;
                col *= atten*crv*ao;
                fragColor = float4(sqrt(clamp(col, 0., 1.)), 1.);
                if (_GammaCorrect) fragColor.rgb = pow(fragColor.rgb, 2.2);
                return fragColor;
            }
            ENDCG
        }
    }
}
