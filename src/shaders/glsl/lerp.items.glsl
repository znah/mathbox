uniform float sampleRatio;

// External
vec4 sampleData(vec4 xyzi);

vec4 lerpItems(vec4 xyzi) {
  float x = xyzi.w * sampleRatio;
  float i = floor(x);
  float f = x - i;
    
  vec4 xyzi1 = vec4(xyzi.xyz, i);
  vec4 xyzi2 = vec4(xyzi.xyz, i + 1.0);
  
  vec4 a = sampleData(xyzi1);
  vec4 b = sampleData(xyzi2);

  return mix(a, b, f);
}
