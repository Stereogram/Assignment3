#version 300 es

precision highp float;
in vec2 texCoordOut;
in vec3 v_position;
out vec4 o_fragColor;

uniform sampler2D texSampler;

void main()
{
    vec4 color = vec4(1.0, 1.0, 1.0, 1.0);
    color *=texture(texSampler, texCoordOut);
    
    o_fragColor = color;
}


