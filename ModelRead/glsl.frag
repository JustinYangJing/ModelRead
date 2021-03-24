#version 300 es
precision highp float;
precision highp int;
precision highp sampler2D;
out vec4 FragColor;

uniform sampler2D tex;

in vec2 texCoord;

void main()
{
    FragColor = vec4(1.0,0.3,0.4, 0.0);
//    FragColor = texture(tex,texCoord);
}
