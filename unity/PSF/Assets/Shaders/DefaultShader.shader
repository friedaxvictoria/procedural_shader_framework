Shader "Custom/DefaultShader"
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

            struct SDF 
            {
                int type;
                float3 position;
                float3 size;
                float radius;
            };
            static int gHitID;
            static SDF sdfArray[10];
            float sdSphere(float3 position, float radius)
            {
                return length(position)-radius;
            }

            float sdRoundBox(float3 p, float3 b, float r)
            {
                float3 q = abs(p)-b+r;
                return length(max(q, 0.))+min(max(q.x, max(q.y, q.z)), 0.)-r;
            }

            float sdTorus(float3 p, float2 radius)
            {
                float2 q = float2(length(p.xy)-radius.x, p.z);
                return length(q)-radius.y;
            }

            float evalSDF(SDF s, float3 p)
            {
                if (s.type==0)
                {
                    return sdSphere(p-s.position, s.radius);
                }
                else if (s.type==1)
                {
                    return sdRoundBox(p-s.position, s.size, s.radius);
                }
                else if (s.type==2)
                    return sdTorus(p-s.position, s.size.yz);
                    
                return 100000.;
            }

            float evaluateScene(float3 p)
            {
                float d = 100000.;
                int bestID = -1;
                for (int i = 0;i<10; ++i)
                {
                    float di = evalSDF(sdfArray[i], p);
                    if (di<d)
                    {
                        d = di;
                        bestID = i;
                    }
                    
                }
                gHitID = bestID;
                return d;
            }

            float3 getNormal(float3 p)
            {
                float h = 0.0001;
                float2 k = float2(1, -1);
                return normalize(k.xyy*evaluateScene(p+k.xyy*h)+k.yyx*evaluateScene(p+k.yyx*h)+k.yxy*evaluateScene(p+k.yxy*h)+k.xxx*evaluateScene(p+k.xxx*h));
            }

            float2 GetGradient(float2 intPos, float t)
            {
                float rand = frac(sin(dot(intPos, float2(12.9898, 78.233)))*43758.547);
                float angle = 6.283185*rand+4.*t*rand;
                return float2(cos(angle), sin(angle));
            }

            float Pseudo3dNoise(float3 pos)
            {
                float2 i = floor(pos.xy);
                float2 f = frac(pos.xy);
                float2 blend = f*f*(3.-2.*f);
                float a = dot(GetGradient(i+float2(0, 0), pos.z), f-float2(0., 0.));
                float b = dot(GetGradient(i+float2(1, 0), pos.z), f-float2(1., 0.));
                float c = dot(GetGradient(i+float2(0, 1), pos.z), f-float2(0., 1.));
                float d = dot(GetGradient(i+float2(1, 1), pos.z), f-float2(1., 1.));
                float xMix = lerp(a, b, blend.x);
                float yMix = lerp(c, d, blend.x);
                return lerp(xMix, yMix, blend.y)/0.7;
            }

            float fbmPseudo3D(float3 p, int octaves)
            {
                float result = 0.;
                float amplitude = 0.5;
                float frequency = 1.;
                for (int i = 0;i<octaves; ++i)
                {
                    result += amplitude*Pseudo3dNoise(p*frequency);
                    frequency *= 2.;
                    amplitude *= 0.5;
                }
                return result;
            }

            float4 hash44(float4 p)
            {
                p = frac(p*float4(0.1031, 0.103, 0.0973, 0.1099));
                p += dot(p, p.wzxy+33.33);
                return frac((p.xxyz+p.yzzw)*p.zywx);
            }

            float n31(float3 p)
            {
                const float3 S = float3(7., 157., 113.);
                float3 ip = floor(p);
                p = frac(p);
                p = p*p*(3.-2.*p);
                float4 h = float4(0., S.yz, S.y+S.z)+dot(ip, S);
                h = lerp(hash44(h), hash44(h+S.x), p.x);
                h.xy = lerp(h.xz, h.yw, p.y);
                return lerp(h.x, h.y, p.z);
            }

            float fbm_n31(float3 p, int octaves)
            {
                float value = 0.;
                float amplitude = 0.5;
                for (int i = 0;i<octaves; ++i)
                {
                    value += amplitude*n31(p);
                    p *= 2.;
                    amplitude *= 0.5;
                }
                return value;
            }

            struct MaterialParams 
            {
                float3 baseColor;
                float3 specularColor;
                float specularStrength;
                float shininess;
                float roughness;
                float metallic;
                float rimPower;
                float fakeSpecularPower;
                float3 fakeSpecularColor;
                float ior;
                float refractionStrength;
                float3 refractionTint;
            };
            MaterialParams createDefaultMaterialParams()
            {
                MaterialParams mat;
                mat.baseColor = ((float3)1.);
                mat.specularColor = ((float3)1.);
                mat.specularStrength = 1.;
                mat.shininess = 32.;
                mat.roughness = 0.5;
                mat.metallic = 0.;
                mat.rimPower = 2.;
                mat.fakeSpecularPower = 32.;
                mat.fakeSpecularColor = ((float3)1.);
                mat.ior = 1.45;
                mat.refractionStrength = 0.;
                mat.refractionTint = ((float3)1.);
                return mat;
            }

            MaterialParams makePlastic(float3 color)
            {
                MaterialParams mat = createDefaultMaterialParams();
                mat.baseColor = color;
                mat.metallic = 0.;
                mat.roughness = 0.4;
                mat.specularStrength = 0.5;
                return mat;
            }

            struct LightingContext 
            {
                float3 position;
                float3 normal;
                float3 viewDir;
                float3 lightDir;
                float3 lightColor;
                float3 ambient;
            };
            float3 applyPhongLighting(LightingContext ctx, MaterialParams mat)
            {
                float diff = max(dot(ctx.normal, ctx.lightDir), 0.);
                float3 R = reflect(-ctx.lightDir, ctx.normal);
                float spec = pow(max(dot(R, ctx.viewDir), 0.), mat.shininess);
                float3 diffuse = diff*mat.baseColor*ctx.lightColor;
                float3 specular = spec*mat.specularColor*mat.specularStrength;
                return ctx.ambient+diffuse+specular;
            }

            float raymarch(float3 ro, float3 rd, out float3 hitPos)
            {
                hitPos = 0;
                float t = 0.;
                for (int i = 0;i<100; i++)
                {
                    float3 p = ro+rd*t;
                    float noise = fbmPseudo3D(p, 1);
                    float d = evaluateScene(p)+noise*0.3;
                    if (d<0.001)
                    {
                        hitPos = p;
                        return t;
                    }
                    
                    if (t>50.)
                        break;
                        
                    t += d;
                }
                return -1.;
            }

            float4 frag (v2f __vertex_output) : SV_Target
            {
                vertex_output = __vertex_output;
                float4 fragColor = 0;
                float2 fragCoord = vertex_output.uv * _Resolution;
                float2 uv = fragCoord/iResolution.xy*2.-1.;
                uv.x *= iResolution.x/iResolution.y;

                SDF circle;
                circle.type = 0;
                circle.position = float3(0.0, 0.0, 0.0);
                circle.size = float3(0.0, 0.0, 0.0);
                circle.radius = 1.0;

                SDF roundBox;
                roundBox.type = 1;
                roundBox.position = float3(1.9, 0.0, 0.0);
                roundBox.size = float3(1.0, 1.0, 1.0);
                roundBox.radius = 0.2;

                SDF roundBox2;
                roundBox2.type = 1;
                roundBox2.position = float3(-1.9, 0.0, 0.0);
                roundBox2.size = float3(1.0, 1.0, 1.0);
                roundBox2.radius = 0.2;

                SDF torus;
                torus.type = 2;
                torus.position = float3(0.0, 0.0, 0.0);
                torus.size = float3(1.0, 5.0, 1.5);
                torus.radius = 0.2;

                sdfArray[0] = circle;
                sdfArray[1] = roundBox;
                sdfArray[2] = roundBox2;
                sdfArray[3] = torus;
                float3 ro = float3(0, 0, 7);
                float3 rd = normalize(float3(uv, -1));
                float3 hitPos;
                float t = raymarch(ro, rd, hitPos);
                float3 color;
                if (t>0.)
                {
                    float3 normal = getNormal(hitPos);
                    float3 viewDir = normalize(ro-hitPos);
                    float3 lightPos = float3(5., 5., 5.);
                    float3 lightColor = ((float3)1.);
                    float3 L = normalize(lightPos-hitPos);
                    float3 ambientCol = ((float3)0.1);
                    LightingContext ctx;
                    ctx.position = hitPos;
                    ctx.normal = normal;
                    ctx.viewDir = viewDir;
                    ctx.lightDir = L;
                    ctx.lightColor = lightColor;
                    ctx.ambient = ambientCol;
                    MaterialParams mat;
                    if (gHitID==0)
                    {
                        mat = makePlastic(float3(0.2, 0.2, 1.));
                    }
                    else if (gHitID==1||gHitID==2)
                    {
                        mat = makePlastic(float3(0.2, 1., 0.2));
                    }
                    else if (gHitID==3)
                    {
                        mat = createDefaultMaterialParams();
                        mat.baseColor = float3(1., 0.2, 0.2);
                        mat.shininess = 64.;
                    }
                    else 
                    {
                        mat = createDefaultMaterialParams();
                    }
                    color = applyPhongLighting(ctx, mat);
                }
                else 
                {
                    color = ((float3)0.);
                }
                fragColor = float4(color, 1.);
                if (_GammaCorrect) fragColor.rgb = pow(fragColor.rgb, 2.2);
                return fragColor;
            }
            ENDCG
        }
    }
}
