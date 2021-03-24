//
//  Mesh.hpp
//  AssimpTest
//
//  Created by JustinYang on 2019/11/20.
//  Copyright © 2019 JustinYang. All rights reserved.
//

#ifndef Mesh_hpp
#define Mesh_hpp
#include <iostream>
#include <vector>
#include "shader.hpp"
#include "glm/glm.hpp"
#include "glm/gtc/matrix_transform.hpp"

#include <assimp/Importer.hpp>
#include <assimp/scene.h>
#include <assimp/postprocess.h>
using namespace std;
struct Vertex{
    glm::vec3 Position;
    glm::vec3 Normal;
    glm::vec2 TexCoords;
    glm::vec3 Tangent;
    glm::vec3 Bitangent;
};

struct Texture{
    unsigned int id;
    string type;
    aiString path;
};

class Mesh{
public:
    vector<Vertex> vertices;
    vector<unsigned int> indices;
    vector<Texture> textures;
    unsigned int VAO;
    Mesh(vector<Vertex> vertices, vector<unsigned int> indices, vector<Texture> textures);
    void Draw(Shader shader);
private:
    unsigned int VBO, EBO;
    void setupMesh();
};

#endif /* Mesh_hpp */
