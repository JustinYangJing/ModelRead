//
//  Mesh.cpp
//  AssimpTest
//
//  Created by JustinYang on 2019/11/20.
//  Copyright © 2019 JustinYang. All rights reserved.
//

#include "Mesh.hpp"
#include <stddef.h>
Mesh::Mesh(vector<Vertex> vertices, vector<unsigned int> indices, vector<Texture> textures){
    this->vertices = vertices;
    this->indices = indices;
    this->textures = textures;
    setupMesh();
}

void Mesh::setupMesh(){
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);
    glGenBuffers(1, &EBO);
    
    glBindVertexArray(VAO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, vertices.size()*sizeof(Vertex), &vertices[0],GL_STATIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size()*sizeof(unsigned int), &indices[0],GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0,3,GL_FLOAT, GL_FALSE, sizeof(Vertex),(void *)0);
    
    glEnableVertexAttribArray(1);
     glVertexAttribPointer(1,3,GL_FLOAT, GL_FALSE, sizeof(Vertex),(void *)offsetof(Vertex, Normal));
    
    glEnableVertexAttribArray(2);
    glVertexAttribPointer(2,2, GL_FLOAT, GL_FALSE, sizeof(Vertex),(void *)offsetof(Vertex, TexCoords));
    
    glEnableVertexAttribArray(3);
    glVertexAttribPointer(3,3,GL_FLOAT, GL_FALSE, sizeof(Vertex),(void *)offsetof(Vertex, Tangent));
    glEnableVertexAttribArray(4);
    glVertexAttribPointer(4,3,GL_FLOAT, GL_FALSE, sizeof(Vertex),(void *)offsetof(Vertex, Bitangent));
    
    glBindVertexArray(0);
}

void Mesh::Draw(Shader shader){
    unsigned int diffuseNr = 1;
    unsigned int specularNr = 1;
    unsigned int normalNr = 1;
    unsigned int heightNr = 1;
    unsigned int reflectNr = 1;
    for (unsigned int  i = 0; i < textures.size(); i ++) {
        glActiveTexture(GL_TEXTURE0 + i);
        string number;
        string name = textures[i].type;
        if (name == "texture_diffuse") {
            number = to_string(diffuseNr++);
        }else if(name == "texture_specular"){
            number = to_string(specularNr++);
        }else if(name == "texture_normal"){
            number = to_string(normalNr++);
        }else if(name == "texture_height"){
            number = to_string(heightNr++);
        }else if (name == "texture_reflect"){
            number = to_string(reflectNr++);
        }
        shader.use();
        shader.setFloat(name + number.c_str(), i);
//        std::cout<<name + number <<std::endl;
        glBindTexture(GL_TEXTURE_2D, textures[i].id);
    }
    
    
    glBindVertexArray(VAO);
    glDrawElements(GL_TRIANGLES, (int)indices.size(), GL_UNSIGNED_INT, 0);
    glBindVertexArray(0);
    
    glActiveTexture(GL_TEXTURE0);
}
