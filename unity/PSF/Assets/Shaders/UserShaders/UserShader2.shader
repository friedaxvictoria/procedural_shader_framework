Shader "Custom/UserShader2"
{
    Properties
    {
        _Color ("Base Color", Color) = (1,1,1,1)
        _TimeSpeed ("Time Speed", Float) = 1.0

        // Built-in properties
        _MainTex ("iChannel0", 2D) = "white" {}
        _SecondTex ("iChannel1", 2D) = "white" {}
        _ThirdTex ("iChannel2", 2D) = "white" {}
        _FourthTex ("iChannel3", 2D) = "white" {}
        _Mouse ("Mouse", Vector) = (0.5, 0.5, 0.5, 0.5)
        [ToggleUI] _GammaCorrect ("Gamma Correction", Float) = 1
        _Resolution ("Resolution (Change if AA is bad)", Range(1, 1024)) = 1

        _TorusColor ("Torus Color", Vector) = (1.0, 0.2, 0.2)
        _TorusRadius ("Torus Radius", Float) = 0.2
        _TorusSize ("Torus Size", Vector) = (1.0, 5.0, 1.5)
        _TorusPosition ("Torus Position", Vector) = (0.0, 0.0, 0.0)

        _CubeColor ("Cube Color", Vector) = (0.2, 1, 0.2)
        _CubeSize ("Cube Size", Vector) = (1.0, 1.0, 1.0)
        _CubePosition1 ("Cube Position 1", Vector) = (1.9, 0.0, 0.0)
        _CubePosition2 ("Cube Position 2", Vector) = (-1.9, 0.0, 0.0)

        _SphereColor ("Sphere Color", Vector) = (0.2, 0.2, 1.0)
        _SphereRadius ("Sphere Radius", Float) = 1
        _SpherePosition ("Sphere Position", Vector) = (0.0, 0.0, 0.0)

        _LightPosition ("Light Position", Vector) = (5.0, 5.0, 5.0)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 300

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Assets/Shaders/Includes/ModularShaderLib.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            float4 _Color;
            float _TimeSpeed;
            float3 _TorusColor;
            float _TorusRadius;
            float3 _TorusSize;
            float3 _TorusPosition;
            float3 _CubeColor;
            float3 _CubeSize;
            float3 _CubePosition1;
            float3 _CubePosition2;
            float3 _SphereColor;
            float _SphereRadius;
            float3 _SpherePosition;
            float3 _LightPosition;

            Varyings vert (Attributes IN)
            {
                Varyings OUT;

                float3 pos = IN.positionOS.xyz;
                float time = _Time.y * _TimeSpeed;



                OUT.positionCS = TransformObjectToHClip(pos);
                OUT.uv = IN.uv;
                OUT.worldPos = TransformObjectToWorld(pos);

                return OUT;
            }

            float4 frag (Varyings IN) : SV_Target
            {

                float4 color4 = float4(1,1,1,1);

                // Integration(IN.uv, color4);

                Integration(IN.uv, color4, 
                    _TorusColor, _TorusRadius, _TorusSize, _TorusPosition
                    , _CubeColor, _CubeSize, _CubePosition1, _CubePosition2
                    , _SphereColor, _SphereRadius, _SpherePosition,
                    _LightPosition
                    );

                // ApplyWaterEffect(IN.uv, color4);
                
                return color4;
            }
            ENDHLSL
        }
    }
}
