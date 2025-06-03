Shader "Custom/Shader2"
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

            float4x4 rotationMatrix(float3 axis, float angle)
            {
                axis = normalize(axis);
                float s = sin(angle);
                float c = cos(angle);
                float oc = 1.-c;
                return transpose(float4x4(oc*axis.x*axis.x+c, oc*axis.x*axis.y-axis.z*s, oc*axis.z*axis.x+axis.y*s, 0., oc*axis.x*axis.y+axis.z*s, oc*axis.y*axis.y+c, oc*axis.y*axis.z-axis.x*s, 0., oc*axis.z*axis.x-axis.y*s, oc*axis.y*axis.z+axis.x*s, oc*axis.z*axis.z+c, 0., 0., 0., 0., 1.));
            }

            float3 rotate(float3 v, float3 axis, float angle)
            {
                float4x4 m = rotationMatrix(axis, angle);
                return (mul(m,float4(v, 1.))).xyz;
            }

            float sdSphere(float3 p)
            {
                return length(p)-0.5;
            }

            float sdBox(float3 p, float3 b)
            {
                float3 q = abs(p)-b;
                return length(max(q, 0.))+min(max(q.x, max(q.y, q.z)), 0.);
            }

            float SineCrazy(float3 p)
            {
                return 1.-(sin(p.x)-sin(p.y)+sin(p.z))/3.;
            }

            float CosCrazy(float3 p)
            {
                return 1.-(cos(p.x)+2.*cos(p.y)+cos(p.z))/3.;
            }

            float sdOctahedron(float3 p)
            {
                p = abs(p);
                float m = p.x+p.y+p.z-0.8;
                float3 q;
                if (3.*p.x<m)
                q = p.xyz;
                else if (3.*p.y<m)
                q = p.yzx;
                else if (3.*p.z<m)
                q = p.zxy;
                else return m*0.57735026;
                float k = clamp(0.5*(q.z-q.y+0.5), 0., 0.5);
                return length(float3(q.x, q.y-0.5+k, q.z-k));
            }

            float scene(float3 p)
            {
                float3 p1 = rotate(p, float3(0.1, 1., 0.1), _Time.y/10.);
                float scale = 8.+5.*sin(_Time.y/12.);
                return max(sdOctahedron(p1), (0.85-SineCrazy(p1*scale))/scale);
            }

            float3 getNormal(float3 p)
            {
                float2 o = float2(0.001, 0.);
                return normalize(float3(scene(p+o.xyy)-scene(p-o.xyy), scene(p+o.yxy)-scene(p-o.yxy), scene(p+o.yyx)-scene(p-o.yyx)));
            }

            float3 GetColorAmount(float3 p)
            {
                float amount = clamp((1.5-length(p))/2., 0., 1.);
                float3 col = 0.5+0.5*cos(6.28319*(float3(0.2, 0., 0.)+amount*float3(1., 1., 0.5)));
                return col*amount;
            }

            float4 frag (v2f __vertex_output) : SV_Target
            {
                vertex_output = __vertex_output;
                float4 fragColor = 0;
                float2 fragCoord = vertex_output.uv * _Resolution;
                float2 newUV = fragCoord/iResolution.xy;
                float2 p = newUV-((float2)0.5);
                float3 camPos = float3(-0.5, 0., 2.+0.5*sin(_Time.y/4.));
                float3 ray = normalize(float3(p, -1.));
                float3 rayPos = camPos;
                float curDist = 0.;
                float rayLen = 0.;
                float3 light = float3(-1., 1., 1.);
                float3 color = ((float3)0.);
                for (int i = 0;i<64; ++i)
                {
                    curDist = scene(rayPos);
                    rayLen += 0.6*curDist;
                    rayPos = camPos+ray*rayLen;
                    if (abs(curDist)<0.001)
                    {
                        float3 n = getNormal(rayPos);
                        float diff = dot(n, light);
                        break;
                    }
                    
                    color += 0.04*GetColorAmount(rayPos);
                }
                fragColor = float4(color, 1.);
                if (_GammaCorrect) fragColor.rgb = pow(fragColor.rgb, 2.2);
                return fragColor;
            }
            ENDCG
        }
    }
}
