#version 300 es
precision highp float;
precision highp int;
precision highp sampler2D;
out vec4 FragColor;

uniform sampler2D tex;

in vec2 texCoord;

void main()
{
//    FragColor = vec4(0.3078, 0.45294, 0.894117, 1.0);
    vec4 tmpColor = texture(tex,texCoord);
    FragColor = vec4(tmpColor.b,tmpColor.g,tmpColor.r,tmpColor.a);
}
