const std = @import("std");
const render = @import("renderer.zig");
const maths = @import("maths.zig");
const mem = @import("memory.zig");

pub const Entity = struct {
    id: usize,

    etype: EntityType,
    transform: ?Transform,
    kinematics: ?Kinematics,

    factionBase: ?FactionBase,
    resourcePatch: ?ResourcePatch,

    pub fn new(id: usize, etype: EntityType) Entity {
        return Entity{
            .id = id,
            .etype = etype,
            .transform = null,
            .kinematics = null,
            .factionBase = null,
            .resourcePatch = null,
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

pub const EntityType = enum {
    NONE,
    BASE,
    AGENT,
    COUNT,
};

pub const FactionBase = struct {
    min: maths.Vector3f,
    max: maths.Vector3f,
};

pub const ResourceType = enum {
    NONE,
    IRON,
    AGRO,
    WOOD,
    GOLD,
    COUNT,
};
pub const ResourcePatch = struct {
    resource: ResourceType,
    quantiy: f32,
    dificulty: f32,
};
pub fn newResource(resource: ResourceType, quantity: f32, dificulty: f32) ResourcePatch {
    return ResourcePatch{
        .resource = resource,
        .quantiy = quantity,
        .dificulty = dificulty, // between 0 and 1
    };
}

const MAX_FRAME_DT = 1.0 / 60.0;

pub const GameState = struct {
    initialized: bool,
    frame_dt: f32, // detla time in seconds
    entity_count: usize, // not the capacity of the array but count added this frame
    entities: std.ArrayList(Entity) = undefined,

    world_dim: maths.Vector3f,

    pub fn init(allocator: std.mem.Allocator, world_width: f32, world_height: f32) GameState {
        return GameState{
            .initialized = false,
            .frame_dt = 0.0,
            .entity_count = 0,
            .entities = std.ArrayList(Entity).init(allocator),
            .world_dim = maths.v32_new(world_width, world_height, 0.0),
        };
    }

    pub fn push_entity(self: *GameState, entity: Entity) !usize {
        const id = self.entity_count;
        try self.entities.append(entity);
        self.entity_count += 1;
        return id;
    }

    pub fn reset(self: *GameState) !void {
        try self.entities.clearRetainingCapacity();
        self.entity_count = 0;
    }
};

pub const GameInput = struct {
    up_button: bool,
    down_button: bool,
    left_button: bool,
    right_button: bool,

    pub fn init() @This() {
        return .{
            .up_button = false,
            .down_button = false,
            .left_button = false,
            .right_button = false,
        };
    }
};

// colors
const TileColor = render.Color3f{
    .r = 0.40,
    .g = 0.30,
    .b = 0.30,
};
const UnitColor = render.Color3f{
    .r = 1.0,
    .g = 0.8,
    .b = 0.1,
};

pub fn UpdateAndRender(_: GameInput, state: *GameState, renderer: *render.Renderer) !void {
    if (!state.initialized) {
        state.initialized = true;

        {
            for (0..100) |i| {
                const nextId = state.entities.items.len;
                const speed = 20.0; // World units per second
                const radius = 25.0; // Spawn in a circle with radius 25 world units
                const x = std.math.cos(@as(f32, @floatFromInt(i))) * radius;
                const y = std.math.sin(@as(f32, @floatFromInt(i))) * radius;
                const dx = std.math.cos(@as(f32, @floatFromInt(i))) * speed;
                const dy = std.math.sin(@as(f32, @floatFromInt(i))) * speed;
                var e = Entity.new(nextId, EntityType.AGENT);
                e.transform = Transform{
                    .pos = maths.Vector3f{ .x = x, .y = y, .z = 0.0 },
                    .scale = maths.Vector3f{ .x = 1.0, .y = 1.0, .z = 1.0 }, // 1 world unit square
                };
                e.kinematics = Kinematics{
                    .dp = maths.Vector3f{ .x = dx, .y = dy, .z = 0.0 },
                    .ddp = maths.Vector3f{ .x = 0.0, .y = 0.0, .z = 0.0 },
                    .mass = 1.0,
                    .max_force = 1.0,
                    .max_speed = 5.0, // Max 30 world units per second
                };

                _ = try state.push_entity(e);
            }
        }
    }

    for (state.entities.items) |*e| {
        if (e.kinematics) |*kin| {
            const tx = &e.transform.?; // everything should have a transform
            const dp = maths.v3f_scale(kin.dp, state.frame_dt);
            var new_pos = maths.v3f_add(tx.pos, dp);

            // Keep entities within world bounds
            const world_half_width: f32 = state.world_dim.x / 2; // worldWidth / 2
            const world_half_height: f32 = state.world_dim.y / 2; // worldHeight / 2

            if (new_pos.x > world_half_width or new_pos.x < -world_half_width) {
                kin.dp.x = -kin.dp.x; // reverse x velocity
                new_pos.x = if (new_pos.x > world_half_width) world_half_width else -world_half_width; // clamp position
            }
            if (new_pos.y > world_half_height or new_pos.y < -world_half_height) {
                kin.dp.y = -kin.dp.y; // reverse y velocity
                new_pos.y = if (new_pos.y > world_half_height) world_half_height else -world_half_height; // clamp position
            }

            e.transform.?.pos = new_pos;
        }
    }

    // reset the renderer
    renderer.ops.clearRetainingCapacity();

    // clear screen to black
    try renderer.ops.append(render.RenderOp{
        .ClearScreen = render.Color3f{
            .r = 0.0,
            .g = 0.0,
            .b = 0.0,
        },
    });

    // draw world boundary rectangle (100x75 world bounds)
    try renderer.ops.append(render.RenderOp{
        .DrawQuad = render.Quad{
            .pos = maths.Vector3f{ .x = 0.0, .y = 0.0, .z = 0.0 }, // World center
            .scale = maths.Vector3f{
                .x = state.world_dim.x,
                .y = state.world_dim.y,
                .z = 1.0,
            }, // World bounds from main.zig
            .color = render.Color3f{
                .r = 0.1,
                .g = 0.1,
                .b = 0.2,
            },
        },
    });

    for (0..state.entity_count) |id| {
        const e = &state.entities.items[id];
        const tx = e.transform.?;

        // draw the base territory reach first
        if (e.factionBase) |fb| {
            try renderer.ops.append(render.RenderOp{
                .DrawQuad = render.Quad{
                    .pos = tx.pos,
                    .scale = maths.v3f_sub(fb.max, fb.min),
                    .color = TileColor,
                },
            });
        }
        try renderer.ops.append(render.RenderOp{
            .DrawQuad = render.Quad{
                .pos = tx.pos,
                .scale = tx.scale,
                .color = UnitColor,
            },
        });
    }

    // render structures
    // try renderer.ops.append(render.RenderOp{
    //     .DrawText = render.Text.fromConst(
    //         "From the Game Code",
    //         maths.Vector3f{
    //             .x = -0.5,
    //             .y = -0.5,
    //             .z = 0.0,
    //         },
    //         maths.Vector3f{
    //             .x = 1.0,
    //             .y = 1.0,
    //             .z = 1.0,
    //         },
    //         render.Color3f{
    //             .r = 0.0,
    //             .g = 1.0,
    //             .b = 0.0,
    //         },
    //     ),
    // });

    // try renderer.ops.append(render.RenderOp{
    //     .DrawText = render.Text.fromConst(
    //         "This is way more than 32 characters so lets see",
    //         maths.Vector3f{
    //             .x = -0.5,
    //             .y = 0.5,
    //             .z = 0.0,
    //         },
    //         maths.Vector3f{
    //             .x = 1.0,
    //             .y = 1.0,
    //             .z = 1.0,
    //         },
    //         render.Color3f{
    //             .r = 1.0,
    //             .g = 0.0,
    //             .b = 0.0,
    //         },
    //     ),
    // });
}
