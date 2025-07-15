#ifndef DOLPHIN_FILE
#define DOLPHIN_FILE

//SPECIAL HELPERS FOR DOLPHIN
float distanceToBox(float3 p, float3 halfExtent, float radius)
{
    float3 distanceToBox = abs(p) - halfExtent;
    return length(max(distanceToBox, 0.0)) - radius;
}

float smoothUnion(float distance1, float distance2, float smoothFactor)
{
    float h = clamp(0.5 + 0.5 * (distance2 - distance1) / smoothFactor, 0.0, 1.0);
    return lerp(distance2, distance1, h) - smoothFactor * h * (1.0 - h);
}

float2 dolphinAnimation(float position, float timeOffset)
{
    float adjustedTime = _Time.y + timeOffset;
    float angle1 = 0.9 * (0.5 + 0.2 * position) * cos(5.0 * position - 3.0 * adjustedTime + 6.2831 / 4.0);
    float angle2 = 1.0 * cos(3.5 * position - 1.0 * adjustedTime + 6.2831 / 4.0);
    float jumping = 0.5 + 0.5 * cos(-0.4 + 0.5 * adjustedTime);
    float finalAngle = lerp(angle1, angle2, jumping);
    float thickness = 0.4 * cos(4.0 * position - 1.0 * adjustedTime) * (1.0 - 0.5 * jumping);
    return float2(finalAngle, thickness);
}

float3 dolphinMovement(float timeOffset, float3 basePosition, float speed)
{
    if (speed == 0)
        return basePosition;
    float adjustedTime = _Time.y + timeOffset;
    float jumping = 0.5 + 0.5 * cos(-0.4 + 0.5 * adjustedTime);
    
    float3 movement1 = float3(0.0, sin(3.0 * adjustedTime + 6.2831 / 4.0), 0.0);
    float3 movement2 = float3(0.0, 1.5 + 2.5 * cos(1.0 * adjustedTime), 0.0);
    float3 finalMovement = lerp(movement1, movement2, jumping);
    finalMovement.y *= 0.5;
    finalMovement.x += 0.1 * sin(0.1 - 1.0 * adjustedTime) * (1.0 - jumping);
    
    float3 worldOffset = float3(0.0, 0.0, fmod(-speed * _Time.y, 20.0) - 5.0);
    
    return basePosition + finalMovement + worldOffset;
}

//returning: res.x: The signed distance from point p to the dolphin. res.y: A parameter h that stores a normalized position along the dolphin's body (used for further shaping/decorating).
float2 dolphinDistance(float3 p, float3 position, float timeOffset, float speed)
{

	//initialize the result to a very large distance and an auxiliary value of 0. We'll minimize this value over the dolphin's body parts.
    float2 result = float2(1000.0, 0.0);
    float3 startPoint = dolphinMovement(timeOffset, position, speed);

    float segmentNumberFloat = 11.0;
    int segmentNumber = int(segmentNumberFloat);

    float3 position1 = startPoint;
    float3 position2 = startPoint;
    float3 position3 = startPoint;
    float3 direction1 = float3(0.0, 0.0, 0.0);
    float3 direction2 = float3(0.0, 0.0, 0.0);
    float3 direction3 = float3(0.0, 0.0, 0.0);
    float3 closestPoint = startPoint;

    for (int i = 0; i < segmentNumber; i++)
    {
        float segmentPosition = float(i) / segmentNumberFloat;
        float2 segmentAnimation = speed == 0 ? float2(0, 0): dolphinAnimation(segmentPosition, timeOffset);
        float segmentLength = 0.48;
        if (i == 0)
            segmentLength = 0.655;
        float3 endPoint = startPoint + segmentLength * normalize(float3(sin(segmentAnimation.y), sin(segmentAnimation.x), cos(segmentAnimation.x)));

        float3 startToPoint = p - startPoint;
        float3 startToEnd = endPoint - startPoint;
        float projection = clamp(dot(startToPoint, startToEnd) / dot(startToEnd, startToEnd), 0.0, 1.0);
        float3 vectorToClosestPoint = startToPoint - projection * startToEnd;

        float2 distance = float2(dot(vectorToClosestPoint, vectorToClosestPoint), projection);

        if (distance.x < result.x)
        {
            result = float2(distance.x, segmentPosition + distance.y / segmentNumberFloat);
            closestPoint = startPoint + distance.y * (endPoint - startPoint);

        }
		//store Specific Segment Info for Fins and Tail
        if (i == 3)
        {
            position1 = startPoint;
            direction1 = endPoint - startPoint;
        }
        if (i == 4)
        {
            position3 = startPoint;
            direction3 = endPoint - startPoint;
        }
        if (i == (segmentNumber - 1))
        {
            position2 = endPoint;
            direction2 = endPoint - startPoint;
        }
		//move Forward to Next Segment
        startPoint = endPoint;
    }
    float bodyRadius = result.y;
    float radius = 0.05 + bodyRadius * (1.0 - bodyRadius) * (1.0 - bodyRadius) * 2.7;
    radius += 7.0 * max(0.0, bodyRadius - 0.04) * exp(-30.0 * max(0.0, bodyRadius - 0.04)) * smoothstep(-0.1, 0.1, p.y - closestPoint.y);
    radius -= 0.03 * (smoothstep(0.0, 0.1, abs(p.y - closestPoint.y))) * (1.0 - smoothstep(0.0, 0.1, bodyRadius));
    radius += 0.05 * clamp(1.0 - 3.0 * bodyRadius, 0.0, 1.0);
    radius += 0.035 * (1.0 - smoothstep(0.0, 0.025, abs(bodyRadius - 0.1))) * (1.0 - smoothstep(0.0, 0.1, abs(p.y - closestPoint.y)));
    result.x = 0.75 * (distance(p, closestPoint)- radius);

	//fin part
    direction3 = normalize(direction3);
    float k = sqrt(1.0 - direction3.y * direction3.y);
    float3x3 ms = float3x3(
			direction3.z / k, -direction3.x * direction3.y / k, direction3.x,
			0.0, k, direction3.y,
			-direction3.x / k, -direction3.y * direction3.z / k, direction3.z);
    float3 ps = mul((p- position3), ms);
    ps.z -= 0.1; // This is the offset for the fin

    float distance5 = length(ps.yz) - 0.9;
    distance5 = max(distance5, -(length(ps.yz - float2(0.6, 0.0)) - 0.35));
    distance5 = max(distance5, distanceToBox(ps + float3(0.0, -0.5, 0.5), float3(0.0, 0.5, 0.5), 0.02));
    result.x = smoothUnion(result.x, distance5, 0.1);

	//fin 
    direction1 = normalize(direction1);
    k = sqrt(1.0 - direction1.y * direction1.y);
    ms = float3x3(
			direction1.z / k, -direction1.x * direction1.y / k, direction1.x,
			0.0, k, direction1.y,
			-direction1.x / k, -direction1.y * direction1.z / k, direction1.z);

    ps = p - position1;
    ps = mul(ps, ms);
    ps.x = abs(ps.x);
    float l = ps.x;
    l = clamp((l - 0.4) / 0.5, 0.0, 1.0);
    l = 4.0 * l * (1.0 - l);
    l *= 1.0 - clamp(5.0 * abs(ps.z + 0.2), 0.0, 1.0);
    ps.xyz += float3(-0.2, 0.36, -0.2);
    distance5 = length(ps.xz) - 0.8;
    distance5 = max(distance5, -(length(ps.xz - float2(0.2, 0.4)) - 0.8));
    distance5 = max(distance5, distanceToBox(ps + float3(0.0, 0.0, 0.0), float3(1.0, 0.0, 1.0), 0.015 + 0.05 * l));
    result.x = smoothUnion(result.x, distance5, 0.12);

	//tail part
    direction2 = normalize(direction2);
    float2x2 mf = float2x2(
			direction2.z, direction2.y,
			-direction2.y, direction2.z);
    float3 pf = p - position2 - direction2 * 0.25;
    pf.yz = mul(pf.yz, mf);
    float distance4 = length(pf.xz) - 0.6;
    distance4 = max(distance4, -(length(pf.xz - float2(0.0, 0.8)) - 0.9));
    distance4 = max(distance4, distanceToBox(pf, float3(1.0, 0.005, 1.0), 0.005));
    result.x = smoothUnion(result.x, distance4, 0.1);

    return result;
}

#endif