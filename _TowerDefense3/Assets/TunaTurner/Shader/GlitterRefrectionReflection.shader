Shader "Unlit/GlitterRefrectionReflection"
{
        Properties
    {
        [Header(Colors)]
        _Color ("Color", Color) = (.5,.5,.5,1)
		_SpecColor ("Specular Color", Color) = (.5,.5,.5,1)
		_MainTex ("Texture", 2D) = "white" {}

        [Header(Specular)]
        _SpecPow ("Specular Power", Range (1, 50)) = 24
		_GlitterPow ("Glitter Power", Range (1, 50)) = 5

        [Header(RefLecation And RefRaction]
        _ReflId ("Reflection Index", Range (1, 5)) = 1
		_RefrId ("Refraction Index", Range (1, 5)) = 1
		_ReflRoughness ("Reflection Roughness", Range (0, 9)) = 0
		_RefrRoughness ("Refraction Roughness", Range (0, 9)) = 0

        [Toggle(USE_CUBE_REFRACTION)]
         _UseCubeRefr ("Use Refraction Probe", Float) = 0

        [Header(Sparkles)]
        _SparkleDepth ("Sparkle Depth", Range (0, 5)) = 1
		_NoiseScale ("noise Scale", Range (0, 5)) = 1
		_AnimSpeed ("Animation Speed", Range (0, 5)) = 1
        
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		LOD 100

		GrabPass 
		{
			"_BackgroundTexture"
		}


        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
			#pragma fragment frag
			#pragma shader_feature USE_CUBE_REFRACTION
			// make fog work
			#pragma multi_compile_fog

            #include "\CGinc\UnityCG.cginc"
			#include "\CGinc\Simplex3D.cginc"
			#include "\CGinc\SparklesCG.cginc"

            struct MeshData
            {
                float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float3 wPos : TEXCOORD1;
				float3 pos : TEXCOORD3;
				float3 normal : NORMAL;
				float4 grabPos : TEXCOORD4;
				float4 scrPos : TEXCOORD5;
            };

            sampler2D _MainTex;
			sampler2D _BackgroundTexture;
			float4 _MainTex_ST;
			float4 _Color, _SpecColor;
			float _SpecPow, _GlitterPow, _ReflId, _RefrId, _ReflRoughness, _RefrRoughness;

            Interpolators vert (MeshData v)
            {
                Interpolators o;

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.pos = v.vertex;
				o.normal = mul(unity_ObjectToWorld, float4(v.normal,0)).xyz;
				o.vertex = UnityObjectToClipPos(v.vertex); // + v.normal * snoise(o.wPos * .03 + _Time.y*.5) * .05);   
				o.grabPos = ComputeGrabScreenPos(UnityObjectToClipPos(v.vertex*-5));
				o.scrPos = o.vertex;
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                // light calculation
                float3 normal = normalize(i.normal);
                float3 viewDir = normalize(UnityWorldSpaceViewDir(i.wPos));
                float3 reflDir = reflect(-viewDir, normal);
                float3 lightDirection;
                float atten = 1.0;
                lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float diffuse = max( 0.0, dot(normal, lightDirection) * 0.5 + 0.5);
                float specular = saturate(dot(reflDir, lightDirection));
                float glitterSpecular = pow(specular, _GlitterPow);
                specular = pow(specular,_SpecPow);

                // rim
				float rim = 1-saturate(dot(viewDir, normal));
				rim = pow(rim, _ReflId);

                // sample reflection cube 
                half4 skyData = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflDir, _ReflRoughness);
                half3 skyColor = DecodeHDR (skyData, unity_SpecCube0_HDR) * (1 + diffuse);

                half3 refrColor;

                // Attention, Attention, please! Decide wheter to use grabPass (frenchLift aka incorrect) OR a cubeMap (can be realtime, too) for refRaction  
     #ifdef USE_CUBE_REFRACTION
                
                float3 refrDir = refract( viewDir, normal, 1/_RefrId ); // calculate refraction direction based on cubeMap (s.o.)   
                half4 refrData = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, refrDir,_RefrRoughness);   
                refrColor = DecodeHDR (refrData, unity_SpecCube0_HDR);

                // Alright then, do the donald and duck!
     #else
                float4 screenPos = i.grabPos; // get screenspace for GrabPass
                float2 offset = normalize(mul(UNITY_MATRIX_V,float4(normal, 0))).xy * _RefrId * 10; // create lookUp offSet based on viewspace normals 
                offset.x *= _ScreenParams.y/_ScreenParams.x; // make sure the params is in square aspect   
                screenPos.xy += offset; // apply offSet
                refrColor = tex2Dproj(_BackgroundTexture, screenPos).rgb;          
     #endif

                // Sparkles
                float sparkles = Sparkles(viewDir,i.wPos);

                
                fixed4 col = tex2D(_MainTex, i.uv) * _Color; // sample the technoTexture
                col.rgb *= refrColor.rgb; // apply refRrection
                col.rgb =  lerp(skyColor * _SpecColor, col, 1-rim); // apply refLection
                col += _SpecColor * (saturate(sparkles * glitterSpecular * 5) + specular); // apply Specular and Sparkles for some Glamour 
                UNITY_APPLY_FOG(i.fogCoord, col);
                
                return col;

            }
            ENDCG
        }
    }
}
