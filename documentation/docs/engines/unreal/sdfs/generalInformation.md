<div class="container">
    <h1 class="main-heading">SDFs in Unreal Engine</h1>
    <blockquote class="author">by Maximilian Lipski</blockquote>
</div>

Due to engine-restrictions, some adjustments to the shader library's implemenation were made in order to achieve the same output. 

---

## Storage

Since Unity's ShaderGraph does not support arrays of structs, the struct ```SDF``` was split into its separate parameters. Each parameter is stored within its own array. The exact setup of the arrays can be found in the [Global Variables](../globalVariables.md). 

Arrays in their very nature are not modifyable in their size. Thus, a pre-defined size had to be chosen which determines the maximum amount of SDFs that can be added to a scene. For this implementation, that size was set to **20**. 

---

## Instantiation 

Furthermore, ShaderGraph does not allow the access of arrays using input parameters, non-static, and non-constant variables. Thus, to fill the arrays, a work-around using for-loops was implemented. Each SDF uses an **index** to determine the location that it will be stored in. Subsequently, a loop iterates over all possible indices and writes the inputs once the correct index has been reached.

To allow for proper processing, the output-indices should be used as input-indices for the following SDF. The last SDF's output-index should be connected to the **number of SDFs** in the [SDF Raymarching](raymarching.md). This setup also ensures that, in case ShaderGraph is used, all nodes are connected to the graph.

Additionally, each SDF is defined by a type. Due to ShaderGraph's limitations and lack of support for *integers*, it is defined as a *float*. The values for the types can be found in the code for the respective SDFs and the [SDF Raymarching](raymarching.md).

The instantiation of an SDF is implemented as follows:

``` hlsl
void addSDF(float index, float type, float3 position, float3 size, float radius, float3 axis, float angle, float noise, float3 baseColor, float3 specularColor, float specularStrength,
float shininess, float timeOffset, float speed){
    for (int i = 0; i <= MAX_OBJECTS; i++)
    {
        if (i == index)
        {
            _sdfType[i] = type;
            _sdfPosition[i] = position;
            _sdfSize[i] = size;
            _sdfRadius[i] = radius;
            _sdfRotation[i] = computeRotationMatrix(normalize(axis), angle * PI / 180);
            _sdfNoise[i] = noise;
            
            _objectBaseColor[i] = baseColor;
            _objectSpecularColor[i] = specularColor;
            _objectSpecularStrength[i] = specularStrength;
            _objectShininess[i] = shininess;

            _timeOffsetDolphin[i] = timeOffset;
            _speedDolphin[i] = speed;
            break;
        }
    }
}
```

## Example Connectivity

=== "Visual Scripting"

    ![Unity Mouse-Based Camera Rotation](){ width="300" }

=== "Standard Scripting"

    Some code