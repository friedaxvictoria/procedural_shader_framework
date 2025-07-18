shader_type canvas_item;

#include "res://addons/includes/sdf_updated.gdshaderinc"
void fragment() {
    //TODO: pass call any noise fucntion from inclusive file
    //and pass noise as param
    vec4 color;
   //Define variables to add combineWatwer and combineDesret
   //IntegrationFlexible(UV, color, lightPosition,noise,combineWater,combineDesret);
   IntegrationFlexible(UV, color);
    COLOR = color;

}
