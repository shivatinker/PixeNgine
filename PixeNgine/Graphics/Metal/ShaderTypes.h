//
//  ShaderTypes.h
//  testgame
//
//  Created by Andrii Zinoviev on 08.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

//
//  Header containing types and enum constants shared between Metal shaders and Swift/ObjC source
//
#ifndef ShaderTypes_h
#define ShaderTypes_h

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger metal::int32_t
#else
#import <Foundation/Foundation.h>
#endif

#include <simd/simd.h>

typedef NS_ENUM(NSInteger, BufferIndex)
{
    BufferIndexPosition = 0,
    BufferIndexTexcoord = 1,
    BufferIndexUniforms = 2
};

typedef NS_ENUM(NSInteger, VertexAttribute)
{
    VertexAttributePosition  = 0,
    VertexAttributeTexcoord  = 1,
    VertexAttributeUniforms = 2
};

typedef NS_ENUM(NSInteger, LightsFragmentBuffers)
{
    LightsFragmentBuffersLights = 0,
    LightsFragmentBuffersUniforms = 1
};

typedef NS_ENUM(NSInteger, TextureIndex)
{
    TextureIndexColor = 0,
};

typedef struct
{
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 modelViewMatrix;
    float opacity;
    float brightness;
} Uniforms;

typedef struct
{
    vector_float2 pos;
    float clipRadius;
    float amount;
    vector_float4 color;
} Light;

typedef struct {
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 modelViewMatrix;
} LightsVertexUniforms;

typedef struct {
    int lightsCount;
    vector_float4 ambientColor;
} LightsFragmentUniforms;

#endif /* ShaderTypes_h */

