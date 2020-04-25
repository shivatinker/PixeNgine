//
//  Shaders.metal
//  testgame
//
//  Created by Andrii Zinoviev on 08.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

// File for Metal kernel and shader functions

#include <metal_stdlib>
#include <simd/simd.h>

// Including header shared between this Metal shader code and Swift/C code executing Metal API commands
#import "Metal/ShaderTypes.h"

using namespace metal;

typedef struct
{
    float3 position [[attribute(VertexAttributePosition)]];
    float2 texcoord [[attribute(VertexAttributeTexcoord)]];
} Vertex;

typedef struct
{
    float4 position [[position]];
    float2 texcoord;
} ColorInOut;

vertex ColorInOut vertex_basic(Vertex in [[stage_in]],
                               constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]])
{
    ColorInOut out;

    float4 position = uniforms.projectionMatrix * uniforms.modelViewMatrix * float4(in.position, 1.0);
    out.position = position;
    out.texcoord = in.texcoord;

    return out;
}

fragment float4 fragment_basic(ColorInOut in [[stage_in]],
                               texture2d<float> texture [[texture(TextureIndexColor)]])
{
    constexpr sampler colorSampler(filter::nearest);

    float4 colorSample = texture.sample(colorSampler, in.texcoord.xy);
    return colorSample;
}
