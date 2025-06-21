void applyPhongLighting(
    // Surface Properties
    vec3 Position,
    vec3 Normal,
    vec3 ViewDir,
    
    // Light Properties
    vec3 LightPos,
    vec3 LightColor,
    vec3 AmbientColor,
    
    // Material Properties
    vec3 BaseColor,
    vec3 SpecularColor,
    float SpecularStrength,
    float Shininess,
    
    out vec3 OutputColor
){
    vec3 L = normalize(LightPos - Position);
    float diff = max(dot(Normal, L), 0.0);
    
    vec3 R = reflect(-L, Normal);
    float spec = pow(max(dot(R, ViewDir), 0.0), Shininess);
    
    vec3 diffuse = diff * BaseColor * LightColor;
    vec3 specular = spec * SpecularColor * SpecularStrength;
    
    OutputColor = AmbientColor + diffuse + specular;
}