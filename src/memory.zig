const std = @import("std");

const GameMemory = struct {
    memory: []u8,
    allocator: std.mem.Allocator,
};

pub fn InitMemory(sizeInBytes: usize) !GameMemory {
    const bytes = try std.heap.page_allocator.alloc(u8, sizeInBytes);
    var fixedBufferAllocator = std.heap.FixedBufferAllocator.init(bytes);
    return GameMemory{
        .memory = bytes,
        .allocator = fixedBufferAllocator.allocator(),
    };
}
