const std = @import("std");
const rl = @import("raylib.zig");

const draw = @import("renderer.zig");
const maths = @import("maths.zig");
const game = @import("game.zig");

pub fn main() !void {
    const screenWidth = 1080;
    const screenHeight = 920;

    rl.SetConfigFlags(rl.FLAG_VSYNC_HINT);
    rl.InitWindow(screenWidth, screenHeight, "Zig RTS Game");
    rl.SetTargetFPS(60); // Uncomment this line

    const oneGigMemory = try std.heap.page_allocator.alloc(u8, 1024 * 1024);
    var fixedBufferAllocator = std.heap.FixedBufferAllocator.init(oneGigMemory);

    // Define world bounds - this is your game world coordinate system
    const worldWidth: f32 = 100.0; // World is 100 units wide
    const worldHeight: f32 = 75.0; // World is 75 units tall (maintaining 4:3 aspect ratio)

    // Set up orthographic camera
    const camera = rl.Camera2D{
        .offset = rl.Vector2{ .x = @floatFromInt(screenWidth / 2), .y = @floatFromInt(screenHeight / 2) },
        .target = rl.Vector2{ .x = 0.0, .y = 0.0 },
        .rotation = 0.0,
        .zoom = 1.0,
    };

    var renderer = draw.Renderer.init(fixedBufferAllocator.allocator(), worldWidth, worldHeight);
    var gameState = game.GameState.init(fixedBufferAllocator.allocator());
    var last_time = std.time.nanoTimestamp();

    std.time.sleep(1_000_000);

    while (!rl.WindowShouldClose()) {
        const current_time = std.time.nanoTimestamp();
        const delta_time_ns = current_time - last_time;
        const delta_time_seconds = @as(f32, @floatFromInt(delta_time_ns)) / 1_000_000_000.0;
        last_time = current_time;

        gameState.frame_dt = delta_time_seconds;

        const input = game.GameInput{
            .up_button = rl.IsKeyDown(rl.KEY_W),
            .down_button = rl.IsKeyDown(rl.KEY_S),
            .left_button = rl.IsKeyDown(rl.KEY_A),
            .right_button = rl.IsKeyDown(rl.KEY_D),
        };

        try game.UpdateAndRender(input, &gameState, &renderer);

        rl.BeginDrawing();
        rl.BeginMode2D(camera);
        renderer.executeRenderOps();
        rl.EndMode2D();
        rl.EndDrawing();

        // const frame_end_time = std.time.nanoTimestamp();
        // const work_done_ns = frame_end_time - current_time;
        // const target_frame_ns = 16_666_667; // 60 FPS = ~16.67ms in nanoseconds
        // const time_left_ns = target_frame_ns - work_done_ns;

        // std.debug.print("time_left_ns: {}, work_done_ns: {}\n", .{ time_left_ns, work_done_ns });

        // if (time_left_ns > 0) {
        //     // std.debug.print("Sleeping for: {} ns\n", .{time_left_ns});
        //     std.time.sleep(@intCast(time_left_ns));
        // }
    }

    rl.CloseWindow();
}
