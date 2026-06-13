import Foundation
import Metal

struct PaintingFileHeader {
    static let magic: [UInt8] = [0x54, 0x52, 0x50, 0x31] // "TRP1"
    static let version: UInt32 = 1

    var canvasWidth: UInt32
    var canvasHeight: UInt32
    var layerCount: UInt32
    var canvasPresetHash: UInt32
    var metadataOffset: UInt64
}

struct PaintingFileManager: Sendable {
    static func save(
        volumeBuffer: MTLBuffer,
        canvasWidth: Int,
        canvasHeight: Int,
        to url: URL
    ) throws {
        var data = Data()

        data.append(contentsOf: PaintingFileHeader.magic)
        data.append(UInt32(PaintingFileHeader.version))
        data.append(UInt32(canvasWidth))
        data.append(UInt32(canvasHeight))
        data.append(UInt32(VolumeLayer.layerCount))
        data.append(UInt32(0)) // canvasPresetHash
        data.append(UInt64(0)) // metadataOffset (filled later)
        data.append(contentsOf: [UInt8](repeating: 0, count: 32)) // reserved

        let volumeSize = canvasWidth * canvasHeight * VolumeLayer.layerCount * MemoryLayout<VolumeLayer>.stride
        let ptr = volumeBuffer.contents()
        data.append(Data(bytes: ptr, count: volumeSize))

        let metadataStart = data.count
        let metadata: [String: Any] = [
            "version": 1,
            "created": ISO8601DateFormatter().string(from: Date()),
            "canvasWidth": canvasWidth,
            "canvasHeight": canvasHeight
        ]
        let jsonData = try JSONSerialization.data(withJSONObject: metadata)
        data.append(jsonData)

        data.withUnsafeMutableBytes { raw in
            let headerPtr = raw.baseAddress!.advanced(by: 24)
            headerPtr.assumingMemoryBound(to: UInt64.self).pointee = UInt64(metadataStart)
        }

        try data.write(to: url)
    }

    static func load(
        from url: URL,
        into volumeBuffer: MTLBuffer,
        canvasWidth: Int,
        canvasHeight: Int
    ) throws {
        let data = try Data(contentsOf: url)

        guard data.count >= 64 else {
            throw PaintingFileError.invalidFormat
        }

        let magic = [UInt8](data[0..<4])
        guard magic == PaintingFileHeader.magic else {
            throw PaintingFileError.invalidMagic
        }

        let volumeOffset = 64
        let volumeSize = canvasWidth * canvasHeight * VolumeLayer.layerCount * MemoryLayout<VolumeLayer>.stride

        guard data.count >= volumeOffset + volumeSize else {
            throw PaintingFileError.truncated
        }

        data.withUnsafeBytes { raw in
            let src = raw.baseAddress!.advanced(by: volumeOffset)
            memcpy(volumeBuffer.contents(), src, volumeSize)
        }
    }

    enum PaintingFileError: Error {
        case invalidFormat
        case invalidMagic
        case truncated
    }
}

private extension Data {
    mutating func append(_ value: UInt32) {
        var v = value
        append(Data(bytes: &v, count: 4))
    }
    mutating func append(_ value: UInt64) {
        var v = value
        append(Data(bytes: &v, count: 8))
    }
}
