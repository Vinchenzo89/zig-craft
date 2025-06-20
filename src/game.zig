const std = @import("std");
const render = @import("renderer.zig");
const maths = @import("maths.zig");
const mem = @import("memory.zig");

pub const Entity = struct {
    id: usize,
    pos: maths.Vector3f,
    scale: maths.Vector3f,
};

pub const SeekBehavior: type = struct {
    agentId: usize,
    targetId: usize,
    speed: f32,
};

pub const EvadeBehavior: type = struct {
    agentId: usize,
    targetId: usize,
    speed: f32,
};

pub const GameState = struct {
    initialized: bool,
    entities: std.ArrayList(Entity) = undefined,
    seekers: [2]?SeekBehavior,
    evaders: [2]?EvadeBehavior,

    pub fn init(allocator: std.mem.Allocator) GameState {
        return GameState{
            .initialized = false,
            .entities = std.ArrayList(Entity).init(allocator),
            .seekers = .{ null, null },
            .evaders = .{ null, null },
        };
    }
};

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

pub fn UpdateAndRender(state: *GameState, renderer: *render.Renderer) !void {
    if (!state.initialized) {
        state.initialized = true;

        var nextId = state.entities.items.len;
        try state.entities.append(Entity{
            .id = nextId,
            .pos = maths.Vector3f{
                .x = 0.25,
                .y = 0.75,
                .z = 0.0,
            },
            .scale = maths.Vector3f{
                .x = 1.0,
                .y = 1.0,
                .z = 1.0,
            },
        });

        nextId = state.entities.items.len;
        try state.entities.append(Entity{
            .id = nextId,
            .pos = maths.Vector3f{
                .x = 0.25,
                .y = 0.75,
                .z = 0.0,
            },
            .scale = maths.Vector3f{
                .x = 1.0,
                .y = 1.0,
                .z = 1.0,
            },
        });
    }

    for (state.seekers) |value| {
        if (value) |*it| {
            var agent = &state.entities.items[it.agentId];
            const target = &state.entities.items[it.targetId];

            var dir = maths.v3f_sub(target.pos, agent.pos);
            dir = maths.v3f_normalize(dir);

            const ddp = maths.v3f_scale(dir, it.speed);
            agent.pos = maths.v3f_add(agent.pos, ddp);
        }
    }

    for (state.evaders) |value| {
        if (value) |*it| {
            var agent = &state.entities.items[it.agentId];
            const target = &state.entities.items[it.targetId];

            var dir = maths.v3f_sub(agent.pos, target.pos);
            dir = maths.v3f_normalize(dir);

            const ddp = maths.v3f_scale(dir, it.speed);
            agent.pos = maths.v3f_add(agent.pos, ddp);
        }
    }

    // reset the renderer
    renderer.*.ops.clearRetainingCapacity();

    // clear screen
    try renderer.ops.append(render.RenderOp{
        .ClearScreen = render.Color3f{
            .r = 0.18,
            .g = 0.18,
            .b = 0.18,
        },
    });

    // render structures
    try renderer.ops.append(render.RenderOp{
        .DrawQuad = render.Quad{
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
        },
    });

    try renderer.ops.append(render.RenderOp{
        .DrawText = render.Text.fromConst(
            "From the Game Code",
            maths.Vector3f{
                .x = -0.5,
                .y = -0.5,
                .z = 0.0,
            },
            maths.Vector3f{
                .x = 1.0,
                .y = 1.0,
                .z = 1.0,
            },
            render.Color3f{
                .r = 0.0,
                .g = 1.0,
                .b = 0.0,
            },
        ),
    });

    try renderer.ops.append(render.RenderOp{
        .DrawText = render.Text.fromConst(
            "This is way more than 32 characters so lets see",
            maths.Vector3f{
                .x = -0.5,
                .y = 0.5,
                .z = 0.0,
            },
            maths.Vector3f{
                .x = 1.0,
                .y = 1.0,
                .z = 1.0,
            },
            render.Color3f{
                .r = 1.0,
                .g = 0.0,
                .b = 0.0,
            },
        ),
    });
}
