<div class="container">
    <h1 class="main-heading">Global Variables</h1>
    <blockquote class="author">by Maximilian Lipski</blockquote>
</div>

The global variables are an essential part of the integration in Unreal Engine. They are defined in a separate file and included in all hlsl-files that require them. They can easily distinguished by their signature underscore **_variableName**.

The global variables define the maximum amount of SDFs that can be added to a single shader to be **20**. Read more about this setup in the [SDF General Information](sdfs/generalInformation.md). 

---

## The Code

``` hlsl
#define MAX_SDFS 20

static float3 _rayOrigin = float3(0.0, 0, 7.0);
static float _GammaCorrect;

static float _raymarchStoppingCriterium = 100;
```