Shader "Custom/GrassShader"
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
            // "IgnoreProjector" = "True"
            "UniversalMaterialType" = "Unlit"
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

            

            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            


            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
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

                float3 worldPosition = mul(unity_ObjectToWorld, float4(input.positionOS.xyz, 1.0)).xyz;
                
                #ifdef INSTANCING_ON
                float randomOffset = rand(float(input.instanceID));
                worldPosition.x += randomOffset * pow(worldPosition.y, _BladeCurve); 
                #endif

                float3 objectPosition = mul(unity_WorldToObject, float4(worldPosition, 1.0)).xyz;

                VertexPositionInputs vertexInput = GetVertexPositionInputs(objectPosition);
                
                output.positionCS = vertexInput.positionCS;
                output.uv = input.uv;

                return output;
            }

            half4 GrassShaderFragment(Varyings i) : SV_TARGET 
            {
                return _Color;
            }
            
            ENDHLSL
        }
    }
    FallBack "Diffuse"
}
