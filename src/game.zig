const std = @import("std");
const render = @import("renderer.zig");
const maths = @import("maths.zig");
const mem = @import("memory.zig");

pub const Entity = struct {
    id: usize,

    transform: ?Transform,
    kinematics: ?Kinematics,

    pub fn new(id: usize) Entity {
        return Entity{
            .id = id,
            .transform = null,
            .kinematics = null,
        };
    }
};

pub const Transform = struct {
    pos: maths.Vector3f,
    scale: maths.Vector3f,
};

pub const Kinematics = struct {
    mass: f32,
    max_speed: f32,
    max_force: f32,
    dp: maths.Vector3f, // velocity
    ddp: maths.Vector3f, // acceleration
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

        // random
        // var prng = std.rand.DefaultPrng.init(blk: {
        //     var seed: u64 = undefined;
        //     try std.posix.getrandom(std.mem.asBytes(&seed));
        //     break :blk seed;
        // });
        // const rand = prng.random();

        {
            for (0..100) |i| {
                const nextId = state.entities.items.len;
                const max_speed = 0.1;
                const x = std.math.cos(@as(f32, @floatFromInt(i))) * 0.5;
                const y = std.math.sin(@as(f32, @floatFromInt(i))) * 0.5;
                const dx = std.math.cos(@as(f32, @floatFromInt(i))) * max_speed;
                const dy = std.math.sin(@as(f32, @floatFromInt(i))) * max_speed;
                var e = Entity.new(nextId);
                e.transform = Transform{
                    .pos = maths.Vector3f{ .x = x, .y = y, .z = 0.0 },
                    .scale = maths.Vector3f{ .x = 0.01, .y = 0.01, .z = 1.0 },
                };
                e.kinematics = Kinematics{
                    .dp = maths.Vector3f{ .x = dx, .y = dy, .z = 0.0 },
                    .ddp = maths.Vector3f{ .x = 0.0, .y = 0.0, .z = 0.0 },
                    .mass = 1.0,
                    .max_force = 1.0,
                    .max_speed = 50.0,
                };

                _ = try state.push_entity(e);
            }
        }

        {
            const nextId = state.entities.items.len;
            var e = Entity.new(nextId);
            e.transform = Transform{
                .pos = maths.Vector3f{ .x = -0.25, .y = -0.75, .z = 0.0 },
                .scale = maths.Vector3f{ .x = 0.25, .y = 0.15, .z = 1.0 },
            };
            _ = try state.push_entity(e);
        }
    }

    for (state.entities.items) |*e| {
        if (e.kinematics) |kin| {
            const tx = &e.transform.?; // everything should have a transform
            const dp = maths.v3f_scale(kin.dp, state.frame_dt);
            e.transform.?.pos = maths.v3f_add(tx.pos, dp);
        }
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
        const tx = e.transform.?;
        try renderer.ops.append(render.RenderOp{
            .DrawQuad = render.Quad{
                .pos = tx.pos,
                .scale = tx.scale,
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
