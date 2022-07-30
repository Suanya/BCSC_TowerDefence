Shader "Custom/StandardSurfaceShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        //_Color ("Color", 2D) = "baseColor" {}
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) =  0.5 
         //_Glossiness ("Smoothness", 2D) =  "SmoothRough" {}    
        _Metallic ("Metallic", Range(0,1)) = 0.0
        //_Metallic ("Metallic", 2D) = "white" {} 
        _Normal ("Normal", 2D) = "bump" {} // Extending the shader with a normal map property 
        _EnvMap ("EnvironmentMap", CUBE) = ""{} // extending the shader with cube/environment map 
        _Opacity("Opacity", Range(0,1)) = 0.5
    }
    SubShader
    {
        // Tags { "RenderType"="Opaque" }
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProject" = "True"}

        Blend SrcAlpha OneMinusSrcAlpha 

        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types 
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _Normal;  // the actual normal map 
        samplerCUBE _EnvMap;  // the cube map

        sampler2D _Smoothness;

        struct Input
        {
            float2 uv_MainTex;  
            float2 uv_Normal; // adding the normal map's UVs  
            float3 worldRefl; // obtain the world reflection vector
            INTERNAL_DATA // INTERNAL DATA required

             //float2 uv_Smoothness;
            //float3 uv_Metallic;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        half _Opacity;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * 1 * _Color; // we dim the albedo by half to make the reflections less intense  
            float3 n = tex2D(_Normal, IN.uv_Normal);

            //float4 r = tex2D(_Smoothness, IN.un_Smoothness) * _Smoothness;  
            // float3 m = tex2D(_Metallic, IN.uv_Metallic) * _Metallic ; 
            o.Albedo = c.rgb;
            o.Emission = texCUBE (_EnvMap, IN.worldRefl * n).rgb; // calculating cubemap reflection by writing to Emission and distort reflection by the normal map           
            o.Normal = UnpackNormal (tex2D(_Normal, IN.uv_Normal)); // Implementing the normal map calculation here  
            o.Metallic = _Metallic; // Metallic and smoothness come from slider variables        
            o.Smoothness = _Glossiness;
            o.Alpha = c.a * _Opacity; // added opacity for disorting reflection
        }
        ENDCG
    }
    FallBack "Diffuse"
}
