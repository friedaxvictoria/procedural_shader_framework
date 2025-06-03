Shader "Custom/Shader6"
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

#define MaxSteps 30
#define MinimumDistance 0.0009
#define normalDistance 0.0002
#define PI 3.141592
#define Scale 3.
#define FieldOfView 0.5
#define Jitter 0.06
#define FudgeFactor 1.
#define Ambient 0.32184
#define Diffuse 0.5
#define LightDir ((float3)1.)
#define LightColor float3(0.6, 1., 0.158824)
#define LightDir2 float3(1., -1., 1.)
#define LightColor2 float3(1., 0.933333, 1.)
#define Offset float3(0.92858, 0.92858, 0.32858)
            float3x3 rotationMatrix3(float3 v, float angle)
            {
                float c = cos(radians(angle));
                float s = sin(radians(angle));
                return transpose(float3x3(c+(1.-c)*v.x*v.x, (1.-c)*v.x*v.y-s*v.z, (1.-c)*v.x*v.z+s*v.y, (1.-c)*v.x*v.y+s*v.z, c+(1.-c)*v.y*v.y, (1.-c)*v.y*v.z-s*v.x, (1.-c)*v.x*v.z-s*v.y, (1.-c)*v.y*v.z+s*v.x, c+(1.-c)*v.z*v.z));
            }

            float2 rotate(float2 v, float a)
            {
                return float2(cos(a)*v.x+sin(a)*v.y, -sin(a)*v.x+cos(a)*v.y);
            }

#define Type 5
            static float U;
            static float V;
            static float W;
            static float T = 1.;
            static float VRadius = 0.05048;
            static float SRadius = 0.05476;
            static float3 RotVector = float3(0., 1., 1.);
            static float RotAngle = 0.;
            static float3x3 rot;
            static float4 nc, nd, p;
            void init()
            {
                U = 0.*cos(_Time.y)*0.5+0.1;
                V = 0.2*sin(_Time.y*0.1)*0.5+0.2;
                W = 1.*cos(_Time.y*1.2)*0.5+0.5;
                if (_Mouse.z>0.)
                {
                    U = _Mouse.x/iResolution.x;
                    W = 1.-U;
                    V = _Mouse.y/iResolution.y;
                    T = 1.-V;
                }
                
                float cospin = cos(PI/float(Type)), isinpin = 1./sin(PI/float(Type));
                float scospin = sqrt(2./3.-cospin*cospin), issinpin = 1./sqrt(3.-4.*cospin*cospin);
                nc = 0.5*float4(0, -1, sqrt(3.), 0.);
                nd = float4(-cospin, -0.5, -0.5/sqrt(3.), scospin);
                float4 pabc, pbdc, pcda, pdba;
                pabc = float4(0., 0., 0., 1.);
                pbdc = 0.5*sqrt(3.)*float4(scospin, 0., 0., cospin);
                pcda = isinpin*float4(0., 0.5*sqrt(3.)*scospin, 0.5*scospin, 1./sqrt(3.));
                pdba = issinpin*float4(0., 0., 2.*scospin, 1./sqrt(3.));
                p = normalize(U*pabc+V*pbdc+W*pcda+T*pdba);
                rot = rotationMatrix3(normalize(RotVector), RotAngle);
            }

            float4 fold(float4 pos)
            {
                for (int i = 0;i<Type*(Type-2); i++)
                {
                    pos.xy = abs(pos.xy);
                    float t = -2.*min(0., dot(pos, nc));
                    pos += t*nc;
                    t = -2.*min(0., dot(pos, nd));
                    pos += t*nd;
                }
                return pos;
            }

            float DD(float ca, float sa, float r)
            {
                return r-(2.*r*ca-(1.-r*r)*sa)/((1.-r*r)*ca+2.*r*sa+1.+r*r);
            }

            float dist2Vertex(float4 z, float r)
            {
                float ca = dot(z, p), sa = 0.5*length(p-z)*length(p+z);
                return DD(ca, sa, r)-VRadius;
            }

            float dist2Segment(float4 z, float4 n, float r)
            {
                float zn = dot(z, n), zp = dot(z, p), np = dot(n, p);
                float alpha = zp-zn*np, beta = zn-zp*np;
                float4 pmin = normalize(alpha*p+min(0., beta)*n);
                float ca = dot(z, pmin), sa = 0.5*length(pmin-z)*length(pmin+z);
                return DD(ca, sa, r)-SRadius;
            }

            float dist2Segments(float4 z, float r)
            {
                float da = dist2Segment(z, float4(1., 0., 0., 0.), r);
                float db = dist2Segment(z, float4(0., 1., 0., 0.), r);
                float dc = dist2Segment(z, nc, r);
                float dd = dist2Segment(z, nd, r);
                return min(min(da, db), min(dc, dd));
            }

            float DE(float3 pos)
            {
                float r = length(pos);
                float4 z4 = float4(2.*pos, 1.-r*r)*1./(1.+r*r);
                z4.xyw = mul(rot,z4.xyw);
                z4 = fold(z4);
                return min(dist2Vertex(z4, r), dist2Segments(z4, r));
            }

            static float3 lightDir;
            static float3 lightDir2;
            float3 getLight(in float3 color, in float3 normal, in float3 dir)
            {
                float diffuse = max(0., dot(-normal, lightDir));
                float diffuse2 = max(0., dot(-normal, lightDir2));
                return diffuse*Diffuse*(LightColor*color)+diffuse2*Diffuse*(LightColor2*color);
            }

            float3 getNormal(in float3 pos)
            {
                float3 e = float3(0., normalDistance, 0.);
                return normalize(float3(DE(pos+e.yxx)-DE(pos-e.yxx), DE(pos+e.xyx)-DE(pos-e.xyx), DE(pos+e.xxy)-DE(pos-e.xxy)));
            }

            float3 getColor(float3 normal, float3 pos)
            {
                return float3(1., 1., 1.);
            }

            float rand(float2 co)
            {
                return frac(cos(dot(co, float2(4.898, 7.23)))*23421.63);
            }

            float4 rayMarch(in float3 from, in float3 dir, in float2 fragCoord)
            {
                float totalDistance = Jitter*rand(fragCoord.xy+((float2)_Time.y));
                float3 dir2 = dir;
                float distance;
                int steps = 0;
                float3 pos;
                for (int i = 0;i<=MaxSteps; i++)
                {
                    pos = from+totalDistance*dir;
                    distance = DE(pos)*FudgeFactor;
                    totalDistance += distance;
                    if (distance<MinimumDistance)
                        break;
                        
                    steps = i;
                }
                float smoothStep = float(steps);
                float ao = 1.-smoothStep/float(MaxSteps);
                float3 normal = getNormal(pos-dir*normalDistance*3.);
                float3 bg = ((float3)0.2);
                if (steps==MaxSteps)
                {
                    return float4(bg, 1.);
                }
                
                float3 color = getColor(normal, pos);
                float3 light = getLight(color, normal, dir);
                color = lerp(color*Ambient+light, bg, 1.-ao);
                return float4(color, 1.);
            }

#define BLACK_AND_WHITE 
#define LINES_AND_FLICKER 
#define BLOTCHES 
#define GRAIN 
#define FREQUENCY 10.
            static float2 uv;
            float rand(float c)
            {
                return rand(float2(c, 1.));
            }

            float randomLine(float seed)
            {
                float b = 0.01*rand(seed);
                float a = rand(seed+1.);
                float c = rand(seed+2.)-0.5;
                float mu = rand(seed+3.);
                float l = 1.;
                if (mu>0.2)
                l = pow(abs(a*uv.x+b*uv.y+c), 1./8.);
                else l = 2.-pow(abs(a*uv.x+b*uv.y+c), 1./8.);
                return lerp(0.5, 1., l);
            }

            float randomBlotch(float seed)
            {
                float x = rand(seed);
                float y = rand(seed+1.);
                float s = 0.01*rand(seed+2.);
                float2 p = float2(x, y)-uv;
                p.x *= iResolution.x/iResolution.y;
                float a = atan2(p.y, p.x);
                float v = 1.;
                float ss = s*s*(sin(6.2831*a*x)*0.1+1.);
                if (dot(p, p)<ss)
                v = 0.2;
                else v = pow(dot(p, p)-ss, 1./16.);
                return lerp(0.3+0.2*(1.-s/0.02), 1., v);
            }

            float3 degrade(float3 image)
            {
                float t = float(int(_Time.y*FREQUENCY));
                float2 suv = uv+0.002*float2(rand(t), rand(t+23.));
#ifdef BLACK_AND_WHITE
                float luma = dot(float3(0.2126, 0.7152, 0.0722), image);
                float3 oldImage = luma*float3(0.7, 0.7, 0.7);
#else
                float3 oldImage = image;
#endif
                float vI = 16.*(uv.x*(1.-uv.x)*uv.y*(1.-uv.y));
                vI *= lerp(0.7, 1., rand(t+0.5));
                vI += 1.+0.4*rand(t+8.);
                vI *= pow(16.*uv.x*(1.-uv.x)*uv.y*(1.-uv.y), 0.4);
#ifdef LINES_AND_FLICKER
                int l = int(8.*rand(t+7.));
                if (0<l)
                    vI *= randomLine(t+6.+17.*float(0));
                    
                if (1<l)
                    vI *= randomLine(t+6.+17.*float(1));
                    
                if (2<l)
                    vI *= randomLine(t+6.+17.*float(2));
                    
                if (3<l)
                    vI *= randomLine(t+6.+17.*float(3));
                    
                if (4<l)
                    vI *= randomLine(t+6.+17.*float(4));
                    
                if (5<l)
                    vI *= randomLine(t+6.+17.*float(5));
                    
                if (6<l)
                    vI *= randomLine(t+6.+17.*float(6));
                    
                if (7<l)
                    vI *= randomLine(t+6.+17.*float(7));
                    
#endif
#ifdef BLOTCHES
                int s = int(max(8.*rand(t+18.)-2., 0.));
                if (0<s)
                    vI *= randomBlotch(t+6.+19.*float(0));
                    
                if (1<s)
                    vI *= randomBlotch(t+6.+19.*float(1));
                    
                if (2<s)
                    vI *= randomBlotch(t+6.+19.*float(2));
                    
                if (3<s)
                    vI *= randomBlotch(t+6.+19.*float(3));
                    
                if (4<s)
                    vI *= randomBlotch(t+6.+19.*float(4));
                    
                if (5<s)
                    vI *= randomBlotch(t+6.+19.*float(5));
                    
#endif
                float3 outv = oldImage*vI;
#ifdef GRAIN
                outv *= 1.+(rand(uv+t*0.01)-0.2)*0.15;
#endif
                return outv;
            }

            float4 frag (v2f __vertex_output) : SV_Target
            {
                vertex_output = __vertex_output;
                float4 fragColor = 0;
                float2 fragCoord = vertex_output.uv * _Resolution;
                uv = fragCoord.xy/iResolution.xy;
                init();
                float3 camPos = (12.+2.*sin(_Time.y*0.6))*float3(cos(_Time.y*0.3), 0., sin(_Time.y*0.3));
                float3 target = float3(0., 0., 0.);
                float3 camUp = float3(0., 1., 0.);
                float3 camDir = normalize(target-camPos);
                camUp = normalize(camUp-dot(camDir, camUp)*camDir);
                float3 camRight = normalize(cross(camDir, camUp));
                lightDir = -normalize(camPos+7.5*camUp);
                lightDir2 = -normalize(camPos-6.5*camRight);
                float2 coord = -1.+2.*fragCoord.xy/iResolution.xy;
                float vignette = 0.4+(1.-coord.x*coord.x)*(1.-coord.y*coord.y);
                coord.x *= iResolution.x/iResolution.y;
                float3 rayDir = normalize(camDir+(coord.x*camRight+coord.y*camUp)*FieldOfView);
                float3 col = rayMarch(camPos, rayDir, fragCoord).xyz;
                col = degrade(col);
                fragColor = float4(col, 1.);
                if (_GammaCorrect) fragColor.rgb = pow(fragColor.rgb, 2.2);
                return fragColor;
            }
            ENDCG
        }
    }
}
