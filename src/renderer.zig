const std = @import("std");
const maths = @import("maths.zig");

pub const Color3f = struct {
    r: f32,
    g: f32,
    b: f32,
};

pub const Quad = struct {
    pos: maths.Vector3f,
    scale: maths.Vector3f,
    color: Color3f,
};

pub const RenderOp = union(enum) {
    ClearScreen: Color3f,
    DrawQuad: Quad,
};

pub const Renderer = struct {
    ops: std.ArrayList(RenderOp) = undefined,

    pub fn init(allocator: std.mem.Allocator) Renderer {
        return Renderer{
            .ops = std.ArrayList(RenderOp).init(allocator),
        };
    }
};
