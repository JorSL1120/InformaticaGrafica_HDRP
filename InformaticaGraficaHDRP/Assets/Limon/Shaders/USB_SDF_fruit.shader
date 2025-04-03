Shader "Unlit/USB_SDF_fruit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _PlaneTex ("Plane Texture", 2D) = "white" {}
        _CircleCol ("Circle Color", Color) = (1, 1, 1, 1)
        _CircleRad ("Circle Radius", Range(0.0, 0.5)) = 0.45
        _Edge ("Edge", Range(-0.5, 0.5)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Off

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
                float3 hitPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _PlaneTex;
            float4 _MainTex_ST;
            float4 _CircleCol;
            float _CircleRad;
            float _Edge;

            float planeSDF(float3 ray_position)
            {
                return ray_position.y - _Edge;
            }

            #define MAX_MARCHING_STEPS 50
            #define MAX_DISTANCE 10.0
            #define SURFACE_DISTANCE 0.001

            //float sphereCasting(float ray_origin, float3 ray_direction)
            float sphereCasting(float3 ray_origin, float3 ray_direction)
            {
                float distance_origin = 0;
                for(int i = 0; i < MAX_MARCHING_STEPS; i++)
                {
                    float3 ray_position = ray_origin + ray_direction * distance_origin;
                    float distance_scene = planeSDF(ray_position);
                    distance_origin += distance_scene;

                    //if(distance_scene < SURFACE_DISTANCE || distance_origin > MAX_MARCHIG_STEPS);
                    if (distance_scene < SURFACE_DISTANCE || distance_origin > MAX_DISTANCE)
                        break;
                }
                return distance_origin;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.hitPos = v.vertex;
                return o;
            }

            fixed4 frag (v2f i, bool face : SV_isFrontFace) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float3 ray_origin = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1)).xyz;
                float3 ray_direction = normalize(i.hitPos - ray_origin);
                float t = sphereCasting(ray_origin, ray_direction);
                float4 planeCol = 0;
                float4 circleCol = 0;

                if (t < MAX_DISTANCE)
                {
                    float3 p = ray_origin + ray_direction * t;
                    float2 uv_p = p.xz;

                    uv_p = (uv_p + 1.0) * 0.5;
                    uv_p.y = 1.0 - uv_p.y;

                    float c = length(uv_p - 0.5);
                    //circleCol = (smoothstep(c - 0.01, c + 0.01, _CircleRad abs(pow(_Edge * (1 * 0.5), 2))));
                    circleCol = 1.0 - smoothstep(_CircleRad - 0.01, _CircleRad + 0.01, c);

                    //planeCol = tex2D(_PlaneTex, (uv_p(1 - abs(pow(_Edge * l, 2)))) - 0.5);
                    planeCol = tex2D(_PlaneTex, uv_p);

                    planeCol *= circleCol;
                    planeCol += (1 - circleCol) * _CircleCol;
                }

                if (i.hitPos.y > _Edge)
                    discard;

                return face ? col : float4(planeCol.rgb, 1);
            }
            ENDCG
        }
    }
}
