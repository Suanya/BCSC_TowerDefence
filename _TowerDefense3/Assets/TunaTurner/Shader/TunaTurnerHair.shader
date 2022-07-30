Shader "Unlit/TunaTurnerHair"
{
    Properties   
    {  
        _ColorA ("ColorA", Color) = (1,1,1,1)
        _ColorB ("ColorB", Color) = (1,1,1,1)
        _ColorStart ("ColorStart", Range(0,1)) = 0
        _ColorEnd ("ColorEnd", Range(0,1)) = 1     
    }
    SubShader 
    {
        Tags {
            "RenderType"="Transparent"
            "Queue"="Transparent"         
        }
          
        Pass 
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            #define TAU 6.2831853071 // perfectRepeat
     
           float4 _ColorA;
           float4 _ColorB;
           float _ColorStart;
           float _ColorEnd;

            // automatically filled out by unity  
            struct MeshData  // perVertex meshData    
            {  
                float4 vertex : POSITION; // vertexPosition  
                float3 normals : NORMAL; // normalDirection of a vertex     
                float4 uv0 : TEXCOORD0; // uv0 coordinates -> diffuse/normal map textures   
                
            };

            struct Interpolaters // v2f     
            { 
                
                float4 vertex : SV_POSITION; // clipSpacePosition of the vertex    
                float3 normal : TEXCOORD0;      
                float2 uv : TEXCOORD1; 
            };   

            Interpolaters vert (MeshData v)                                                          
            {
                Interpolaters o;
                o.vertex = UnityObjectToClipPos(v.vertex); // localSpace to clipSpace  
                o.normal = UnityObjectToWorldNormal(v.normals); // show normals of the object -> visualize normalDirections             
                o.uv = v.uv0; // passTrough;  
                return o;  
            }

            // define own function 
            float InverseLerp(float a, float b, float v)
            {
                return(v-a)/(b-a);
                
            }

            // actual fragmentShader 
            float4 frag (Interpolaters i) : SV_Target
            {
                // blend between 2 colors based on the X UV coordinates with lerp 

                // return i.uv.y;

                float xOffset = cos(i.uv.x * TAU * 8) * 0.01;
                float t = cos( (i.uv.y + xOffset + _Time.y * 0.1 ) * TAU * 5) * 0.5 + 0.5;
                t *= i.uv.y;

                float topBottomRemover = (abs(i.normal.y) < 0.999);
                float waves = t * topBottomRemover;

                float4 gradient = lerp(_ColorA, _ColorB, i.uv.y);
                return gradient * waves;   
            }
            ENDCG 
        }
    }
}
