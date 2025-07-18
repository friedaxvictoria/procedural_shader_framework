#ifndef TWEEN_FILE
#define TWEEN_FILE

// ENUMS FOR TWEEN TYPES
#define TWEEN_LINEAR               0
#define TWEEN_QUADRATIC_IN         1
#define TWEEN_QUADRATIC_OUT        2
#define TWEEN_QUADRATIC_INOUT      3
#define TWEEN_CUBIC_IN             4
#define TWEEN_CUBIC_OUT            5
#define TWEEN_CUBIC_INOUT          6
#define TWEEN_QUARTIC_IN           7
#define TWEEN_QUARTIC_OUT          8
#define TWEEN_QUARTIC_INOUT        9
#define TWEEN_QUINTIC_IN           10
#define TWEEN_QUINTIC_OUT          11
#define TWEEN_QUINTIC_INOUT        12
#define TWEEN_SINE_IN              13
#define TWEEN_SINE_OUT             14
#define TWEEN_SINE_INOUT           15
#define TWEEN_CIRCULAR_IN          16
#define TWEEN_CIRCULAR_OUT         17
#define TWEEN_CIRCULAR_INOUT       18
#define TWEEN_EXPONENTIAL_IN       19
#define TWEEN_EXPONENTIAL_OUT      20
#define TWEEN_EXPONENTIAL_INOUT    21
#define TWEEN_ELASTIC_IN           22
#define TWEEN_ELASTIC_OUT          23
#define TWEEN_ELASTIC_INOUT        24
#define TWEEN_BACK_IN              25
#define TWEEN_BACK_OUT             26
#define TWEEN_BACK_INOUT           27
#define TWEEN_BOUNCE_IN            28
#define TWEEN_BOUNCE_OUT           29
#define TWEEN_BOUNCE_INOUT         30

float BounceEaseOut(float p)
{
    if (p < 4.0 / 11.0)
        return (121.0 * p * p) / 16.0;
    else if (p < 8.0 / 11.0)
        return (363.0 / 40.0 * p * p) - (99.0 / 10.0 * p) + 17.0 / 5.0;
    else if (p < 9.0 / 10.0)
        return (4356.0 / 361.0 * p * p) - (35442.0 / 1805.0 * p) + 16061.0 / 1805.0;
    else
        return (54.0 / 5.0 * p * p) - (513.0 / 25.0 * p) + 268.0 / 25.0;
}

float BounceEaseIn(float p)
{
    return 1.0 - BounceEaseOut(1.0 - p);
}

float BounceEaseInOut(float p)
{
    if (p < 0.5)
        return 0.5 * BounceEaseIn(p * 2.0);
    else
        return 0.5 * BounceEaseOut(p * 2.0 - 1.0) + 0.5;
}

float applyTweenFunction(float t, int tweenType)
{
    if (tweenType == TWEEN_LINEAR)
        return t;
    else if (tweenType == TWEEN_QUADRATIC_IN)
        return t * t;
    else if (tweenType == TWEEN_QUADRATIC_OUT)
        return -(t * (t - 2.0));
    else if (tweenType == TWEEN_QUADRATIC_INOUT)
        return t < 0.5 ? 2.0 * t * t : (-2.0 * t * t) + (4.0 * t) - 1.0;
    else if (tweenType == TWEEN_CUBIC_IN)
        return t * t * t;
    else if (tweenType == TWEEN_CUBIC_OUT)
    {
        float f = t - 1.0;
        return f * f * f + 1.0;
    }
    else if (tweenType == TWEEN_CUBIC_INOUT)
    {
        if (t < 0.5)
            return 4.0 * t * t * t;
        float f = 2.0 * t - 2.0;
        return 0.5 * f * f * f + 1.0;
    }
    else if (tweenType == TWEEN_QUARTIC_IN)
        return t * t * t * t;
    else if (tweenType == TWEEN_QUARTIC_OUT)
    {
        float f = t - 1.0;
        return 1.0 - f * f * f * (1.0 - t);
    }
    else if (tweenType == TWEEN_QUARTIC_INOUT)
    {
        if (t < 0.5)
            return 8.0 * t * t * t * t;
        float f = t - 1.0;
        return -8.0 * f * f * f * f + 1.0;
    }
    else if (tweenType == TWEEN_QUINTIC_IN)
        return t * t * t * t * t;
    else if (tweenType == TWEEN_QUINTIC_OUT)
    {
        float f = t - 1.0;
        return f * f * f * f * f + 1.0;
    }
    else if (tweenType == TWEEN_QUINTIC_INOUT)
    {
        if (t < 0.5)
            return 16.0 * t * t * t * t * t;
        float f = 2.0 * t - 2.0;
        return 0.5 * f * f * f * f * f + 1.0;
    }
    else if (tweenType == TWEEN_SINE_IN)
        return sin((t - 1.0) * (3.14159265 * 0.5)) + 1.0;
    else if (tweenType == TWEEN_SINE_OUT)
        return sin(t * (3.14159265 * 0.5));
    else if (tweenType == TWEEN_SINE_INOUT)
        return 0.5 * (1.0 - cos(t * 3.14159265));
    else if (tweenType == TWEEN_CIRCULAR_IN)
        return 1.0 - sqrt(1.0 - t * t);
    else if (tweenType == TWEEN_CIRCULAR_OUT)
        return sqrt((2.0 - t) * t);
    else if (tweenType == TWEEN_CIRCULAR_INOUT)
    {
        if (t < 0.5)
            return 0.5 * (1.0 - sqrt(1.0 - 4.0 * t * t));
        return 0.5 * (sqrt(-((2.0 * t - 3.0) * (2.0 * t - 1.0))) + 1.0);
    }
    else if (tweenType == TWEEN_EXPONENTIAL_IN)
        return (t == 0.0) ? 0.0 : pow(2.0, 10.0 * (t - 1.0));
    else if (tweenType == TWEEN_EXPONENTIAL_OUT)
        return (t == 1.0) ? 1.0 : 1.0 - pow(2.0, -10.0 * t);
    else if (tweenType == TWEEN_EXPONENTIAL_INOUT)
    {
        if (t == 0.0 || t == 1.0)
            return t;
        if (t < 0.5)
            return 0.5 * pow(2.0, 20.0 * t - 10.0);
        return -0.5 * pow(2.0, -20.0 * t + 10.0) + 1.0;
    }
    else if (tweenType == TWEEN_ELASTIC_IN)
        return sin(13.0 * 3.14159265 * 0.5 * t) * pow(2.0, 10.0 * (t - 1.0));
    else if (tweenType == TWEEN_ELASTIC_OUT)
        return sin(-13.0 * 3.14159265 * 0.5 * (t + 1.0)) * pow(2.0, -10.0 * t) + 1.0;
    else if (tweenType == TWEEN_ELASTIC_INOUT)
    {
        if (t < 0.5)
            return 0.5 * sin(13.0 * 3.14159265 * (2.0 * t) * 0.5) * pow(2.0, 10.0 * (2.0 * t - 1.0));
        return 0.5 * (sin(-13.0 * 3.14159265 * 0.5 * ((2.0 * t - 1.0) + 1.0)) * pow(2.0, -10.0 * (2.0 * t - 1.0)) + 2.0);
    }
    else if (tweenType == TWEEN_BACK_IN)
        return t * t * t - t * sin(t * 3.14159265);
    else if (tweenType == TWEEN_BACK_OUT)
    {
        float f = 1.0 - t;
        return 1.0 - (f * f * f - f * sin(f * 3.14159265));
    }
    else if (tweenType == TWEEN_BACK_INOUT)
    {
        if (t < 0.5)
        {
            float f = 2.0 * t;
            return 0.5 * (f * f * f - f * sin(f * 3.14159265));
        }
        else
        {
            float f = 1.0 - (2.0 * t - 1.0);
            return 0.5 * (1.0 - (f * f * f - f * sin(f * 3.14159265))) + 0.5;
        }
    }
    else if (tweenType == TWEEN_BOUNCE_IN)
        return BounceEaseIn(t);
    else if (tweenType == TWEEN_BOUNCE_OUT)
        return BounceEaseOut(t);
    else if (tweenType == TWEEN_BOUNCE_INOUT)
        return BounceEaseInOut(t);
    
    return t; // fallback
}

float getTweenProgress(float startTime, float duration, bool pingpong)
{
    float t = (_Time.y - startTime) / duration;

    if (t < 0)
        return 0;

    if (pingpong == true)
    {
        // Double duration for full ping-pong cycle
        float cycleTime = fmod(t, 2.0); // 0–2
        return cycleTime < 1.0 ? cycleTime : 2.0 - cycleTime; // Ping (0–1), Pong (1–0)
    }
    else
    {
        return frac(t); // Loops from 0 to 1
    }
}


// MOVE TWEEN
void tween3D_float(float3 start, float3 end, float duration, int tweenType, float startTime, bool pingpong, out float3 position)
{
    float t = getTweenProgress(startTime, duration, pingpong);

    float eased = applyTweenFunction(t, tweenType);
    position = lerp(start, end, eased);
}

// SCALE TWEEN
void tween1D_float(float start, float end, float duration, int tweenType, float startTime, bool pingpong, out float scale)
{
    float t = getTweenProgress(startTime, duration, pingpong);

    float eased = applyTweenFunction(t, tweenType);
    scale = lerp(start, end, eased);
}


#endif