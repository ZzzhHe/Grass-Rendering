Shader "Custom/LitGrassShader"
{
    Properties
    {
        _TopColor ("Tip Color", Color) = (0.74, 1, 0.6, 1)
        _MidColor1 ("Color 2", Color) = (0.4, 0.8, 0.3, 1)
        _MidColor2 ("Color 1", Color) = (0.25, 0.5, 0.24, 1)
        _BaseColor ("Base Color", Color) = (0.14, 0.35, 0.1, 1)

        _BladeCurve ("Blade Curve", Range(0, 1.0)) = 0.5
        _BladeCurvePow ("Blade Curve Pow", Range(1.0, 4.0)) = 2.0
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
            #pragma target 4.5
            

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

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

            float rand(uint seed)
            {
                return frac(sin(seed * 12.9898 + 78.233) * 43758.5453);
            }

            Varyings GrassShaderVertex(Attributes IN)
            {
                Varyings OUT = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

                float3 worldPosition = TransformObjectToWorld(IN.positionOS.xyz);
                float3 worldNormal = TransformObjectToWorldNormal(IN.normalOS);

                #ifdef INSTANCING_ON
                float randomOffset = rand(float(IN.instanceID)) - 0.5;  // random from -0.5 to 0.5
                worldPosition.x += _BladeCurve * randomOffset * pow(worldPosition.y, _BladeCurvePow); 
                #endif

                OUT.positionWS = float4(worldPosition, 1.0);
                OUT.normalWS = worldNormal;
                OUT.positionCS = TransformWorldToHClip(worldPosition);
                OUT.uv = IN.uv;

                // Color gradient
                float t = saturate(worldPosition.y);
                float4 color = lerp(_BaseColor, _MidColor2, t);
                color = lerp(color, _MidColor1, t * t);
                color = lerp(color, _TopColor, t * t * t);
                OUT.color = color;

                return OUT;
            }

            half4 GrassShaderFragment(Varyings IN) : SV_TARGET 
            {
                float3 normal = normalize(IN.normalWS);
                
                float3 lightDir = normalize(float3(10, 10, 0) - IN.positionWS.xyz);
                float3 viewDir = normalize(_WorldSpaceCameraPos - IN.positionWS.xyz);

                float diff = max(dot(normal, lightDir), 0.0);
                float3 diffuse = _MainLightColor.rgb * diff * IN.color.rgb;
                
                float3 reflectDir = reflect(-lightDir, normal);
                float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32);  // Adjust shininess as needed
                float3 specular = _MainLightColor.rgb * spec * 0.5;  // Adjust specular intensity as needed

                float3 ambient = 0.1 * IN.color.rgb;  // Simple ambient lighting

                float3 finalColor = ambient + diffuse + specular;

                return half4(finalColor, IN.color.a);
            }
            
            ENDHLSL
        }
    }
    FallBack "Universal Render Pipeline/Lit"
}
