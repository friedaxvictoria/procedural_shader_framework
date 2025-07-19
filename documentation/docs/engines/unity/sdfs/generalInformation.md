# SDFs in Unity

Due to engine-restrictions, some adjustments to the shader library's implemenation were made in order to achieve the same output. 

---

## Storage

Since Unity's ShaderGraph does not support arrays of structs, the struct ```SDF``` was split into its separate parameters. Each parameter is stored within its own array. The exact setup of the arrays can be found in the [Global Variables](../globalVariables.md). 

Arrays in their very nature are not modifyable in their size. Thus, a pre-defined size had to be chosen which determines the maximum amount of SDFs that can be added to a scene. For this implementation, that size was set to **20**. 

---

## Instantiation 

Furthermore, ShaderGraph does not allow the access of arrays using input parameters, non-static, and non-constant variables. Thus, to fill the arrays, a work-around using for-loops was implemented. 