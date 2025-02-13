// OpenGL function bindings to avoid including the header files
// NOTE: Including the GL/gl.h header file breaks the Zig Language Server.
// Having our own bindings defined is better anyways
pub const TRIANGLES = 0x0004;
pub const UNSIGNED_BYTE = 0x1401;
pub extern "opengl32" fn glClearColor(r: f32, g: f32, b: f32, a: f32) callconv(.C) void;
pub extern "opengl32" fn glVertex2f(x: f32, y: f32) void;
pub extern "opengl32" fn glLoadIdentity() void;
pub extern "opengl32" fn glColor3f(r: f32, g: f32, b: f32) void;
pub extern "opengl32" fn glBegin(mode: u32) void;
pub extern "opengl32" fn glEnd() void;

pub extern "opengl32" fn glRasterPos2f(x: f32, y: f32) void;
pub extern "opengl32" fn glListBase(a: u32) void;
pub extern "opengl32" fn glCallLists(a: c_int, b: c_int, c: ?[*:0]const u8) void;
pub extern "opengl32" fn glFlush() void;
