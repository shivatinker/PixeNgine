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
} VertexOut;

vertex VertexOut vertex_basic(Vertex in [[stage_in]],
                               constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]])
{
    VertexOut out;

    float4 position = uniforms.projectionMatrix * uniforms.modelViewMatrix * float4(in.position, 1.0);
    out.position = position;
    out.texcoord = in.texcoord;

    return out;
}

fragment float4 fragment_basic(VertexOut in [[stage_in]],
                               texture2d<float> texture [[texture(TextureIndexColor)]],
                               constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]])
{
    constexpr sampler colorSampler(filter::nearest);

    float4 colorSample = texture.sample(colorSampler, in.texcoord.xy);
    colorSample.rgb *= uniforms.brightness;
    colorSample.a *= uniforms.opacity;
    return colorSample;
}

// Light shaders

typedef struct
{
    float3 position [[attribute(VertexAttributePosition)]];
} LVertex;

typedef struct
{
    float4 position [[position]];
    float2 worldPosition;
} LVertexOut;

vertex LVertexOut vertex_lights(LVertex in [[stage_in]],
                                constant LightsVertexUniforms &uniforms [[buffer(BufferIndexUniforms)]])
{
    LVertexOut out;

    out.position = (uniforms.projectionMatrix * uniforms.modelViewMatrix * float4(in.position, 1.0));
    out.worldPosition = (uniforms.modelViewMatrix * float4(in.position, 1.0)).xy;

    return out;
}

fragment float4 fragment_lights(
                                LVertexOut in [[stage_in]],
                                constant Light* lights [[buffer(LightsFragmentBuffersLights)]],
                                constant LightsFragmentUniforms &uniforms [[buffer(LightsFragmentBuffersUniforms)]]){
    int count = uniforms.light_count;
    float4 out = float4(0, 0, 0, 1);
    for(int i = 0; i < count; i++){
        Light cur = lights[i];
        float dist = length((float2)(in.worldPosition - cur.pos));
        if(dist > cur.radius)
            continue;
        float intensity = saturate(cur.color.a * cur.amount / (0.01 + 0.01 * dist + 0.006 * dist * dist));
        float4 lcol = float4(cur.color.rgb, 0) * intensity;
        out += lcol;
    }
    return out;
}

// Composition shaders

typedef struct
{
    float3 position [[attribute(VertexAttributePosition)]];
} CVertex;

typedef struct
{
    float4 position [[position]];
    float2 texcoords;
} CVertexOut;

vertex CVertexOut vertex_composition(CVertex in [[stage_in]])
{
    CVertexOut out;
    out.position = float4(in.position, 1.0);
    out.texcoords = (float2(in.position.x, in.position.y * -1) + float2(1, 1)) / 2;
    return out;
}

fragment float4 fragment_composition(CVertexOut in [[stage_in]],
                                texture2d<float> entities [[texture(1)]],
                                texture2d<float> lights [[texture(2)]]){
    constexpr sampler colorSampler(filter::nearest);
    float4 entitiesColor = entities.sample(colorSampler, in.texcoords);
    float4 lightsColor = lights.sample(colorSampler, in.texcoords);
    return entitiesColor + entitiesColor * lightsColor * 3.0;
}
