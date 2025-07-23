# Surface Normal Estimation

- **Category:** Rendering

- **Author:** Ruimin Ma

- **Shader Type:** Tetrahedral adaptive SDF normal estimation

- **Input:** 

  `p`: 3D world-space position at which to estimate the surface normal

---

## 🧠 Algorithm

### 1. `GetNormal(vec3 p)`
Estimates the surface normal at a given point `p` by computing the **gradient** of the Signed Distance Field (SDF) using **central differences**:

- Defines a small epsilon offset `eps = 0.001`.
- For each axis (x, y, z), it evaluates the SDF at slightly perturbed positions forward and backward.
- The difference between these values along each axis approximates the partial derivative.
- The resulting gradient vector is normalized to produce a unit-length surface normal pointing outward from the surface.

#### Formula:

Let `Scene(p)` be the Signed Distance Field function, and `p = (x, y, z)`.  
The surface normal vector `n` is approximated using central differences:
$$
\mathbf{n} \approx \frac{1}{2\epsilon}
\begin{pmatrix}
\text{Scene}(x+\epsilon, y, z) - \text{Scene}(x-\epsilon, y, z) \\
\text{Scene}(x, y+\epsilon, z) - \text{Scene}(x, y-\epsilon, z) \\
\text{Scene}(x, y, z+\epsilon) - \text{Scene}(x, y, z-\epsilon)
\end{pmatrix}
$$

Then normalized to obtain the unit normal vector:

$$
\hat{\mathbf{n}} = \frac{\mathbf{n}}{\|\mathbf{n}\|}
$$

---

 ## 🎛️ Parameters

| Name | Description          | Range | Notes |
|------|-------------------|-------|-------|
| `p`   | World-space position to estimate normal |                | Usually the surface hit point |
| `eps` | Step size for central differencing      | constant(0.01) |                               |



## 💻 Code
`GetNormal` computes an approximate surface normal at a given point `p` by evaluating the gradient of the Signed Distance Field using central differences.

```glsl
vec3 GetNormal(vec3 p) {
    float eps = 0.001;
    vec2 h = vec2(eps, 0);
    float dx = Scene(p + vec3(h.x, h.y, h.y)) - Scene(p - vec3(h.x, h.y, h.y));
    float dy = Scene(p + vec3(h.y, h.x, h.y)) - Scene(p - vec3(h.y, h.x, h.y));
    float dz = Scene(p + vec3(h.y, h.y, h.x)) - Scene(p - vec3(h.y, h.y, h.x));
    return normalize(vec3(dx, dy, dz));
}
```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/rendering/GetNormal.glsl)
