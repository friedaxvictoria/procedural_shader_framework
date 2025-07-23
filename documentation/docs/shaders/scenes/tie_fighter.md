<div class="container">
    <h1 class="main-heading">TIE Fighter</h1>
    <blockquote class="author">by Ruimin Ma</blockquote>
</div>

<img src="../../../static/images/images4Shaders/tie_fighter.gif" alt="tie_fighter" width="400" height="225">

- **Category:** Scene

- **Shader Type:** TIE_Fighter

- **Input:** 

  `ties[]`: Per‑instance parameters (position + three swing rates)

---

## 🧠 Algorithm

1. **Per‑instance animation (`tiePos`)**  
   * world → local (`p – tie.position`)  
   * add 3‑axis sinusoidal offsets (`XOffset`, `YOffset`, `ZOffset`)  
   * apply a tiny xy‑plane roll to fake banking  

2. **Signed‑distance body (`sdTie`)**  
   * Build the hull with analytic primitives:  
     * wings =`sdTri` + small offset  
     * cockpit sphere & glass  
     * struts (`sdCyl`, `sdHex`, `sdBox`)  
   * Return `Hit(d, id)` where **`id == 2` for wing panels**, everything else `id ≠ 2`.

3. **Scene union (`mapAll`)**  
   * Loop over `TIE_COUNT`, call `tieDistance` and keep the closest hit.

4. **Normal (`TIENormal`)**  
   * Central‑difference on `mapAll` for shading or rim‑light if you add lighting later.

5. **Base colour (`getTieColor`)**  
   * Two‑tone grey: dark for wings, light for cockpit & frame.  
   * (No lighting calculation – pure albedo.)

6. **Ray marcher (`trace`)**  
   * Classic sphere‑tracing loop → early‑out on small \|d\| or max distance.

 ## 🎛️ Parameters

| Name | Description          | Range | Notes |
|------|-------------------|-------|-------|
| `T` | Global time (`iTime`) – drives the idle swing | — |                            |
| `TIE_COUNT`    | Compile‑time number of instances              | self-defined | Increase for more fighters |
| `Tie.position` | World‑space anchor of one TIE | — |  |
| `Tie.XOffset` | X‑axis swing frequency | — |  |
| `Tie.YOffset` | Y‑axis swing frequency | —     |  |
| `Tie.ZOffset` | Z‑axis swing frequency | — |  |

## 💻 Code
Pure signed-distance–field module that generates and animates one or more Star-Wars TIE Fighters entirely procedurally.

```glsl
/* ---------- Global ---------- */
#define TIE_COUNT 2    

float T;                            // iTime        
struct Hit { float d; int id; };    // Distance + Part ID

/* -----------------  Instance data ------------------------- */
struct Tie {
    vec3  position;                 
    float XOffset;                  // x-direciton swing 0.7
    float YOffset;                  // y-direciton swing 1.0
    float  ZOffset;                  // z-direciton swing 1.1
};
Tie ties[TIE_COUNT];                // From CPU like ties[0] = Tie(vec3(-4,0, 8), 0.7,1.0,1.1);

/* ---------- Hash / Noise ---------- */
vec4 hash44(vec4 p) {
    p = fract(p*vec4(.1031,.103,.0973,.1099));
    p += dot(p,p.wzxy+33.33);
    return fract((p.xxyz+p.yzzw)*p.zywx);
}
float n31(vec3 p) {
    const vec3 s = vec3(7,157,113);
    vec3 ip=floor(p); p=fract(p);
    p=p*p*(3.-2.*p);
    vec4 h=vec4(0,s.yz,s.y+s.z)+dot(ip,s);
    h=mix(hash44(h),hash44(h+s.x),p.x);
    h.xy=mix(h.xz,h.yw,p.y);
    return mix(h.x,h.y,p.z);
}

/* ---------- Helpers ---------- */
mat2 rot(float a){ float c=cos(a),s=sin(a);return mat2(c,s,-s,c); }
vec2 opModPolar(vec2 p,float n,float o){
    float ang=3.141/n;
    float a=mod(atan(p.y,p.x)+ang+o,2.*ang)-ang;
    return length(p)*vec2(cos(a),sin(a));
}
float dot2(vec3 v){return dot(v,v);}

/* ---------- sdf primitives ---------- */
float sdHex(vec3 p,vec2 h){
    const vec3 k=vec3(-.866,.5,.577);
    p=abs(p);
    p.xy-=2.*min(dot(k.xy,p.xy),0.)*k.xy;
    vec2 d=vec2(length(p.xy-vec2(clamp(p.x,-k.z*h.x,k.z*h.x),h.x))*sign(p.y-h.x),p.z-h.y);
    return min(max(d.x,d.y),0.)+length(max(d,0.));
}
float sdBox(vec3 p,vec3 b){vec3 q=abs(p)-b;return length(max(q,0.))+min(max(q.x,max(q.y,q.z)),0.);}
float sdPlane(vec3 p,vec3 n){return dot(p,n);}
float sdCyl(vec3 p,vec2 hr){vec2 d=abs(vec2(length(p.xy),p.z))-hr;return min(max(d.x,d.y),0.)+length(max(d,0.));}
float sdTri(vec3 p,vec3 a,vec3 b,vec3 c){
    vec3 ba=b-a, pa=p-a, cb=c-b, pb=p-b, ac=a-c, pc=p-c;
    vec3 n=cross(ba,ac);
    return sqrt((sign(dot(cross(ba,n),pa))+sign(dot(cross(cb,n),pb))+sign(dot(cross(ac,n),pc))<2.)?
        min(min(dot2(ba*clamp(dot(ba,pa)/dot2(ba),0.,1.)-pa),
                dot2(cb*clamp(dot(cb,pb)/dot2(cb),0.,1.)-pb)),
            dot2(ac*clamp(dot(ac,pc)/dot2(ac),0.,1.)-pc))
        :dot(n,pa)*dot(n,pa)/dot2(n));
}

/* ---------- TIE SDF ---------- */
Hit sdWings(vec3 p){
    p.xy=abs(p.xy); p.z=abs(p.z)-2.3;
    return Hit(min(sdTri(p,vec3(0),vec3(2,3,0),vec3(-2,3,0)),
                   sdTri(p,vec3(0),vec3(3.3,0,0),vec3(2,3,0)))-.03,2);
}
Hit sdTie(vec3 p){
    p = p.zyx - vec3(10,0,0);
    Hit h = sdWings(p); if(h.d>2.5) return h;

    vec3 op=p; p.xy=abs(p.xy); p.z=abs(p.z)-2.3;
    float f,d=0.;
    if((f=abs(p.y))<.1) d=.03+step(f,.025)*.02;
    else if((f=abs(p.y-p.x*1.5))<.15) d=.03+step(f,.025)*.02;
    else if(abs(p.y-3.)<.1) d=.03;
    else if(abs(p.x-3.3+p.y*.43)<.1) d=.03;
    if(d>0.){ h.d-=d; h.id=1; }

    d=min(sdHex(p,vec2(.7,.06)),sdHex(p,vec2(.5,.12)));
    d=min(d,sdCyl(op,vec2(mix(.21,.23,step(p.y,.04)),2.3)));
    p.z=abs(p.z+.8)-.5;
    f=sdCyl(p,vec2(mix(.21,.33,(p.z+.33)/.48),.24));
    p.x-=.25; p.z+=.02;
    d=min(d,max(f,-sdBox(p,vec3(.1,.4,.08))));
    p=op; p.yz=abs(p.yz);
    h.d=min(h.d, min(d, sdTri(p,vec3(0),vec3(0,.8,0),vec3(0,0,2))-.05));
    f=step(.75,p.y);
    h.d=min(h.d, length(op)-.9-.02*(f+step(p.y,.03)+f*step(p.z,.1)));
    p=op; p.x+=.27; p.yz=opModPolar(p.yz,8.,.4);
    h.d=min(h.d, max(length(p)-.7, sdPlane(p+vec3(.77,0,0),vec3(vec2(-1,0)*rot(.5),0))));
    h.d=min(h.d, max(length(p)-.71,.45-length(p.yz)));
    p=op; p.x+=.7; p.y+=.6; p.z=abs(p.z)-.2;
    h.d=min(h.d, sdCyl(p.zyx,vec2(.05,.2)));
    return h;
}

// Achieving animaiton here
vec3 tiePos(vec3 p, Tie tie, float t)
{
    p = p - tie.position;
    float x = cos(t * tie.XOffset);
	p += vec3(x, cos(t * tie.YOffset), sin(t * tie.ZOffset)); // Set these parameters to achieve different animation
	p.xy *= rot(x * -.1); // Slight rotation of the xy plane to achieve a "tilt-in-flight feel"
    return p;
}

Hit tieDistance(vec3 p, Tie tie, float t){
    return sdTie( tiePos(p, tie, t) );
}

Hit mapAll(vec3 p){
    Hit best; best.d = 1e5; best.id = -1;
    for(int i=0;i<TIE_COUNT;i++){
        Hit h = tieDistance(p, ties[i], T);
        if(h.d < best.d) best = h;
    }
    return best;
}

vec3 TIENormal(vec3 p)
{
    const float e=.001;
    return normalize(vec3(
        mapAll(p+vec3(e,0,0)).d-mapAll(p-vec3(e,0,0)).d,
        mapAll(p+vec3(0,e,0)).d-mapAll(p-vec3(0,e,0)).d,
        mapAll(p+vec3(0,0,e)).d-mapAll(p-vec3(0,0,e)).d
    ));
}

/* ---------- Ray march ---------- */
Hit trace(vec3 ro,vec3 rd,out float tHit){
    float t=0.; Hit h;
    for(int i=0;i<120;i++){
        vec3 p=ro+rd*t;
        h=mapAll(p);
        if(abs(h.d)<.0015||t>600.) break;
        t+=h.d;
    }
    tHit = t;
    return h;
}

/* ---------- Base color ---------- */
void getTieColor(int id, out vec3 baseCol){
    baseCol = (id==2) ? vec3(0.08) : vec3(0.25);   // Wing dark gray / rest light gray
}

/* ---------- Camera helpers ---------- */
vec3 getRayDir(vec3 ro,vec3 la,vec2 uv){
    vec3 f=normalize(la-ro);
    vec3 r=normalize(cross(vec3(0,1,0),f));
    vec3 u=cross(f,r);
    float FOV=1.2;
    return normalize(f+uv.x*r*FOV+uv.y*u*FOV);
}

/* ---------- Main ---------- */
void mainImage(out vec4 fragColor,in vec2 fragCoord){

    ties[0] = Tie(vec3(-4,0, 8), 0.7,1.0,1.1);
    ties[1] = Tie(vec3( 3,1,-3), 0.6,0.9,1.2);


    
    T = iTime;

    vec3 ro = vec3(4.,.2,-8.);
    vec3 lookAt = vec3(0,0,6);

    vec2 uv = (fragCoord - 0.5*iResolution.xy)/iResolution.y;
    vec3 rd = getRayDir(ro,lookAt,uv);

    float hitDist;
    Hit h = trace(ro,rd,hitDist);

    vec3 col = (hitDist > 600.) ? vec3(.8,.9,1) : vec3(0);
    if(hitDist <= 600.) getTieColor(h.id, col);

    fragColor = vec4(pow(col, vec3(.4545)), 1.0); // γ
}
```

