#include "res://addons/includes/helper_functions/helper_func.gdshaderinc"

//const int MAX_OBJECTS = 10;

//uniform vec3 specularColorFloat[MAX_OBJECTS];
//uniform float specularStrengthFloat[MAX_OBJECTS];
//uniform float shininessFloat[MAX_OBJECTS];


//from SDF shader
void applyPhongLighting(vec3 hitPos, int hitID,vec3 lightPosition, vec3 normal, 
    out vec3 lightingColor,)
{
    vec3 viewDir, lightDir, lightColor, ambientColor;
    lightingContext(hitPos, lightPosition, viewDir, lightDir, lightColor, ambientColor);
    float diff = max(dot(normal, lightDir), 0.0); // Lambertian diffuse

    vec3 R = reflect(-lightDir, normal); // Reflected light direction
    float spec = pow(max(dot(R, viewDir), 0.0), shininess); // Phong specular

    //float3 colour = _sdfTypeFloat[hitID] == 3 ? getDolphinColor(hitPos, normal, lightPosition) : _baseColorFloat[hitID];
    //vec3 colour = obj_color[hitID];
    vec3 diffuse = diff * base_color * lightColor;
    vec3 specular = spec * specular_color * specular_strength;

    lightingColor = ambientColor + diffuse + specular;

   // if (hitPos.z == 0.0)
    //{
      // lightingColor = vec3(0, 0, 0);
    //}
}