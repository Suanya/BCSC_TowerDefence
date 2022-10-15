Shader "Unlit/GlitterSpecularDiffuse"
{
    Properties 
    {
        [Header(Colors)]
        _Color ("Color", Color) = (0.5, 0.5, 0.5, 1)
        _SpecColor("SpecularColor", Color) = (1, 1, 0, 1)
        _MainTex ("Texture", 2D) = "white" {}

        [Header(Specular]
        _SpecPow ("SpecularPower", Range (1,50)) = 24
        _GlitterPow ("GlitterPower", Range(1,50)) = 5

        [Header(Sparkles)]
        _SparkleDepth("SparkleDepth", Range(0,5)) = 1
        _NoiseScale("noiseScale", Range(0,5)) = 1
        _AnimSpeed("AnimationSpeed", Range(0,5)) = 1
    }

    SubShader 
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags { "LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
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
              
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _Color, _SpecColor;
            float _SpecPow, _GlitterPow;

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.pos = v.vertex;
				o.normal = mul(unity_ObjectToWorld, float4(v.normal,0)).xyz;
				o.vertex = UnityObjectToClipPos(v.vertex);
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
				float diffuse = max( 0.0, dot(normal, lightDirection) * .5 + .5);
				float specular = saturate(dot(reflDir, lightDirection));				
				float glitterSpecular = pow(specular,_GlitterPow);
				specular = pow(specular,_SpecPow);

                // sparkles
                float sparkles = Sparkles(viewDir, i.wPos);

                // sample the texture  
                fixed4 col = tex2D(_MainTex, i.uv) * _Color * diffuse;

                // apply Specular and Sparkles
                col += _SpecColor * (saturate(sparkles * glitterSpecular * 5) + specular);

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);

                return col;
            }
            ENDCG  
        }
    }
}
