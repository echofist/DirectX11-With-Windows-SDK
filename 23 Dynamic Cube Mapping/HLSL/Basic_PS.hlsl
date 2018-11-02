#include "Basic.hlsli"

// ������ɫ��(3D)
float4 PS(VertexPosHWNormalTex pIn) : SV_Target
{
    // ����ʹ����������ʹ��Ĭ�ϰ�ɫ
    float4 texColorA = float4(1.0f, 1.0f, 1.0f, 1.0f);
    float4 texColorD = float4(1.0f, 1.0f, 1.0f, 1.0f);

    if (gTextureUsed)
    {
        texColorA = texA.Sample(sam, pIn.Tex);
        texColorD = texD.Sample(sam, pIn.Tex);
        	// ��ǰ���вü����Բ�����Ҫ������ؿ��Ա����������
        clip(texColorA.a - 0.1f);
        clip(texColorD.a - 0.1f);
    }
    
    // ��׼��������
    pIn.NormalW = normalize(pIn.NormalW);

    // ����ָ���۾�������
    float3 toEyeW = normalize(gEyePosW - pIn.PosW);

    // ��ʼ��Ϊ0 
    float4 ambient = float4(0.0f, 0.0f, 0.0f, 0.0f);
    float4 diffuse = float4(0.0f, 0.0f, 0.0f, 0.0f);
    float4 spec = float4(0.0f, 0.0f, 0.0f, 0.0f);
    float4 A = float4(0.0f, 0.0f, 0.0f, 0.0f);
    float4 D = float4(0.0f, 0.0f, 0.0f, 0.0f);
    float4 S = float4(0.0f, 0.0f, 0.0f, 0.0f);
    int i;

    [unroll]
    for (i = 0; i < 5; ++i)
    {
        ComputeDirectionalLight(gMaterial, gDirLight[i], pIn.NormalW, toEyeW, A, D, S);
        ambient += A;
        diffuse += D;
        spec += S;
    }
        
    [unroll]
    for (i = 0; i < 5; ++i)
    {
        ComputePointLight(gMaterial, gPointLight[i], pIn.PosW, pIn.NormalW, toEyeW, A, D, S);
        ambient += A;
        diffuse += D;
        spec += S;
    }

    [unroll]
    for (i = 0; i < 5; ++i)
    {
        ComputeSpotLight(gMaterial, gSpotLight[i], pIn.PosW, pIn.NormalW, toEyeW, A, D, S);
        ambient += A;
        diffuse += D;
        spec += S;
    }
  
    float4 litColor = texColorA * ambient + texColorD * diffuse + spec;
    // ����
    if (gReflectionEnabled)
    {
        float3 incident = -toEyeW;
        float3 reflectionVector = reflect(incident, pIn.NormalW);
        float4 reflectionColor = texCube.Sample(sam, reflectionVector);

        litColor += gMaterial.Reflect * reflectionColor;
    }
    // ����
    if (gRefractionEnabled)
    {
        float3 incident = -toEyeW;
        float3 refractionVector = refract(incident, pIn.NormalW, gEta);
        float4 refractionColor = texCube.Sample(sam, refractionVector);

        litColor += gMaterial.Reflect * refractionColor;
    }

    litColor.a = texColorD.a * gMaterial.Diffuse.a;
    return litColor;
}