shader_type canvas_item;

#include "res://addons/includes/sdf_updated.gdshaderinc"
void fragment() {
    vec4 color;
   vec3 lightPosition = camera_position;
   IntegrationFlexible(UV, color, lightPosition);
    COLOR = color;

}
