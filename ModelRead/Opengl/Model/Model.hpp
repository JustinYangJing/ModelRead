//
//  Model.hpp
//  AssimpTest
//
//  Created by JustinYang on 2019/11/21.
//  Copyright © 2019 JustinYang. All rights reserved.
//

#ifndef Model_hpp
#define Model_hpp

#include <iostream>
#include "Mesh.hpp"

#include <assimp/Importer.hpp>
#include <assimp/scene.h>
#include <assimp/postprocess.h>
//#include <vector>
//
//#include "shader.hpp"
//#include <glad/glad.h>
//#include <glm/glm.hpp>
//#include <glm/gtc/matrix_transform.hpp>

class Model{
public:
    vector<Texture> textures_loaded;
    vector <Mesh> meshes;
    string directory;
    bool gammaCorrection;
    
    Model(string const &path, bool gamma = false):gammaCorrection(gamma){
        loadModel(path);
    }
    void Draw(Shader shader);
private:
    void loadModel(string const &path, bool gamma = false);
    void processNode(aiNode *node, const aiScene *scene);
    Mesh processMesh(aiMesh *mesh, const aiScene *scene);
    vector<Texture> loadMaterialTextures(aiMaterial *mat, aiTextureType type, string typeName);
};

#endif /* Model_hpp */
