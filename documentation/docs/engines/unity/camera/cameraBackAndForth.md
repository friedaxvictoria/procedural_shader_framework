<div class="container">
    <h1 class="main-heading">Camera Back and Forth</h1>
    <blockquote class="author">by Frieda Hentschel</blockquote>
</div>

This function imitates a camera translation by changing the ray origin and the camera matrix. The translation occurs along the z-axis going from 0 to 1 using a sinus function.

---

## The Code

``` hlsl
void backAndForth_float(float speed, out float3x3 mat)
{
    float t = _Time.y * speed;
    mat = float3x3(1, 0, 0, 0, 1, 0, 0, 0, abs(sin(t)));
}
```

---

## The Parameters

### Inputs:
| Name            | Type     | Description |
|-----------------|----------|-------------|
| `speed`        | float   | Speed with which the translation is applied <br> <blockquote>*ShaderGraph default value*: 1</blockquote>|

### Outputs:
| Name            | Type     | Description |
|-----------------|----------|-------------|
| `mat`        | float3x3   | Transformation matrix which __needs to be__ plugged into the [Camera Matrix](cameraMatrix.md) before it can be used within the rest of the pipeline. This is necessary to apply the transformation matrix to the ray origin and to compute the correct camera matrix |

---

## Implementation

=== "Visual Scripting"
    Find the node at `PSF/Camera/Back and Forth`

    <figure markdown="span">
        ![Unity Back And Forth Camera](../images/camera/backAndForth.png){ width="400" }
    </figure>

=== "Standard Scripting"
    !Utku Input
    Include ...

---

ADD LINK
Find the original shader code [here](unity/cameraMatrix.md).