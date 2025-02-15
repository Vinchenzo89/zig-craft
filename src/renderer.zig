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

pub const MAX_TEXT: usize = 32;
pub const Text = struct {
    pos: maths.Vector3f,
    scale: maths.Vector3f,
    color: Color3f,
    text: [MAX_TEXT:0]u8,

    pub fn fromConst(
        text: [:0]const u8,
        pos: maths.Vector3f,
        scale: maths.Vector3f,
        color: Color3f,
    ) Text {
        var result = Text{
            .text = undefined,
            .pos = pos,
            .scale = scale,
            .color = color,
        };
        for (0..MAX_TEXT) |i| {
            result.text[i] = 0;
            if (i < text.len) {
                result.text[i] = text[i];
            }
        }
        return result;
    }
};

pub const RenderOp = union(enum) {
    ClearScreen: Color3f,
    DrawQuad: Quad,
    DrawText: Text,
};

pub const Renderer = struct {
    ops: std.ArrayList(RenderOp) = undefined,

    pub fn init(allocator: std.mem.Allocator) Renderer {
        return Renderer{
            .ops = std.ArrayList(RenderOp).init(allocator),
        };
    }
};
