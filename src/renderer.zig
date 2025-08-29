const std = @import("std");
const maths = @import("maths.zig");
const rl = @import("raylib.zig");

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
    world_width: f32,
    world_height: f32,

    pub fn init(allocator: std.mem.Allocator, worldWidth: f32, worldHeight: f32) Renderer {
        return Renderer{
            .ops = std.ArrayList(RenderOp).init(allocator),
            .world_width = worldWidth,
            .world_height = worldHeight,
        };
    }

    pub fn executeRenderOps(self: *Renderer) void {
        for (self.ops.items) |r| {
            switch (r) {
                .ClearScreen => |color| {
                    rl.ClearBackground(rl.Color{
                        .r = @intFromFloat(color.r * 255),
                        .g = @intFromFloat(color.g * 255),
                        .b = @intFromFloat(color.b * 255),
                        .a = 255,
                    });
                },
                .DrawQuad => |quad| {
                    // Draw directly in world coordinates - Raylib camera handles the transformation
                    rl.DrawRectangle(
                        @intFromFloat(quad.pos.x - quad.scale.x / 2.0),
                        @intFromFloat(quad.pos.y - quad.scale.y / 2.0),
                        @intFromFloat(quad.scale.x),
                        @intFromFloat(quad.scale.y),
                        rl.Color{
                            .r = @intFromFloat(quad.color.r * 255),
                            .g = @intFromFloat(quad.color.g * 255),
                            .b = @intFromFloat(quad.color.b * 255),
                            .a = 255,
                        },
                    );
                },
                .DrawText => |text| {
                    // Draw directly in world coordinates - Raylib camera handles the transformation
                    const fontSize = @as(c_int, @intFromFloat(text.scale.y));

                    rl.DrawText(
                        &text.text,
                        @intFromFloat(text.pos.x),
                        @intFromFloat(text.pos.y),
                        fontSize,
                        rl.Color{
                            .r = @intFromFloat(text.color.r * 255),
                            .g = @intFromFloat(text.color.g * 255),
                            .b = @intFromFloat(text.color.b * 255),
                            .a = 255,
                        },
                    );
                },
            }
        }
    }
};
