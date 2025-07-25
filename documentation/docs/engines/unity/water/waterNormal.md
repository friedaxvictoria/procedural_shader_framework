<div class="container">
    <h1 class="main-heading">Sample Water Normal</h1>
    <blockquote class="author">by Frieda Hentschel</blockquote>
</div>

This function computes the normal of the water surface at a given position. It can be used to adjust an objects orientation to match up with the water's. 

> Due to the normal of the water surface changing very rapidly, an approach was implemented that samples four normals with a distance of **sampleRadius** to the position in the x-z-plane. Their average is taken. To additionally smooth out the rapid change, the normal's influence can be adjusted.

---

## The Code

??? "Water Related Helper Functions"
    ```` hlsl
    float waveStrength = 0.0;

    float2x2 compute2DRotationMatrix(float angle)
    {
        float c = cos(angle), s = sin(angle);
        return float2x2(c, s, -s, c);
    }

    float hashNoise(float3 p)
    {
        float3 f = floor(p), magic = float3(7, 157, 113);
        p -= f;
        float4 h = float4(0, magic.yz, magic.y + magic.z) + dot(f, magic);
        p *= p * (3.0 - 2.0 * p);
        h = lerp(frac(sin(h) * 43785.5), frac(sin(h + magic.x) * 43785.5), p.x);
        h.xy = lerp(h.xz, h.yw, p.y);
        return lerp(h.x, h.y, p.z);
    }

    float computeWave(float3 position)
    {
        float3 warped = position - float3(0, 0, _Time.y % 62.83 * 3.0);

        float direction = sin(_Time.y * 0.15);
        float angle = 0.001 * direction;
        float2x2 rotation = compute2DRotationMatrix(angle);

        float accumulated = 0.0, amplitude = 3.0;
        for (int i = 0; i < 7; i++)
        {
            accumulated += abs(sin(hashNoise(warped * 0.15) - 0.5) * 3.14) * (amplitude *= 0.51);
            warped.xy = mul(warped.xy, rotation);
            warped *= 1.75;
        }
        
        waveStrength = accumulated;

        float height = position.y + accumulated;
        height *= 0.5;
        height += 0.3 * sin(_Time.y + position.x * 0.3); // slight bobbing
        return height;
    }

    float3 getNormal(float3 position, float delta)
    {
        return normalize(float3(
                computeWave(position + float3(delta, 0.0, 0.0)) -
                computeWave(position - float3(delta, 0.0, 0.0)),
                0.02,
                computeWave(position + float3(0.0, 0.0, delta)) -
                computeWave(position - float3(0.0, 0.0, delta))
            ));
    }

    float4 traceWater(float3 rayDirection)
    {
        float d = 0;
        float t = 0;
        float3 hitPosition = float3(0, 0, 0);
        float3 outputPos;
        for (int i = 0; i < 100; i++)
        {
            float3 p = _rayOrigin + rayDirection * t;
            d = computeWave(p);
            if (d < 0.0001)
            {
                hitPosition = p;
                break;
            }
            t += d;
            if (t > _raymarchStoppingCriterium)
                break;
        }
        return float4(hitPosition, t);
    }

    float3 getNormal(float3 position, float delta)
    {
        return normalize(float3(
                computeWave(position + float3(delta, 0.0, 0.0)) -
                computeWave(position - float3(delta, 0.0, 0.0)),
                0.02,
                computeWave(position + float3(0.0, 0.0, delta)) -
                computeWave(position - float3(0.0, 0.0, delta))
            ));
    }
    ````

```` hlsl
void adaptableNormal_float(float3 position, float3 offset, float influence, float sampleRadius, out float3 normal)
{
    float3 normal1 = getNormal(position + float3(sampleRadius, 0.0, 0.0), 1);
    float3 normal2 = getNormal(position - float3(sampleRadius, 0.0, 0.0), 1);
    float3 normal3 = getNormal(position + float3(0, 0.0, sampleRadius), 1);
    float3 normal4 = getNormal(position - float3(0, 0.0, sampleRadius), 1);
    normal = influence * (normal1 + normal2 + normal3 + normal4)/4 + offset;
}
````

---

## The Parameters

### Inputs:
| Name            | Type     | Description |
|-----------------|----------|-------------|
| `position`  <img width=50/>  | float3   |  Position at which the normal is to be sampled |
| `offset`  | float3   |  Offset axis that is added to the computed normal to allow for object rotation's to be applied on top of this normal |
| `influence` | float   |  Amount with which the water's normal contributes to the output. Typically a value between 0 and 1 <br> <blockquote>*ShaderGraph default value*: 1</blockquote> |
| `sampleRadius`  | float   |  Distance at which four normals are sampled in x- and z-direction |

### Outputs:
| Name            | Type     | Description |
|-----------------|----------|-------------|
| `normal` | float3   |  Adjusted normal at the inputted position. The vector can be used as an axis for an SDF function (e.g. [Sphere](../sdfs/sphere.md)). The normal is not normalised due to the normalisation occuring in later computations

> To get the true normal at a given position, set ```influence=1``` and ```sampleRadius=0```.

---

## Implementation

=== "Visual Scripting"
    Find the node at `PSF/Environments/Water Normal`
    
    <figure markdown="span">
        ![Unity Water Normal](../images/water/waterNormal.png){ width="500" }
    </figure>

=== "Standard Scripting"
    Include - ```#include "Packages/com.tudresden.proceduralshaderframeworkpackage/Runtime/scripts/water_surface.hlsl"```

    Example Usage

    ```hlsl
    float3 adjustedNormal;
    adaptableNormal_float(float3(0,0,0), float3(0,0,0), 1, 0, adjustedNormal);
    ```


---

This is an engine-specific extension to the shader code's water shader which can be found [here](../../../shaders/scenes/water_surface.md).