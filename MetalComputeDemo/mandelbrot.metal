//
//  mandelbrot.metal
//  MetalComputeDemo
//
//  Created by Ishmael Sessions on 7/25/25.
//

#include <metal_stdlib>
using namespace metal;

#include <metal_stdlib>
using namespace metal;

kernel void mandelbrot(device uint *output [[ buffer(0) ]],
                       constant uint2 &size [[ buffer(1) ]],
                       uint2 gid [[ thread_position_in_grid ]]) {
    if (gid.x >= size.x || gid.y >= size.y) return;

    float2 c;
    c.x = (float(gid.x) / float(size.x)) * 3.5 - 2.5; // [-2.5, 1]
    c.y = (float(gid.y) / float(size.y)) * 2.0 - 1.0; // [-1.0, 1.0]

    float2 z = float2(0.0);
    uint maxIter = 1000;
    uint i = 0;

    while (i < maxIter && dot(z, z) < 4.0) {
        float x = z.x * z.x - z.y * z.y + c.x;
        z.y = 2.0 * z.x * z.y + c.y;
        z.x = x;
        i++;
    }

    output[gid.y * size.x + gid.x] = i;
}

