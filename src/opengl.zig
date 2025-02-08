// OpenGL function bindings to avoid including the header files
// NOTE: Including the GL/gl.h header file breaks the Zig Language Server.
// Having our own bindings defined is better anyways
pub const GL_TRIANGLES: u32 = 4;
pub extern "opengl32" fn glClearColor(r: f32, g: f32, b: f32, a: f32) void;
pub extern "opengl32" fn glLoadIdentity() void;
pub extern "opengl32" fn glBegin(mode: u32) void;
pub extern "opengl32" fn glColor3f(r: f32, g: f32, b: f32) void;
pub extern "opengl32" fn glVertex2f(x: f32, y: f32) void;
pub extern "opengl32" fn glEnd() void;
