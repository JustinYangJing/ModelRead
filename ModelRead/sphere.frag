#version 300 es
precision highp float;
precision highp int;
precision highp sampler2D;

uniform sampler2D texture_diffuse1;
uniform sampler2D texture_diffuse2;
uniform sampler2D texture_diffuse3;
uniform sampler2D texture_diffuse4;
uniform sampler2D texture_specular1;
uniform sampler2D texture_specular2;
uniform sampler2D texture_specular3;
uniform sampler2D texture_specular4;

out vec4 FragColor;

in vec2 TexCoords;


void main()
{
//    FragColor = texture(texture_diffuse1, TexCoords);
    FragColor = vec4(0.3078, 0.45294, 0.894117, 1.0);
}
