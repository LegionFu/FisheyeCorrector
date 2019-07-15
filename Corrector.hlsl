//----------------------------------------------------------------------------------------
Corrector
input:UV

float x, y, z; 
float x_cart, y_cart; 

float latitude = UV.y * PI; 
float longitude = UV.x * PI; 
//Convert from latitude cooradinate to the sphere cooradinate
x =  - sin(latitude) * cos(longitude); 
y = cos(latitude); 
z = sin(latitude) * sin(longitude); 

//Convert from unit sphere cooradinate to the parameter sphere cooradinate
float Theta_sphere = acos(z); 
float Phi_sphere = atan2(y, x);

float foval = 0.5 / (PI / 2); 
float p = foval * Theta_sphere; 

float theta = Phi_sphere; 

//Convert from fish-eye polar cooradinate to cartesian cooradinate
x_cart = p * cos(theta); 
y_cart = p * sin(theta); 

//Convert from cartesian cooradinate to image cooradinate
float u = x_cart + 0.5; 
float v =  - y_cart + 0.5; 

if (u >= 0 && u <= 1 && v >= 0 && v <= 1) {
    return float2(u, v); 
}
return 0; 
//----------------------------------------------------------------------------------------
navigationHV
input:angleH, angleV, orgPt

float3x3 matH = float3x3(0, 0, 0, 0, 0, 0, 0, 0, 0); 
matH[0][0] = cos(angleH); 
matH[0][2] =  - sin(angleH); 
matH[1][1] = 1; 
matH[2][0] = sin(angleH); 
matH[2][2] = cos(angleH); 

float3x3 matV = float3x3(0, 0, 0, 0, 0, 0, 0, 0, 0); 
matV[0][0] = 1; 
matV[1][1] = cos(angleV); 
matV[1][2] =  - sin(angleV); 
matV[2][1] = sin(angleV); 
matV[2][2] = cos(angleV); 

float3x3 mat = mul(matV, matH); 

float3x1 org = float3x1(orgPt.x, orgPt.y, orgPt.y); 
float3x1 ret = mul(mat, org); 
return float3(ret[0][0], ret[1][0], ret[2][0]); 
//----------------------------------------------------------------------------------------
getDispView
input： UV, dispArea, angleH, angleV, distance

float dispX = UV.x * dispArea.x;
float dispY = UV.y * dispArea.y;

float center_x = dispArea.x / 2;
float center_y = dispArea.y / 2;
float3 tmpPt = float3(dispX - center_x, center_y - dispY, distance*dispArea.x);

//norm(tmpPt)
float normPt = sqrt(tmpPt.x*tmpPt.x + tmpPt.y * tmpPt.y + tmpPt.z*tmpPt.z);

tmpPt.x /= normPt;
tmpPt.y /= normPt;
tmpPt.z /= normPt;

//float3 ret = navigationHV(tmpPt, angleH, angleV); 
float3x3 matH = float3x3(0, 0, 0, 0, 0, 0, 0, 0, 0); 
matH[0][0] = cos(angleH); 
matH[0][2] =  - sin(angleH); 
matH[1][1] = 1; 
matH[2][0] = sin(angleH); 
matH[2][2] = cos(angleH); 

float3x3 matV = float3x3(0, 0, 0, 0, 0, 0, 0, 0, 0); 
matV[0][0] = 1; 
matV[1][1] = cos(angleV); 
matV[1][2] =  - sin(angleV); 
matV[2][1] = sin(angleV); 
matV[2][2] = cos(angleV); 

float3x3 mat = mul(matV, matH); 

float3x1 org = float3x1(tmpPt.x, tmpPt.y, tmpPt.z); 
float3x1 ret = mul(mat, org); 
float x = ret[0][0]; 
float y = ret[1][0]; 
float z = ret[2][0]; 

float Theta_sphere = acos(z); 
float Phi_sphere = atan2(y, x);

float latitude = Theta_sphere / PI; 
float longitude = Phi_sphere / PI; 

float u = longitude; 
float v = latitude; 

return float2(u, v); 

//----------------------------------------------------------------------
float3 blur = Texture2DSample(Tex, TexSampler, UV);

for (int i = 0; i < r; i++)
{

  blur += Texture2DSample(Tex, TexSampler, UV + float2(i * dist, 0));
  blur += Texture2DSample(Tex, TexSampler, UV - float2(i * dist, 0));

}

for (int j = 0; j < r; j++)
{ 

  blur += Texture2DSample(Tex, TexSampler, UV + float2(0, j * dist));
  blur += Texture2DSample(Tex, TexSampler, UV - float2(0, j * dist));

}

blur /= 2*(2*r)+1;
return blur;
