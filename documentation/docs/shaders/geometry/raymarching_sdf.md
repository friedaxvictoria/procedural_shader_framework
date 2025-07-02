#  🧩 SDF with Ray Marching Shader

<!-- this one is to display the shader output either by locally storing in the directory under static/images/...
or, external link like of a github can be added 

<!-- this is for locally stored images 
<img src="image directory stored locally inside project" alt="TIE Fighter" width="400" height="225"> -->
<!-- this is for external  link  
<img src="https://......." width="400" alt="TIE Fighter Animation"> -->


<!--
 this is for locally stored videos 
<video controls width="640" height="360" >
  <source src="video path stored locally" type="video/mp4">
  Your browser does not support the video tag.
</video>
-->



- **Category:** Geometry  
- **Author:** Shader Team  
- **Shader Type:** Raymarching with SDFs  
- **Inputs:** `t` — time for raymarching loop (0 → 100)
---

## 🧠 Algorithm

### 🔷 Core Concept

This shader implements **raymarching** using **signed distance fields (SDFs)** to render procedurally generated geometry in real-time. Unlike traditional mesh-based rendering:

- The scene is described using **mathematical distance functions** for each shape.
- A **raymarch loop** iteratively steps forward from the camera along the ray until a surface is hit or the max steps/distance is reached.
- **Lighting** is applied using surface normal approximation using phong lighting model.

This makes it perfect for real-time visuals with minimal mesh overhead — and easily portable across engines like Unity, Godot, and Unreal.

---

## 🎛️ Parameters

| Input Name  | Type            | Description                                            |
|-------------|-----------------|--------------------------------------------------------|
| `t`         | `float`         | Looping time variable for raymarching (0–100)       | 
| `UV`        | `vec2`          | Default Godot input for pixel coordinates              | 
| `resolution`| `vec2`          | Optional — screen or texture resolution for scaling    |

---

## 💻 Shader Code & Includes

??? note "📄 sdf_updated.gdshader"
    ```glsl
        shader_type canvas_item;

        #include "res://addons/includes/sdf_updated.gdshaderinc"
        void fragment() {
            vec4 color;
        vec3 lightPosition = camera_position;
        IntegrationFlexible(UV, color, lightPosition);
            COLOR = color;

        }
    ```

??? note "📄 sdf_updated.gdshaderinc"
    ```glsl
        
        // Integration Shader
        //=========Neu =====================

        #include "res://addons/includes/helper_functions/helper_func.gdshaderinc"

        // Maximum number of objects
        const int MAX_OBJECTS=10;
        //uniform int MAX_OBJECTS;
        // Flattened arrays for SDF object data
        uniform int obj_type[MAX_OBJECTS];
        uniform vec3 obj_position[MAX_OBJECTS];
        uniform vec3 obj_size[MAX_OBJECTS];
        uniform float obj_radius[MAX_OBJECTS];
        uniform vec3 obj_color[MAX_OBJECTS];
        uniform vec2 screen_resolution;
        // Count of actual input objects
        uniform int inputCount;
        uniform vec3 specularColorFloat[MAX_OBJECTS];
        uniform float specularStrengthFloat[MAX_OBJECTS];
        uniform float shininessFloat[MAX_OBJECTS];
        // Other common global uniforms (optional, depending on usage)
        //uniform vec3 lightPosition;
        //uniform float _GammaCorrect;
        //uniform float _Resolution;
        // for camera position and ray dirction
        uniform vec3 camera_position;
        uniform vec3 look_at_position;
        //camera
        uniform vec4 _mousePoint;
        uniform vec4 _ScreenParams;
        uniform float iTime;


        //from SDF shader
        void applyPhongLighting_float(vec3 hitPos, int hitID, vec3 lightPosition, vec3 cameraPosition, vec3 normal, vec3 baseColor, vec3 specularColor, float specularStrength, float shininess, out vec3 lightingColor)
        {
            vec3 viewDir, lightDir, lightColor, ambientColor;
            lightingContext(hitPos, lightPosition, cameraPosition , viewDir, lightDir, lightColor, ambientColor);

            normal = normalize(normal);
            float diff = max(dot(normal, lightDir), 0.15); // change from 0.0 to 0.15 Lambertian diffuse

            vec3 R = reflect(-lightDir, normal); // Reflected light direction
            float spec = pow(max(dot(R, viewDir), 0.0), shininess); // Phong specular

            //float3 colour = _sdfTypeFloat[hitID] == 3 ? getDolphinColor(hitPos, normal, lightPosition) : _baseColorFloat[hitID];
            vec3 colour = baseColor;
            vec3 diffuse = diff * colour * lightColor;
            vec3 specular = spec * specularColor * specularStrength;

            // FIXED: Increased ambient lighting
            vec3 enhancedAmbient = ambientColor * baseColor * 0.4; // ✅ Changed from 0.1 to 0.4

            lightingColor = enhancedAmbient + diffuse + specular;

        // if (hitPos.z == 0.0)
            //{
            // lightingColor = vec3(0, 0, 0);
            //}
        }

        //=============================
        
        float sdSphere(vec3 position, float radius)
        {
            return length(position) - radius;
        }

        float sdRoundBox(vec3 p, vec3 b, float r)
        {
            vec3 q = abs(p) - b + r;
            return length(max(q, 0.)) + min(max(q.x, max(q.y, q.z)), 0.) - r;
        }

        float sdTorus(vec3 p, vec2 radius)
        {
            vec2 q = vec2(length(p.xy) - radius.x, p.z);
            return length(q) - radius.y;
        }

        float evalSDF(int type,vec3 position ,vec3 size, float radius,vec3 p)
        {
            if (type == 0)
            {
                return sdSphere(p - position, radius);
            }
            else if (type == 1)
            {
                return sdRoundBox(p - position, size, radius);
            }
            else if (type == 2)
                return sdTorus(p - position,size.yz);

            return 100000.;
        }

        float evaluateScene(vec3 p ,out int gHitID )
        {
            float d = 100000.;
            int bestID = -1;
            for (int i = 0; i < inputCount; ++i)
            {
                float di = evalSDF(obj_type[i],obj_position[i],obj_size[i],obj_radius[i], p);
                if (di < d)
                {
                    d = di;
                    bestID = i;
                }

            }
            gHitID = bestID;
            return d;
        }

        vec3 getNormal(vec3 p)
        {
            float h = 0.0001;
            vec2 k = vec2(1, -1);
            int dummy;
            return normalize(k.xyy * evaluateScene(p + k.xyy * h,dummy) + k.yyx * evaluateScene(p + k.yyx * h,dummy) + k.yxy * evaluateScene(p + k.yxy * h,dummy) + k.xxx * evaluateScene(p + k.xxx * h,dummy));
        }

        vec2 GetGradient(vec2 intPos, float t)
        {
            float rand = fract(sin(dot(intPos, vec2(12.9898, 78.233))) * 43758.547);
            float angle = 6.283185 * rand + 4. * t * rand;
            return vec2(cos(angle), sin(angle));
        }

        float Pseudo3dNoise(vec3 pos)
        {
            vec2 i = floor(pos.xy);
            vec2 f = fract(pos.xy);
            vec2 blend = f * f * (3. - 2. * f);
            float a = dot(GetGradient(i + vec2(0, 0), pos.z), f - vec2(0., 0.));
            float b = dot(GetGradient(i + vec2(1, 0), pos.z), f - vec2(1., 0.));
            float c = dot(GetGradient(i + vec2(0, 1), pos.z), f - vec2(0., 1.));
            float d = dot(GetGradient(i + vec2(1, 1), pos.z), f - vec2(1., 1.));
            float xMix = mix(a, b, blend.x);
            float yMix = mix(c, d, blend.x);
            return mix(xMix, yMix, blend.y) / 0.7;
        }

        float fbmPseudo3D(vec3 p, int octaves)
        {
            float result = 0.;
            float amplitude = 0.5;
            float frequency = 1.;
            for (int i = 0; i < octaves; ++i)
            {
                result += amplitude * Pseudo3dNoise(p * frequency);
                frequency *= 2.;
                amplitude *= 0.5;
            }
            return result;
        }

        vec4 hash44(vec4 p)
        {
            p = fract(p * vec4(0.1031, 0.103, 0.0973, 0.1099));
            p += dot(p, p.wzxy + 33.33);
            return fract((p.xxyz + p.yzzw) * p.zywx);
        }

        float n31(vec3 p)
        {
            const vec3 S = vec3(7., 157., 113.);
            vec3 ip = floor(p);
            p = fract(p);
            p = p * p * (3. - 2. * p);
            vec4 h = vec4(0., S.yz, S.y + S.z) + dot(ip, S);
            h = mix(hash44(h), hash44(h + S.x), p.x);
            h.xy = mix(h.xz, h.yw, p.y);
            return mix(h.x, h.y, p.z);
        }

        float fbm_n31(vec3 p, int octaves)
        {
            float value = 0.;
            float amplitude = 0.5;
            for (int i = 0; i < octaves; ++i)
            {
                value += amplitude * n31(p);
                p *= 2.;
                amplitude *= 0.5;
            }
            return value;
        }

        struct MaterialParams
        {
            vec3 baseColor;
            vec3 specularColor;
            float specularStrength;
            float shininess;
            float roughness;
            float metallic;
            float rimPower;
            float fakeSpecularPower;
            vec3 fakeSpecularColor;
            float ior;
            float refractionStrength;
            vec3 refractionTint;
        };
        MaterialParams createDefaultMaterialParams(vec3 color,vec3 specularColor, float specularStrength,float shininess)
        {
            MaterialParams mat;
            //Dyamic fro gd script
            mat.baseColor = color;
            mat.specularColor = specularColor;
            mat.specularStrength = specularStrength;
            mat.shininess = shininess;

            mat.roughness = 0.5;
            mat.metallic = 0.;
            mat.rimPower = 2.;
            mat.fakeSpecularPower = 32.;
            mat.fakeSpecularColor = vec3(1.0);
            mat.ior = 1.45;
            mat.refractionStrength = 0. ;
            mat.refractionTint = vec3(1.0);
            return mat;
        }

        MaterialParams makePlastic(vec3 color,vec3 specularColor, float specularStrength,float shininess  )
        {
            MaterialParams mat = createDefaultMaterialParams( color,specularColor,specularStrength,shininess);
            mat.metallic = 0.;
            mat.roughness = 0.4;
            mat.specularStrength = 0.5; //special value for plastic
            return mat;
        }



        float raymarch(vec3 ro, vec3 rd, out vec3 hitPos, out int gHitID )
        {
            gHitID = -1;
            hitPos = vec3(0.0);
            float t = 0.;
            for (int i = 0; i < 100; i++)
            {
                vec3 p = ro + rd * t;
                float noise = fbmPseudo3D(p, 1);
                float d = evaluateScene(p, gHitID) + noise * 0.3;
                if (d < 0.001)
                {
                    hitPos = p;
                    return t;
                }

                if (t > 50.)
                    break;

                t += d;
            }
            return -1.;
        }

        // Add this before IntegrationFlexible, inside sdf_updated.gdshaderinc

        void moveCamera_float(vec2 uv, out vec3 rayOrigin, out vec3 rayDirection)
        {
            vec2 mouse = (_mousePoint.xy == vec2(0.0)) ? vec2(0.0) : _mousePoint.xy / screen_resolution;

            float xCameraAngle = 1.2 - 12.0 * (mouse.x - 0.5);
            float yCameraAngle = 1.2 - 12.0 * (mouse.y - 0.5);
            rayOrigin = vec3(4.0 * sin(xCameraAngle), 4.0 * cos(yCameraAngle), 10.0);

            vec3 forward = normalize(-rayOrigin);
            vec3 right = normalize(vec3(-forward.z, 0.0, forward.x));
            vec3 up = normalize(cross(right, forward));

            rayDirection = normalize(uv.x * right + uv.y * up + 2.0 * forward);
        }

        void IntegrationFlexibleFixed(vec2 INuv, out vec4 frgColor3, vec3 lightPosition)
        {
            vec4 frgColor = vec4(0.0);
            vec2 fragCoord = INuv * screen_resolution;
            vec2 uv = fragCoord / screen_resolution.xy * 2.0 - 1.0;
            uv.x *= screen_resolution.x / screen_resolution.y;

            // IMPROVED CAMERA SETUP:
            vec3 ro = camera_position;
            vec3 target = look_at_position;

            // Use your helper function for better camera basis
            mat3 camera_basis = compute_camera_basis(target, ro);
            vec3 rd = normalize(camera_basis * vec3(uv, -1.5)); // Changed from 2.0 to -1.5

            vec3 hitPos;
            int gHitID;
            float t = raymarch(ro, rd, hitPos, gHitID);
            vec3 color;

            if (t > 0.0)
            {
                // Get surface normal
                vec3 normal = getNormal(hitPos);

                // Get material properties
                vec3 base_color = obj_color[gHitID];
                vec3 specular_color = specularColorFloat[gHitID];
                float shininess = shininessFloat[gHitID];
                float specular_strength = specularStrengthFloat[gHitID];

                // Apply improved lighting
                applyPhongLighting_float(
                    hitPos,
                    gHitID,
                    lightPosition,
                    ro, // camera position
                    normal,
                    base_color,
                    specular_color,
                    specular_strength,
                    shininess,
                    color
                );
            }
            else
            {
                // Background color - make it consistent
                color = vec3(0.1, 0.1, 0.2);
            }

            frgColor = vec4(color, 1.0);
            frgColor3 = frgColor;
        }

        void IntegrationFlexible(vec2 INuv, out vec4 frgColor3,vec3 lightPosition)
        {
            //initilize SDF Array
            //SDF sdfArray[MAX_OBJECTS];
            vec4 frgColor = vec4(0.0);
            vec2 fragCoord = INuv * screen_resolution;
            vec2 uv = fragCoord / screen_resolution.xy * 2. - 1.;
            uv.x *= screen_resolution.x / screen_resolution.y;

        // for (int i = 0; i < inputCount; ++i)
        // {
        //     int t = objInputs[i].type;
        //     if (t == 0)
        //         sdfArray[i] = createSphere(objInputs[i].position, objInputs[i].radius);
        //    else if (t == 1)
            //        sdfArray[i] = createRoundedBox(objInputs[i].position, objInputs[i].size, objInputs[i].radius);
            //   else if (t == 2)
            //     sdfArray[i] = createTorus(objInputs[i].position, objInputs[i].size, objInputs[i].radius);
            //}
            ///////////////

        //    for (int i = 0; i < inputCount; ++i)
        //   {
        //     //int t = objInputs[i].type;
                //if (t == 0)
            //    obj_type[i]=sdfArray[i].type;
            //  obj_position[i]=sdfArray[i].position
                //obj_size[i]=sdfArray[i].size
            // obj_radius[i]=sdfArray[i].radius

                //else if (t == 1)
                // sdfArray[i] = createRoundedBox(objInputs[i].position, objInputs[i].size, objInputs[i].radius);
            // else if (t == 2)
                    //sdfArray[i] = createTorus(objInputs[i].position, objInputs[i].size, objInputs[i].radius);
            //}

            /////////////
            //vec3 ro = vec3(0, 0, 7); // Camera origin
        // vec3 rd = normalize(vec3(uv, -1)); // Ray direction

        //vec3 ro, rd;
            //moveCamera_float(uv, ro, rd);

            // IMPROVED CAMERA SETUP:
            vec3 ro = camera_position;
            vec3 target = look_at_position;

            // Use your helper function for better camera basis
            mat3 camera_basis = compute_camera_basis(target, ro);
            vec3 rd = normalize(camera_basis * vec3(uv, -1.0)); // Changed from 2.0 to -1.5

            //vec3 rd=look_at_position-ro;
            vec3 hitPos;
            int gHitID;
            float t = raymarch(ro, rd, hitPos,gHitID);
            vec3 color;
            //bool sdfHitSuccess = t > 0.;


            //vec3 finalColor;


            if (t > 0.)
            {
                vec3 normal = getNormal(hitPos);
                vec3 viewDir = normalize(ro - hitPos);
                vec3 lightColor = vec3(1., 1., 1.);
                vec3 L = normalize(lightPosition - hitPos);
                vec3 ambientCol = vec3(0.1, 0.1, 0.1);
                //color = applyPhongLighting(ctx, mat);
                vec3 base_color = obj_color[gHitID];
                vec3 specular_color = specularColorFloat[gHitID];
                float shininess = shininessFloat[gHitID];
                float specular_strength = specularStrengthFloat[gHitID];

                MaterialParams mat;
                if (gHitID >= 0 && gHitID < MAX_OBJECTS)
                {
                    mat = makePlastic(base_color,specular_color,specular_strength,shininess);
                }
                else
                {
                    mat = createDefaultMaterialParams(base_color,specular_color,specular_strength,shininess);
                }


                applyPhongLighting_float( hitPos,gHitID, lightPosition, ro, normal, mat.baseColor,mat.specularColor ,mat.specularStrength,mat.shininess,color);
            }
        else
            {
                    color = vec3(1.0, 1.0, 1.0);
            }

            frgColor = vec4(color, 1.0);
            //if (_GammaCorrect)
                //frgColor.rgb = pow(frgColor.rgb, 2.2);

            frgColor3 = frgColor;
        }

        //#endif


    ```

??? note "📄 helper_func.gdshaderinc"
    ```glsl

        void lightingContext(vec3 hitPos, vec3 lightPosition, vec3 cameraPos, out vec3 viewDir, out vec3 lightDir, out vec3 lightColor, out vec3 ambientColor)
        {
            viewDir = normalize(cameraPos - hitPos); // Use the actual camera position
            lightDir = normalize(lightPosition - hitPos);
            lightColor = vec3(1.0, 1.0, 1.0);
            ambientColor = vec3(0.1, 0.1, 0.1);
        }


        // Computes a camera basis matrix (right, up, -forward) given eye and target position
        mat3 compute_camera_basis(vec3 look_at_pos, vec3 eye) {
            vec3 f = normalize(look_at_pos - eye);            // Forward
            vec3 r = normalize(cross(f, vec3(0.0, 1.0, 0.0))); // Right
            vec3 u = cross(r, f);                              // Up
            return mat3(r, u, -f); // Column-major matrix for camera orientation
        }

    ```

??? note "📄 sdf_updated.gd (GDScript)"
    ```gdscript
        extends Node2D

        @export var shader_material_target: CanvasItem
        @export var MAX_OBJECTS := 10
        @export var use_dynamic_look_at := false

        class ShaderObject:
            var type: int
            var position: Vector3
            var size: Vector3
            var radius: float
            var color: Vector3
            var specular_color: Vector3 = Vector3.ONE
            var specular_strength: float = 0.5
            var shininess: float = 32.0

            func set_values(t, pos, sz, r, c, spec_col := Vector3.ONE, spec_str := 1.0, shin := 32.0) -> ShaderObject:
                type = t
                position = pos
                size = sz
                radius = r
                color = c
                specular_color = spec_col
                specular_strength = spec_str
                shininess = shin
                return self

        var shader_objects := []

        func _ready():
            shader_objects = [
                ShaderObject.new().set_values(0, Vector3(0, 0, 0), Vector3.ZERO, 1.0, Vector3(0.2, 0.2, 1.0)),
                ShaderObject.new().set_values(1, Vector3(1.9, 0, 0), Vector3(1, 1, 1), 0.2, Vector3(0.2, 1.0, 0.2)),
                ShaderObject.new().set_values(1, Vector3(-1.9, 0, 0), Vector3(1, 1, 1), 0.2, Vector3(0.2, 1.0, 0.2)),
                ShaderObject.new().set_values(2, Vector3(0, 0, 0), Vector3(1, 5, 1.5), 0.2, Vector3(1.0, 0.2, 0.2))
            ]
            fill_shader_parameters(shader_objects)

        func _process(delta):
            update_shader_uniforms()

        func fill_shader_parameters(obj_list: Array):
            var mat := shader_material_target.material
            if mat == null or not mat is ShaderMaterial:
                push_error("No valid ShaderMaterial found!")
                return

            var count := min(obj_list.size(), MAX_OBJECTS)

            var types := PackedInt32Array()
            var positions := PackedVector3Array()
            var sizes := PackedVector3Array()
            var radii := PackedFloat32Array()
            var colors := PackedVector3Array()
            var specular_colors := PackedVector3Array()
            var specular_strengths := PackedFloat32Array()
            var shininesses := PackedFloat32Array()

            for obj in obj_list:
                types.append(obj.type)
                positions.append(obj.position)
                sizes.append(obj.size)
                radii.append(obj.radius)
                colors.append(obj.color)
                specular_colors.append(obj.specular_color)
                specular_strengths.append(obj.specular_strength)
                shininesses.append(obj.shininess)

            while types.size() < MAX_OBJECTS:
                types.append(0)
                positions.append(Vector3.ZERO)
                sizes.append(Vector3.ZERO)
                radii.append(0.0)
                colors.append(Vector3.ZERO)
                specular_colors.append(Vector3.ONE)
                specular_strengths.append(0.0)
                shininesses.append(1.0)

            mat.set_shader_parameter("obj_type", types)
            mat.set_shader_parameter("obj_position", positions)
            mat.set_shader_parameter("obj_size", sizes)
            mat.set_shader_parameter("obj_radius", radii)
            mat.set_shader_parameter("obj_color", colors)
            mat.set_shader_parameter("specularColorFloat", specular_colors)
            mat.set_shader_parameter("specularStrengthFloat", specular_strengths)
            mat.set_shader_parameter("shininessFloat", shininesses)
            mat.set_shader_parameter("inputCount", count)

        func update_shader_uniforms():
            var mat := shader_material_target.material
            if mat == null or not mat is ShaderMaterial:
                return

            var screen_size := get_viewport().get_visible_rect().size
            var mouse_pos := get_viewport().get_mouse_position()

            # Update common uniforms
            mat.set_shader_parameter("screen_resolution", screen_size)
            mat.set_shader_parameter("_ScreenParams", Vector4(screen_size.x, screen_size.y, 0, 0))
            mat.set_shader_parameter("_mousePoint", Vector4(mouse_pos.x, mouse_pos.y, 0, 0))
            mat.set_shader_parameter("iTime", Time.get_ticks_msec() / 1000.0)

            # Orbit-style camera controlled by mouse
            var x_angle = (mouse_pos.x / screen_size.x - 0.5) * TAU
            var y_angle = clamp((mouse_pos.y / screen_size.y - 0.5) * PI, -PI * 0.4, PI * 0.4)

            var radius = 12.0
            var cam_x = radius * cos(y_angle) * sin(x_angle)
            var cam_y = radius * sin(y_angle)
            var cam_z = radius * cos(y_angle) * cos(x_angle)
            var cam_pos = Vector3(cam_x, cam_y, cam_z)

            mat.set_shader_parameter("camera_position", cam_pos)

            if use_dynamic_look_at:
                mat.set_shader_parameter("look_at_position", get_scene_center())
            else:
                mat.set_shader_parameter("look_at_position", Vector3(0, 0, 0))

        func get_scene_center() -> Vector3:
            if shader_objects.is_empty():
                return Vector3.ZERO
            var center := Vector3.ZERO
            for obj in shader_objects:
                center += obj.position
            return center / shader_objects.size()

    ```


---
 
