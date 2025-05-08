Shader "Unlit/Monsters"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (0.8, 0.2, 0.2, 1.0)
        _MovementColor ("Movement Color", Color) = (1.0, 1.0, 0.0, 1.0)
        _TimeSpeed ("Time Speed", Range(0.1, 5.0)) = 1.0
        _MovementIntensity ("Movement Intensity", Range(0.01, 0.1)) = 0.05
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float4 _BaseColor;
            float4 _MovementColor;
            float _TimeSpeed;
            float _MovementIntensity;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 color : COLOR;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                // Aquí no alteramos las coordenadas de los vértices, solo trabajamos con el color
                o.color = _BaseColor.rgb;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Generamos un pequeño "movimiento" interno usando una función sinusoidal
                float wave = sin(_Time.y * _TimeSpeed + i.pos.x * 0.5) * _MovementIntensity;

                // Aplicamos el color de movimiento sumándolo con el color base
                float3 movementColor = _BaseColor.rgb + (_MovementColor.rgb * wave);

                // Limitar el movimiento para que no se desborde el color
                movementColor = saturate(movementColor);

                return fixed4(movementColor, 1.0);
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}
