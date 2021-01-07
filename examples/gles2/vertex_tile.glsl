attribute vec4 coordUv;
attribute vec4 scaleRot;
attribute vec2 trans;

uniform vec2 size;
uniform mediump vec2 texSize;
uniform float prio;
uniform mediump int sw;

varying vec2 texcoord;

void main(void) {
  if(sw == 0){
    vec2 uv = coordUv.zw - (size / 64.0);

    float r = -(scaleRot.z / 10430.0);
    float s = sin(r);
    float c = cos(r);
    float sx = 4096.0 / scaleRot.x;
    float sy = 4096.0 / scaleRot.y;
    float sprio = scaleRot.w;
    float mult = step(prio, sprio) * step(sprio, prio);
    sx *= mult;
    sy *= mult;

    float m0 = sx * c;
    float m1 = sx * s;

    float m3 = sy * -s;
    float m4 = sy * c;

    float m6 = -(trans.x-(size.x/2.0)) / 32.0;
    float m7 = -(trans.y-(size.y/2.0)) / 32.0;

    mat3 transformation = mat3(m0, m1, 0.0, m3, m4, 0.0, m6, m7, 1.0);
    texcoord = (transformation * vec3(uv, 1.0)).xy;

    //transformation = mat3(1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 1.0);

    vec2 xy = (coordUv.xy / (size / 2.0) - 1.0) * vec2(1.0, -1.0);
    gl_Position = vec4(xy, 0.0, 1.0);
  } else {
    vec2 uv = coordUv.zw / texSize;
    texcoord = uv; 

    float r = (scaleRot.z / 10430.0);
    float s = sin(r);
    float c = cos(r);
    float sx = scaleRot.x / 4096.0;
    float sy = scaleRot.y / 4096.0;
    float sprio = scaleRot.w;
    float mult = step(prio, sprio) * step(sprio, prio);
    sx *= mult;
    sy *= mult;

    float m0 = sx * c;
    float m1 = sx * s;

    float m3 = sy * -s;
    float m4 = sy * c;

    float m6 = trans.x;
    float m7 = trans.y;

    mat3 transformation = mat3(m0, m1, 0.0, m3, m4, 0.0, m6, m7, 1.0);
    //transformation = mat3(1.0, 0.0, 0.0, 0.0, 1.0, 0.0, m6, m7, 1.0);

    vec3 transformed = transformation * vec3(coordUv.xy, 1.0);

    vec2 xy = (transformed.xy / (size / 2.0) - 1.0) * vec2(1.0, -1.0);
    gl_Position = vec4(xy, 0.0, 1.0);
  }

}