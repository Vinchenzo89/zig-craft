const c = @cImport({
    @cInclude("raylib.h");
});

// graphics settings
pub const SetConfigFlags = c.SetConfigFlags;
pub const FLAG_VSYNC_HINT = c.FLAG_VSYNC_HINT;
pub const FLAG_WINDOW_HIGHDPI = c.FLAG_WINDOW_HIGHDPI;

// monitor and DPI functions
pub const GetCurrentMonitor = c.GetCurrentMonitor;
pub const GetMonitorWidth = c.GetMonitorWidth;
pub const GetMonitorHeight = c.GetMonitorHeight;
pub const GetMonitorPhysicalWidth = c.GetMonitorPhysicalWidth;
pub const GetMonitorPhysicalHeight = c.GetMonitorPhysicalHeight;
pub const GetWindowScaleDPI = c.GetWindowScaleDPI;

pub const Color = c.Color;
pub const Vector2 = c.Vector2;
pub const Vector3 = c.Vector3;
pub const Rectangle = c.Rectangle;
pub const Camera2D = c.Camera2D;

pub const WHITE = c.WHITE;
pub const BLACK = c.BLACK;
pub const RED = c.RED;
pub const GREEN = c.GREEN;
pub const BLUE = c.BLUE;
pub const YELLOW = c.YELLOW;

pub const BeginDrawing = c.BeginDrawing;
pub const EndDrawing = c.EndDrawing;
pub const BeginMode2D = c.BeginMode2D;
pub const EndMode2D = c.EndMode2D;
pub const ClearBackground = c.ClearBackground;
pub const DrawRectangle = c.DrawRectangle;
pub const DrawRectangleV = c.DrawRectangleV;
pub const DrawRectangleRec = c.DrawRectangleRec;
pub const DrawText = c.DrawText;
pub const DrawTextEx = c.DrawTextEx;

pub const InitWindow = c.InitWindow;
pub const CloseWindow = c.CloseWindow;
pub const WindowShouldClose = c.WindowShouldClose;
pub const SetTargetFPS = c.SetTargetFPS;
pub const GetFrameTime = c.GetFrameTime;
pub const GetTime = c.GetTime;

pub const IsKeyDown = c.IsKeyDown;
pub const KEY_W = c.KEY_W;
pub const KEY_A = c.KEY_A;
pub const KEY_S = c.KEY_S;
pub const KEY_D = c.KEY_D;
