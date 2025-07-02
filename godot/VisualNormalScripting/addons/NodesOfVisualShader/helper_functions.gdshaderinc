// Evaluate the signed distance function for a given SDF shape
float evalSDF(int i, float3 p)
{
    int sdfType = _sdfTypeFloat[i];
    float dist = 1e5;
    if (sdfType == 0)
    {
        dist = sdSphere((p - _sdfPositionFloat[i]), _sdfRadiusFloat[i]);
    }
    else if (sdfType == 1)
    {
        dist = sdRoundBox(p - _sdfPositionFloat[i], _sdfSizeFloat[i], _sdfRadiusFloat[i]);
    }
    else if (sdfType == 2)
        dist = sdTorus(p - _sdfPositionFloat[i], _sdfSizeFloat[i].yz);
    return dist;
}

float3 get_normal(int i, float3 p)
{
    float h = 0.0001;
    float2 k = float2(1, -1);
    
    float normal1 = evalSDF(i, p + k.xyy * h);
    float normal2 = evalSDF(i, p + k.yyx * h);
    float normal3 = evalSDF(i, p + k.yxy * h);
    float normal4 = evalSDF(i, p + k.xxx * h);
    return normalize(k.xyy * normal1 + k.yyx * normal2 + k.yxy * normal3 + k.xxx * normal4);
}


float sdSphere(float3 position, float radius)
{
    return length(position) - radius;
}

float sdRoundBox(float3 p, float3 b, float r)
{
    float3 q = abs(p) - b + r;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - r;
}

// radius.x is the major radius, radius.y is the minor radius
float sdTorus(float3 p, float2 radius)
{
    float2 q = float2(length(p.xy) - radius.x, p.z);
    return length(q) - radius.y;
}