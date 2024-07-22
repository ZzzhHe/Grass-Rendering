Shader "Custom/LitGrassShader"
{
    Properties
    {
        _TopColor ("Tip Color", Color) = (0.74, 1, 0.6, 1)
        _MidColor1 ("Color 2", Color) = (0.4, 0.8, 0.3, 1)
        _MidColor2 ("Color 1", Color) = (0.25, 0.5, 0.24, 1)
        _BaseColor ("Base Color", Color) = (0.14, 0.35, 0.1, 1)
        
        _WindSpeed ("Wind Speed", Range(0, 5.0)) = 1.0
        _WindScale ("Wind Scale", Range(0, 3.0)) = 1.0
        _WindFrequency ("Wind Frequency", Range(0, 3.0)) = 1.0
        _WindNoiseTex ("Wind Noise Texture", 2D) = "white" {}

        _Stiffness ("Stiffness", Range(0.1, 1.0)) = 0.5
        _Damping ("Damping", Range(0.1, 1.0)) = 0.2

        _BladeHeightVariation ("Blade Height Variation", Range(0, 2.0)) = 1.0
        _BladeHeightNoiseTex ("Blade Height Noise Texture", 2D) = "white" {}

        _BladeCurve ("Blade Curve", Range(0, 0.5)) = 0.2
        _BladeCurvePow ("Blade Curve Pow", Range(1.0, 3.0)) = 1.3
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "UniversalMaterialType" = "Lit"
            "RenderPipeline" = "UniversalPipeline"
        }

        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex GrassShaderVertex
            #pragma fragment GrassShaderFragment
            #pragma target 5.0

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"

            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS : NORMAL;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float3 normalWS : NORMAL;
                float4 positionWS : TEXCOORD1;
                float4 positionCS : SV_POSITION;
                float4 color : COLOR0;

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            uniform float4 _TopColor, _MidColor1, _MidColor2, _BaseColor;
            uniform float _BladeCurve, _BladeCurvePow;
            uniform float _WindSpeed, _WindScale, _WindFrequency;
            uniform sampler2D _WindNoiseTex;
            uniform float _Stiffness, _Damping;
            uniform float _BladeHeightVariation;
            uniform sampler2D _BladeHeightNoiseTex;
            
            float randInstance(uint seed)
            {
                return frac(sin(seed * 12.9898 + 78.233) * 43758.5453) - 0.5;
            }

            float randXZ(float2 xz) 
            {
                return frac(sin(dot(xz, float2(12.9898, 78.233))) * 43758.5453);
            }

            float calCurveFactor(float y) 
            {
                float x = lerp(0.0, 1.0, y);
                return pow(x, 2);
            }

            Varyings GrassShaderVertex(Attributes IN)
            {
                Varyings OUT = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

                float3 worldPosition = TransformObjectToWorld(IN.positionOS.xyz);
                float3 worldNormal = TransformObjectToWorldNormal(IN.normalOS);

                // random based on instance ID
                float instanceRandom = 0;
                #ifdef INSTANCING_ON
                instanceRandom = randInstance(IN.instanceID);
                #endif

                // Height Variation
                float2 heightNoiseInput = normalize(worldPosition.xz);
                float heightNoise = tex2Dlod(_BladeHeightNoiseTex, float4(heightNoiseInput, 0.0, 0.0)).r;
                float heightFactor = lerp(1.0, 3.0, heightNoise) * _BladeHeightVariation;
                worldPosition.y *= heightFactor;

                // basic curve
                float curveFactor = calCurveFactor(worldPosition.y);
                float curveAmount = _BladeCurve * instanceRandom; 
                worldPosition.x += curveAmount * curveFactor;

                // wind effect
                float u = sin(worldPosition.x * _WindScale + _Time * _WindFrequency) 
                + cos(worldPosition.z * _WindScale + _Time * _WindFrequency);
                float v = sin(worldPosition.z * _WindScale + _Time * _WindFrequency)
                + cos(worldPosition.x * _WindScale + _Time * _WindFrequency);
                float2 noiseInput = float2(u, v);

                noiseInput = 0.5 + 0.5 * noiseInput;
                float windNoise = tex2Dlod(_WindNoiseTex, float4(noiseInput, 0.0, 0.0)).r;
                float windDisplacement = windNoise * _WindSpeed; 

                float springForce = -_Stiffness * windDisplacement;
                float dampingForce = -_Damping * _WindSpeed;
                worldPosition.x += (windDisplacement + springForce + dampingForce) * curveFactor;
                

                OUT.positionWS = float4(worldPosition, 1.0);
                OUT.normalWS = worldNormal;
                OUT.positionCS = TransformWorldToHClip(worldPosition);
                OUT.uv = IN.uv;

                // Color gradient
                float t = saturate(worldPosition.y);
                float4 color = lerp(_BaseColor, _MidColor1, t);
                color = lerp(color, _MidColor2, t * t);
                color = lerp(color, _TopColor, t * t * t);
                OUT.color = color;

                return OUT;
            }

            half4 GrassShaderFragment(Varyings IN) : SV_TARGET 
            {
                float3 normal = normalize(IN.normalWS);
                
                float3 lightDir = -normalize(_MainLightPosition.xyz);
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - IN.positionWS.xyz);

                float diff = max(dot(normal, lightDir), 0.0);
                float3 diffuse = diff * _MainLightColor.rgb  * IN.color.rgb;
                
                float3 halfwayDir = normalize(lightDir + viewDir);
                float spec = pow(max(dot(normal, halfwayDir), 0.0), 32);  // Adjust shininess as needed
                float3 specular = spec * _MainLightColor.rgb;  // Adjust specular intensity as needed

                float3 ambient = 0.1 * IN.color.rgb;  // Simple ambient lighting

                float3 finalColor = ambient + diffuse + specular;

                return half4(finalColor, IN.color.a);
            }
            
            ENDHLSL
        }
    }
    FallBack "Universal Render Pipeline/Lit"
}
