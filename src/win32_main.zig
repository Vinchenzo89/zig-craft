const std = @import("std");
const gl = @import("opengl.zig");
const windows = @cImport(
    @cInclude("windows.h"),
);

const draw = @import("renderer.zig");
const maths = @import("maths.zig");
const game = @import("game.zig");

var GlobalRunning = false;

pub fn Win32WindowProcess(
    Hwnd: windows.HWND,
    Msg: u32,
    WParam: usize,
    LParam: isize,
) callconv(.C) isize {
    //std.debug.print("We are in the WindowProc \n", .{});
    var Result: isize = 0;
    switch (Msg) {
        windows.WM_CLOSE => {
            GlobalRunning = false;
            return 0;
        },
        windows.WM_DESTROY => {
            GlobalRunning = false;
            return 0;
        },
        windows.WM_QUIT => {
            GlobalRunning = false;
            return 0;
        },
        else => {
            Result = windows.DefWindowProcA(Hwnd, Msg, WParam, LParam);
        },
    }
    return Result;
}

pub fn main() !u8 {
    const WindowClass = windows.WNDCLASSA{
        .style = windows.CS_OWNDC | windows.CS_HREDRAW | windows.CS_VREDRAW,
        .lpfnWndProc = &Win32WindowProcess,
        .cbClsExtra = 0,
        .cbWndExtra = 0,
        .hInstance = windows.GetModuleHandleA(0),
        .hCursor = null,
        .hbrBackground = null,
        .lpszMenuName = null,
        .lpszClassName = "Zig Invaders Game",
    };
    if (windows.RegisterClassA(&WindowClass) == 0) {
        std.debug.print("Error registering window class\n", .{});
    }
    std.debug.print("We've registered the window class \n", .{});

    const Style = windows.WS_OVERLAPPEDWINDOW |
        windows.WS_SYSMENU |
        windows.WS_CAPTION |
        windows.WS_MINIMIZEBOX;

    const WindowHandle = windows.CreateWindowExA(
        0,
        WindowClass.lpszClassName,
        WindowClass.lpszClassName,
        Style | windows.WS_VISIBLE,
        windows.CW_USEDEFAULT,
        windows.CW_USEDEFAULT,
        1080,
        920,
        null,
        null,
        WindowClass.hInstance,
        null,
    ).?;

    std.debug.print("Showing the window now\n", .{});

    const WindowHDC = windows.GetDC(WindowHandle);
    std.debug.print("What did we get as HDC: ", .{});

    {
        // Define the pixel format we want
        var PixelFormat: windows.PIXELFORMATDESCRIPTOR = .{
            .nSize = @sizeOf(windows.PIXELFORMATDESCRIPTOR),
            .nVersion = 1,
            .dwFlags = windows.PFD_DRAW_TO_WINDOW | windows.PFD_SUPPORT_OPENGL | windows.PFD_DOUBLEBUFFER,
            .iPixelType = windows.PFD_TYPE_RGBA,
            .cColorBits = 32,
            .cDepthBits = 24,
            .cStencilBits = 8,
            .iLayerType = windows.PFD_MAIN_PLANE,
        };

        // Get it chosen
        const PixelFormatIndex = windows.ChoosePixelFormat(WindowHDC, &PixelFormat);
        if (PixelFormatIndex == 0) return error.WinAPIError;

        // Then allow the system to describe one for us
        var SuggestedPixelFormat: windows.PIXELFORMATDESCRIPTOR = undefined;
        _ = windows.DescribePixelFormat(
            WindowHDC,
            PixelFormatIndex,
            @sizeOf(windows.PIXELFORMATDESCRIPTOR),
            &SuggestedPixelFormat,
        );

        // Then we set it
        if (0 == windows.SetPixelFormat(
            WindowHDC,
            PixelFormatIndex,
            @ptrCast(&SuggestedPixelFormat),
        )) return error.WinAPIError;

        // Finally create an OpenGL Context
        const GLContext = windows.wglCreateContext(WindowHDC);
        if (GLContext == null) return error.WinAPIError;

        // Here is where we would do modern OpenGL context loading and function binding loading
        if (0 > windows.wglMakeCurrent(WindowHDC, GLContext)) {
            std.debug.print("Here we load other GL features", .{});
        }
    }

    // memory stuff
    const oneGigMemory = try std.heap.page_allocator.alloc(u8, 1024 * 1024);
    var fixedBufferAllocator = std.heap.FixedBufferAllocator.init(oneGigMemory);

    // first game stuff
    var Renderer = draw.Renderer.init(fixedBufferAllocator.allocator());

    // Main Loop
    GlobalRunning = true;
    var Message: windows.MSG = undefined;
    while (GlobalRunning) {
        while (windows.PeekMessageA(&Message, null, 0, 0, windows.PM_REMOVE) > 0) {
            _ = windows.TranslateMessage(&Message);
            _ = windows.DispatchMessageA(&Message);
            if (Message.message == windows.WM_QUIT) {
                std.debug.print("We are quiting for some reason.", .{});
                GlobalRunning = false;
            }
        }

        // Update game state
        try game.UpdateAndRender(&Renderer);

        // Render a frame
        for (Renderer.ops.items) |r| {
            switch (r) {
                .ClearScreen => |color| {
                    gl.glClearColor(
                        color.r,
                        color.g,
                        color.b,
                        1.0,
                    );
                },
                .DrawQuad => |quad| {
                    gl.glLoadIdentity();
                    // TODO We need to call the matrix function to push a model matrix
                    gl.glColor3f(quad.color.r, quad.color.g, quad.color.b);
                    gl.glBegin(gl.GL_TRIANGLES);

                    gl.glVertex2f(
                        -quad.scale.x + quad.pos.x,
                        -quad.scale.y + quad.pos.y,
                    );
                    gl.glVertex2f(
                        quad.scale.x + quad.pos.x,
                        -quad.scale.y + quad.pos.y,
                    );
                    gl.glVertex2f(
                        quad.scale.x + quad.pos.x,
                        quad.scale.y + quad.pos.y,
                    );
                    // bottom right triangle
                    gl.glVertex2f(
                        -quad.scale.x + quad.pos.x,
                        -quad.scale.y + quad.pos.y,
                    );
                    gl.glVertex2f(
                        quad.scale.x + quad.pos.x,
                        quad.scale.y + quad.pos.y,
                    );
                    gl.glVertex2f(
                        -quad.scale.x + quad.pos.x,
                        quad.scale.y + quad.pos.y,
                    );
                    gl.glEnd();
                },
            }
        }

        _ = windows.SwapBuffers(WindowHDC);

        std.time.sleep(17_000_000);
    }

    std.debug.print("Are we dying gracefully?", .{});

    return 0;
}
