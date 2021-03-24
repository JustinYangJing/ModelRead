#version 300 es
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 texcoord;
//layout (location = 1) in mat4 model;

out vec3 fColor;
out vec2 texCoord;
uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;
void main()
{
    gl_Position = projection * view * model * vec4(aPos,1.0);
    texCoord = texcoord.xy;
}
