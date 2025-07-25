//
//  MandelbrotRenderer.swift
//  MetalComputeDemo
//
//  Created by Ishmael Sessions on 7/25/25.
//


import Foundation
import Metal
import CoreGraphics
import simd

class MandelbrotRenderer {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let pipeline: MTLComputePipelineState

    init() {
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device.makeCommandQueue()!
        let library = device.makeDefaultLibrary()!
        let function = library.makeFunction(name: "mandelbrot")!
        pipeline = try! device.makeComputePipelineState(function: function)
    }

    func generateImage(width: Int, height: Int) -> CGImage {
        let count = width * height
        let buffer = device.makeBuffer(length: count * MemoryLayout<UInt32>.size, options: .storageModeShared)!
        var sizeVector = vector_uint2(UInt32(width), UInt32(height))

        let commandBuffer = commandQueue.makeCommandBuffer()!
        let encoder = commandBuffer.makeComputeCommandEncoder()!
        encoder.setComputePipelineState(pipeline)
        encoder.setBuffer(buffer, offset: 0, index: 0)
        encoder.setBytes(&sizeVector, length: MemoryLayout<vector_uint2>.size, index: 1)

        let threadsPerGroup = MTLSize(width: 16, height: 16, depth: 1)
        let threadgroups = MTLSize(width: (width + 15) / 16, height: (height + 15) / 16, depth: 1)

        encoder.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threadsPerGroup)
        encoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        // Convert iteration counts to grayscale
        let output = buffer.contents().bindMemory(to: UInt32.self, capacity: count)
        var pixels = [UInt8](repeating: 0, count: count)

        for i in 0..<count {
            let iter = min(output[i], 255)
            pixels[i] = UInt8(255 - iter) // Invert for contrast
        }

        let provider = CGDataProvider(data: Data(pixels) as CFData)!
        let colorSpace = CGColorSpaceCreateDeviceGray()
        return CGImage(width: width,
                       height: height,
                       bitsPerComponent: 8,
                       bitsPerPixel: 8,
                       bytesPerRow: width,
                       space: colorSpace,
                       bitmapInfo: CGBitmapInfo(rawValue: 0),
                       provider: provider,
                       decode: nil,
                       shouldInterpolate: false,
                       intent: .defaultIntent)!
    }
}
