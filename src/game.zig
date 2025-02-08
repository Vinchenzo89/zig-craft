const std = @import("std");
const render = @import("renderer.zig");
const maths = @import("maths.zig");

pub const Entity = struct {
    id: usize,
    pos: maths.Vector3f,
    size: maths.Vector3f,
};

pub const GameState = struct {};

// colors
const TileColor = render.Color3f{
    .r = 0.24,
    .g = 0.24,
    .b = 0.24,
};
const UnitColor = render.Color3f{
    .r = 1.0,
    .g = 0.8,
    .b = 0.1,
};

pub fn UpdateAndRender(renderer: *render.Renderer) !void {
    // reset the renderer
    renderer.*.ops.clearRetainingCapacity();

    // clear screen works
    try renderer.ops.append(render.RenderOp{
        .ClearScreen = render.Color3f{
            .r = 0.18,
            .g = 0.18,
            .b = 0.18,
        },
    });

    const tile_dim = 0.05;
    const tile_map_dim = 100.0;
    const tile_x_anchor = -1.0 * (tile_dim * tile_map_dim) / 2.0;
    const tile_y_anchor = 1.0 * (tile_dim * tile_map_dim) / 2.0;
    // const tiles: [tile_map_dim][tile_map_dim]Entity = undefined;
    for (0..tile_map_dim) |j| {
        for (0..tile_map_dim) |i| {
            const xi: f32 = @floatFromInt(i);
            const yi: f32 = @floatFromInt(j);
            const x: f32 = tile_x_anchor + (2.0 * tile_dim * xi);
            const y: f32 = tile_y_anchor - (2.0 * tile_dim * yi);
            try renderer.ops.append(render.RenderOp{
                .DrawQuad = render.Quad{
                    .pos = maths.Vector3f{
                        .x = x,
                        .y = y,
                        .z = 0.0,
                    },
                    .scale = maths.Vector3f{
                        .x = tile_dim - 0.003,
                        .y = tile_dim - 0.003,
                        .z = 1.0,
                    },
                    .color = TileColor,
                },
            });
        }
    }

    // render structures
    try renderer.ops.append(render.RenderOp{ .DrawQuad = render.Quad{
        .pos = maths.Vector3f{
            .x = -0.25,
            .y = 0.25,
            .z = 0.0,
        },
        .scale = maths.Vector3f{
            .x = 0.2,
            .y = 0.2,
            .z = 1.0,
        },
        .color = UnitColor,
    } });
}
