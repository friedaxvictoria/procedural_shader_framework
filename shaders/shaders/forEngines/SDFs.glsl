// Signed distance functions for different shapes
float sdSphere( vec3 position, float radius )
{
  return length(position)-radius;
}

float sdRoundBox( vec3 p, vec3 b, float r )
{
  vec3 q = abs(p) - b + r;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}

// radius.x is the major radius, radius.y is the minor radius
float sdTorus( vec3 p, vec2 radius )
{
    // length(p.xy) - radius.x measures how far this point is from the torus ring center in the XY-plane.
  vec2 q = vec2(length(p.xy)-radius.x,p.z);
  return length(q)-radius.y;
}