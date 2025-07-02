


// --- External declarations (defined in main shader) ---
//extern sampler2D _MainTex;
//extern vec4 _MainTex_TexelSize;
//extern vec4 _Mouse;
//extern float _GammaCorrect;
//extern float _Resolution;

// --- Constants ---
//#define iResolution vec3(_Resolution, _Resolution, _Resolution)
//#define glsl_mod(x,y) (((x)-(y)*floor((x)/(y))))


//float SimpleNoise(vec2 p)
//{
    //return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
//}
//
//float PerlinNoise(vec2 p)
//{
    //return (SimpleNoise(p) + SimpleNoise(p * 2.0) * 0.5 + SimpleNoise(p * 4.0) * 0.25);
//}
//
//vec3 ApplyPerlinNoise(vec3 color, vec2 uv, float time)
//{
    //float n = PerlinNoise(uv * 5.0 + time);
    //return color * n;
//}
//
//vec3 ApplySimpleNoise(vec3 color, vec2 uv, float time)
//{
    //float n = SimpleNoise(uv * 10.0 + time);
    //return color * n;
//}
//
//vec3 ApplyPulse(vec3 color, float time)
//{
    //float pulse = abs(sin(time * 2.0));
    //return color * pulse;
//}
//
//vec3 ApplyVerticalStripes(vec3 color, vec2 uv, float time)
//{
    //float stripe = step(0.5, fract(uv.y * 10 + time));
    //return color * stripe;
//}
//
//vec3 ApplyHorizontalStripes(vec3 color, vec2 uv, float time)
//{
    //float stripe = step(0.5, fract(uv.x * 10 + time));
    //return color * stripe;
//}
//
//vec3 ApplyRippleGeometry(vec3 pos, float time, float rippleStrength)
//{
    //pos.y += sin(pos.x * 10 + time) * rippleStrength;
    //return pos;
//}
//
//vec3 ApplyTwistGeometry(vec3 pos, float twistStrength)
//{
    //float angle = pos.y * twistStrength;
    //float c = cos(angle);
    //float s = sin(angle);
    //vec2 xz = vec2(c * pos.x - s * pos.z, s * pos.x + c * pos.z);
    //pos.x = xz.x;
    //pos.z = xz.y;
    //return pos;
//}
//
//vec3 ApplySpinGeometry(vec3 pos, float time, float spinSpeed)
//{
    //float angle = time * spinSpeed;
    //float c = cos(angle);
    //float s = sin(angle);
    //vec2 xz = vec2(c * pos.x - s * pos.z, s * pos.x + c * pos.z);
    //pos.x = xz.x;
    //pos.z = xz.y;
    //return pos;
//}
//#ifndef MODULAR_SDF_SCENE_SHADERINC
//#define MODULAR_SDF_SCENE_SHADERINC

// Maximum number of objects

// Object struct

//// Uniforms
//ObjectInput objInputs[MAX_OBJECTS];
//int inputCount=0;


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
//struct SDF
//{
    //int type;
    //vec3 position;
    //vec3 size;
    //float radius;
//};
//static int gHitID = -99;
//static SDF sdfArray[10];
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



//SDF createSphere(vec3 position, float radius)
//{
    //SDF s;
    //s.type = 0; // 0 = Sphere
    //s.position = position;
    //s.size = vec3(0, 0, 0);
    //s.radius = radius;
    //return s;
//}

//SDF createRoundedBox(vec3 position, vec3 size, float radius)
//{
    //SDF s;
    //s.type = 1; // 1 = Rounded Box
    //s.position = position;
    //s.size = size;
    //s.radius = radius;
    //return s;
//}

//SDF createTorus(vec3 position, vec3 size, float radius)
//{
    //SDF s;
    //s.type = 2; // 2 = Torus
    //s.position = position;
    //s.size = size;
    //s.radius = radius;
    //return s;
//}

//struct ObjectInput
//{
    //int type; // 0 = sphere, 1 = box, 2 = torus
    //vec3 position;
    //vec3 size;
    //float radius;
    //vec3 color;
//};

//void Integration(vec2 INuv, out vec4 frgColor3,
//vec3 torusColor = vec3(1., 0.2, 0.2), float torusRadius = 0.2, vec3 torusSize = vec3(1.0, 5.0, 1.5), vec3 torusPosition = vec3(0.0, 0.0, 0.0),
//vec3 cubeColor = vec3(0.2, 1., 0.2), vec3 cubeSize = vec3(1.0, 1.0, 1.0), vec3 cubePosition1 = vec3(1.9, 0.0, 0.0), vec3 cubePosition2 = vec3(-1.9, 0.0, 0.0),
//vec3 sphereColor = vec3(0.2, 0.2, 1.), float sphereRadius = 1.0, vec3 spherePosition = vec3(0.0, 0.0, 0.0),
//vec3 lightPosition = vec3(5.0, 5.0, 5.0)
//)
//{
    //vec4 frgColor = 0;
    //vec2 fragCoord = INuv * _Resolution;
    //vec2 uv = fragCoord / iResolution.xy * 2. - 1.;
    //uv.x *= iResolution.x / iResolution.y;
//
    //uv.x *= iResolution.x / iResolution.y;
//
    //SDF circle;
    //circle.type = 0;
    //circle.position = spherePosition;
    //circle.size = vec3(0.0, 0.0, 0.0);
    //circle.radius = sphereRadius;
//
    //SDF roundBox;
    //roundBox.type = 1;
    //roundBox.position = cubePosition1;
    //roundBox.size = cubeSize;
    //roundBox.radius = 0.2;
//
    //SDF roundBox2;
    //roundBox2.type = 1;
    //roundBox2.position = cubePosition2;
    //roundBox2.size = cubeSize;
    //roundBox2.radius = 0.2;
//
    //SDF torus;
    //torus.type = 2;
    //torus.position = torusPosition;
    //torus.size = torusSize;
    //torus.radius = torusRadius;
//
    //sdfArray[0] = circle;
    //sdfArray[1] = roundBox;
    //sdfArray[2] = roundBox2;
    //sdfArray[3] = torus;
    //vec3 ro = vec3(0, 0, 7); // Camera position
    //vec3 rd = normalize(vec3(uv, -1)); // Ray direction
    //vec3 hitPos;
    //float t = raymarch(ro, rd, hitPos);
    //vec3 color;
    //if (t > 0.)
    //{
        //vec3 normal = getNormal(hitPos);
        //vec3 viewDir = normalize(ro - hitPos);
        //vec3 lightPos = lightPosition;
        //vec3 lightColor = ((vec3) 1.);
        //vec3 L = normalize(lightPos - hitPos);
        //vec3 ambientCol = ((vec3) 0.1);
        //LightingContext ctx;
        //ctx.position = hitPos;
        //ctx.normal = normal;
        //ctx.viewDir = viewDir;
        //ctx.lightDir = L;
        //ctx.lightColor = lightColor;
        //ctx.ambient = ambientCol;
        //MaterialParams mat;
        //if (gHitID == 0)
        //{
            //mat = makePlastic(sphereColor);
        //}
        //else if (gHitID == 1 || gHitID == 2)
        //{
            //mat = makePlastic(cubeColor);
        //}
        //else if (gHitID == 3)
        //{
            //mat = createDefaultMaterialParams();
            //mat.baseColor = torusColor;
            //mat.shininess = 64.;
        //}
        //else
        //{
            //mat = createDefaultMaterialParams();
        //}
        //color = applyPhongLighting(ctx, mat);
    //}
    //else
    //{
        //color = ((vec3) 0.);
    //}
    //frgColor = vec4(color, 1.);
    //if (_GammaCorrect)
        //frgColor.rgb = pow(frgColor.rgb, 2.2);
//
    //frgColor3 = frgColor;
//}

//#ifndef MAX_OBJECTS
//#define MAX_OBJECTS 10
//#endif

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
    vec3 rd = normalize(camera_basis * vec3(uv, -1.5)); // Changed from 2.0 to -1.5

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

