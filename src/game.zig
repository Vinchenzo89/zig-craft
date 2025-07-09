const std = @import("std");
const render = @import("renderer.zig");
const maths = @import("maths.zig");
const mem = @import("memory.zig");

pub const Entity = struct {
    id: usize,
    pos: maths.Vector3f,
    scale: maths.Vector3f,

    dp: maths.Vector3f, // velocity
    ddp: maths.Vector3f, // acceleration

    pub fn init(id: usize) Entity {
        return Entity{
            .id = id,
            .pos = maths.Vector3f{
                .x = 0.0,
                .y = 0.0,
                .z = 0.0,
            },
            .scale = maths.Vector3f{
                .x = 1.0,
                .y = 1.0,
                .z = 1.0,
            },
            .dp = maths.Vector3f{
                .x = 0.0,
                .y = 0.0,
                .z = 1.0,
            },
            .ddp = maths.Vector3f{
                .x = 0.0,
                .y = 0.0,
                .z = 0.0,
            },
        };
    }
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

const MAX_FRAME_DT = 1.0 / 60.0;

pub const GameState = struct {
    initialized: bool,
    frame_dt: f32, // detla time in seconds
    entity_count: usize, // not the capacity of the array but count added this frame
    entities: std.ArrayList(Entity) = undefined,

    pub fn init(allocator: std.mem.Allocator) GameState {
        return GameState{
            .initialized = false,
            .frame_dt = MAX_FRAME_DT, // fake for now
            .entity_count = 0,
            .entities = std.ArrayList(Entity).init(allocator),
        };
    }

    pub fn push_entity(self: *GameState, entity: Entity) !usize {
        try self.entities.append(entity);
        self.entity_count += 1;
        return self.entity_count;
    }

    pub fn reset(self: *GameState) !void {
        try self.entities.clearRetainingCapacity();
        self.entity_count = 0;
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

        {
            const nextId = state.entities.items.len;
            var e = Entity.init(nextId);
            e.pos = maths.Vector3f{
                .x = 0.25,
                .y = 0.75,
                .z = 0.0,
            };
            e.scale = maths.Vector3f{
                .x = 0.1,
                .y = 0.1,
                .z = 1.0,
            };
            e.dp = maths.Vector3f{
                .x = -0.03,
                .y = -0.03,
                .z = 0.0,
            };
            _ = try state.push_entity(e);
        }

        {
            const nextId = state.entities.items.len;
            var e = Entity.init(nextId);
            e.pos = maths.Vector3f{
                .x = -0.25,
                .y = -0.75,
                .z = 0.0,
            };
            e.scale = maths.Vector3f{
                .x = 0.25,
                .y = 0.15,
                .z = 1.0,
            };
            _ = try state.push_entity(e);
        }
    }

    // for (state.seekers) |value| {
    //     if (value) |*it| {
    //         var agent = &state.entities.items[it.agentId];
    //         const target = &state.entities.items[it.targetId];

    //         var dir = maths.v3f_sub(target.pos, agent.pos);
    //         dir = maths.v3f_normalize(dir);

    //         const ddp = maths.v3f_scale(dir, it.speed);
    //         agent.pos = maths.v3f_add(agent.pos, ddp);
    //     }
    // }

    // for (state.evaders) |value| {
    //     if (value) |*it| {
    //         var agent = &state.entities.items[it.agentId];
    //         const target = &state.entities.items[it.targetId];

    //         var dir = maths.v3f_sub(agent.pos, target.pos);
    //         dir = maths.v3f_normalize(dir);

    //         const ddp = maths.v3f_scale(dir, it.speed);
    //         agent.pos = maths.v3f_add(agent.pos, ddp);
    //     }
    // }

    for (state.entities.items) |*e| {
        const dp = maths.v3f_scale(e.dp, state.frame_dt);
        e.pos = maths.v3f_add(e.pos, dp);
    }

    // reset the renderer
    renderer.ops.clearRetainingCapacity();

    // clear screen
    try renderer.ops.append(render.RenderOp{
        .ClearScreen = render.Color3f{
            .r = 0.18,
            .g = 0.18,
            .b = 0.18,
        },
    });

    for (0..state.entity_count) |id| {
        const e = &state.entities.items[id];
        try renderer.ops.append(render.RenderOp{
            .DrawQuad = render.Quad{
                .pos = e.pos,
                .scale = e.scale,
                .color = UnitColor,
            },
        });
    }

    // render structures
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
