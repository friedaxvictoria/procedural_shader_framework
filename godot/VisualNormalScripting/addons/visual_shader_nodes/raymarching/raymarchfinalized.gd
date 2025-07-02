# UnifiedRaymarchNode.gd - Dynamic Version
# Save this file as: res://addons/sdf_nodes/UnifiedRaymarchNode.gd
@tool
extends VisualShaderNodeCustom
class_name UnifiedRaymarchNode

func _get_name() -> String:
    return "RaymarchSDF"

func _get_category() -> String:
    return "SDF Rendering"

func _get_description() -> String:
    return "Complete SDF raymarching with lighting - uses dynamic SDF parameters"

func _get_return_icon_type() -> int:
    return VisualShaderNode.PORT_TYPE_VECTOR_4D

func _get_input_port_count() -> int:
    return 4

func _get_input_port_name(port: int) -> String:
    match port:
        0: return "uv"
        1: return "resolution"
        2: return "sdf_count"
        3: return "ray_origin"
        _: return ""

func _get_input_port_type(port: int) -> int:
    match port:
        0: return VisualShaderNode.PORT_TYPE_VECTOR_2D
        1: return VisualShaderNode.PORT_TYPE_VECTOR_2D
        2: return VisualShaderNode.PORT_TYPE_SCALAR_INT
        3: return VisualShaderNode.PORT_TYPE_VECTOR_3D
        _: return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count() -> int:
    return 1

func _get_output_port_name(port: int) -> String:
    return "color"

func _get_output_port_type(port: int) -> int:
    return VisualShaderNode.PORT_TYPE_VECTOR_4D

func _get_global_code(mode: Shader.Mode) -> String:
    return """
#include "res://addons/includes/dynamic_sdf_system.gdshaderinc"

vec4 renderDynamicSDFScene(vec2 uv, vec2 resolution, int sdfCount, vec3 rayOrigin) {
    // Set up camera ray
    vec2 screenUV = uv * 2.0 - 1.0;
    screenUV.x *= resolution.x / resolution.y;
    
    vec3 rayDirection = normalize(vec3(screenUV, -1.0));

    // Built-in light setup
    vec3 lightPos = vec3(5.0, 5.0, 5.0);
    vec3 lightColor = vec3(1.0);

    // Perform dynamic raymarching
    vec3 hitPosition;
    int hitID;
    float hitDistance = dynamicRaymarch(rayOrigin, rayDirection, sdfCount, hitPosition, hitID);

    // Background color
    vec3 backgroundColor = vec3(0.1, 0.1, 0.2);

    // Check if we hit something
    if (hitDistance < 0.0 || hitID < 0) {
        return vec4(backgroundColor, 1.0);
    }
    
    // Calculate surface normal
    vec3 normal = getDynamicNormal(hitPosition, sdfCount);
    
    // View direction (from surface to camera)
    vec3 viewDir = normalize(rayOrigin - hitPosition);
    
    // Light direction
    vec3 lightDir = normalize(lightPos - hitPosition);
    
    // Distance attenuation
    float lightDistance = length(lightPos - hitPosition);
    float attenuation = 1.0 / (1.0 + 0.09 * lightDistance + 0.032 * lightDistance * lightDistance);
    
    // Get material properties based on object type
    vec3 albedo;
    float metallic;
    float roughness;
    float specular;
    
    // Use the actual object type from the dynamic system
    if (g_types[hitID] == 0) {        // Sphere
        albedo = vec3(0.2, 0.2, 1.0);     // Blue
        metallic = 0.0;
        roughness = 0.3;
        specular = 0.8;
    } else if (g_types[hitID] == 1) { // Round box
        albedo = vec3(0.2, 1.0, 0.2);     // Green
        metallic = 0.1;
        roughness = 0.6;
        specular = 0.4;
    } else if (g_types[hitID] == 2) { // Torus
        albedo = vec3(1.0, 0.2, 0.2);     // Red
        metallic = 0.8;
        roughness = 0.2;
        specular = 0.9;
    } else {
        // Fallback color based on hitID
        float colorPhase = float(hitID) * 0.5;
        albedo = vec3(
            0.5 + 0.5 * sin(colorPhase),
            0.5 + 0.5 * sin(colorPhase + 2.0),
            0.5 + 0.5 * sin(colorPhase + 4.0)
        );
        metallic = 0.2;
        roughness = 0.5;
        specular = 0.6;
    }
    
    // Lambertian diffuse
    float NdotL = max(dot(normal, lightDir), 0.0);
    vec3 diffuse = NdotL * albedo * lightColor * attenuation;
    
    // Blinn-Phong specular
    vec3 halfDir = normalize(lightDir + viewDir);
    float NdotH = max(dot(normal, halfDir), 0.0);
    float shininess = mix(2.0, 256.0, 1.0 - roughness);
    float spec = pow(NdotH, shininess);
    vec3 specularColor = spec * specular * lightColor * attenuation;
    
    // Simple metallic workflow
    vec3 finalDiffuse = mix(diffuse, vec3(0.0), metallic);
    vec3 finalSpecular = mix(specularColor, diffuse * spec, metallic);
    
    // Rim lighting for extra pop
    float rimPower = 2.0;
    float rim = 1.0 - max(dot(normal, viewDir), 0.0);
    vec3 rimLight = pow(rim, rimPower) * lightColor * 0.3;
    
    // Ambient light
    vec3 ambient = albedo * 0.15;
    
    // Combine all lighting
    vec3 finalColor = ambient + finalDiffuse + finalSpecular + rimLight;
    
    // Optional: Add fog based on distance
    float fogFactor = exp(-hitDistance * 0.02);
    finalColor = mix(backgroundColor, finalColor, fogFactor);
    
    // Tone mapping for better colors
    finalColor = finalColor / (finalColor + vec3(1.0));
    
    return vec4(finalColor, 1.0);
}
"""

func _get_code(input_vars: Array[String], output_vars: Array[String], mode: Shader.Mode, type: VisualShader.Type) -> String:
    var uv = input_vars[0] if input_vars[0] != "" else "UV"
    var resolution = input_vars[1] if input_vars[1] != "" else "vec2(1024.0, 768.0)"
    var sdf_count = input_vars[2] if input_vars[2] != "" else "0"
    var ray_origin = input_vars[3] if input_vars[3] != "" else "vec3(0.0, 0.0, 7.0)"
    
    return "%s = renderDynamicSDFScene(%s, %s, %s, %s);" % [
        output_vars[0],
        uv,
        resolution,
        sdf_count,
        ray_origin
    ]