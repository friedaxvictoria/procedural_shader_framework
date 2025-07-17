#ifndef ANIMATION_FILE
#define ANIMATION_FILE

#include "helper_functions.hlsl"
#include "global_variables.hlsl"

//CUSTOM NODE FUNCTIONS
//CAMERA ANIMATIONS
void rotateCamera_float(float3 axis, float speed, out float3x3 mat)
{
    float angle = _Time.y * speed;
    mat = computeRotationMatrix(normalize(axis), angle);
}

void backAndForth_float(float speed, out float3x3 mat)
{
    float t = _Time.y * speed;
    mat = float3x3(1, 0, 0, 0, 1, 0, 0, 0, abs(sin(t)));
}

void moveViaMouse_float(out float3x3 mat)
{
    float2 mouse = _mousePoint.xy / _ScreenParams.xy;

    // Center mouse to [-0.5, +0.5]
    mouse = mouse - 0.5;

    // Convert to yaw and pitch
    float yaw = lerp(-PI, PI, mouse.x + 0.5); // == PI * mouse.x when centered
    float pitch = lerp(-PI / 2, PI / 2, -mouse.y + 0.5); // invert Y axis

    float3x3 rotY = computeRotationMatrix(float3(0, 1, 0), yaw);
    float3x3 rotX = computeRotationMatrix(float3(1, 0, 0), pitch);

    mat = mul(rotY, rotX); // yaw first, then pitch
}

//a camera animation ALWAYS has to end with this node!!
void getCameraMatrix_float(float3x3 mat1, float3x3 mat2, float distance, float3 lookAtPosition, out float3x3 cameraMatrix)
{
    float3x3 combinedMatrix = mul(mat1, mat2);
    _rayOrigin = mul(float3(0, 0, distance), combinedMatrix);
    cameraMatrix = computeCameraMatrix(lookAtPosition, _rayOrigin, combinedMatrix);
}

//OBJECT ANIMATIONS
void orbitObjectAroundPoint_float(float3 seedPosition, float3 center, float3 axis, float radius, float speed, float angleOffset, out float3 position, out float angle)
{
    axis = normalize(axis);
    angle = _Time.y * speed + angleOffset * PI / 180;
        
    float3 radiusAxis = (float3(1, 1, 1) - axis) * radius;
    float3 positionTemp = seedPosition + radiusAxis - center;

    position = center + cos(angle) * positionTemp + sin(angle) * cross(axis, positionTemp) + (1 - cos(angle)) * dot(axis, positionTemp) * axis;
    //convert to degrees as input to the sdfs is in degrees
    angle = angle * 180 / PI;
}

void shakeObject_float(float3 seedPosition, float intensity, float speed, out float3 position)
{
    float time = _Time.y * speed;

    float x = frac(sin((time + 1.1) * 17.23) * 43758.5453) - 0.5;
    float y = frac(sin((time + 2.3) * 17.23) * 43758.5453) - 0.5;
    float z = frac(sin((time + 3.7) * 17.23) * 43758.5453) - 0.5;

    float3 jitter = float3(x, y, z) * intensity;

    position = seedPosition + jitter;
}

void cycleColor_float(float3 seedColor, float speed, out float3 color)
{
    float time = _Time.y * speed;
    float hue = frac(time);
    float3 hsv = float3(hue, 1.0, 1.0);
    float3 rgb = saturate(abs(frac(hsv.x + float3(0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0) - 1.0);
    
    color = rgb * seedColor;
}

//inspired by inspo: https://www.shadertoy.com/view/fl3fRf 
void changingColorSin_float(float3 seedColor, float speed, out float3 color)
{
    float3 rootColor = asin(2 * seedColor - 1);
    color = 0.5 + 0.5 * sin(_Time.y * speed * rootColor);
}
#endif