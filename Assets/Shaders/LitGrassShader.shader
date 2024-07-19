Shader "Custom/LitGrassShader"
{
    Properties
    {
        _Color ("Color", Color) = (0.074, 0.522, 0.059, 1)
        _BladeCurve ("Blade Curve", Range(1,4)) = 2
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

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            uniform float4 _Color;
            uniform float _BladeCurve;

            float rand(uint seed)
            {
                return frac(sin(seed * 12.9898 + 78.233) * 43758.5453) * 2 - 1;
            }

            Varyings GrassShaderVertex(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float3 worldPosition = TransformObjectToWorld(input.positionOS.xyz);
                float3 worldNormal = TransformObjectToWorldNormal(input.normalOS);

                #ifdef INSTANCING_ON
                float randomOffset = rand(float(input.instanceID));
                worldPosition.x += randomOffset * pow(worldPosition.y, _BladeCurve); 
                #endif

                output.positionWS = float4(worldPosition, 1.0);
                output.normalWS = worldNormal;
                output.positionCS = TransformWorldToHClip(worldPosition);

                output.uv = input.uv;

                return output;
            }

            half4 GrassShaderFragment(Varyings i) : SV_TARGET 
            {
                float3 normal = normalize(i.normalWS);
                // float3 lightDir = 
                float3 lightDir = normalize(float3(0, 3, 0) - i.positionWS.xyz);
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.positionWS.xyz);

                float diff = max(dot(normal, lightDir), 0.0);
                float3 diffuse = _MainLightColor.rgb * diff;
                
                float3 reflectDir = reflect(-lightDir, normal);
                float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32);  // Adjust shininess as needed
                float3 specular = _MainLightColor.rgb * spec * 0.5;  // Adjust specular intensity as needed

                float3 ambient = 0.1 * _Color.rgb;  // Simple ambient lighting

                float3 finalColor = (_Color.rgb * diffuse + specular + ambient) * _Color.rgb;

                return half4(finalColor, _Color.a);
            }
            
            ENDHLSL
        }
    }
    FallBack "Universal Render Pipeline/Lit"
}
