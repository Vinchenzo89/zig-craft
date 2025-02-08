const std = @import("std");

pub const Vector3f = struct {
    x: f32,
    y: f32,
    z: f32,
};
// alias the type so it is shorter?
const v3f: type = Vector3f;

pub fn v3f_add(a: v3f, b: v3f) v3f {
    const result = .{
        .x = (a.x + b.x),
        .y = (a.y + b.y),
        .z = (a.z + b.z),
    };
    return result;
}

pub fn v3f_sub(a: v3f, b: v3f) v3f {
    const result = .{
        .x = (a.x - b.x),
        .y = (a.y - b.y),
        .z = (a.z - b.z),
    };
    return result;
}

pub fn v3f_mul(a: v3f, b: v3f) v3f {
    const result = .{
        .x = (a.x * b.x),
        .y = (a.y * b.y),
        .z = (a.z * b.z),
    };
    return result;
}

pub fn v3f_dot(a: v3f, b: v3f) f32 {
    const result = ((a.x * b.x) + (a.y * b.y) + (a.z * b.z));
    return result;
}

pub fn v3f_length(a: f32) f32 {
    const result = std.math.sqrt((a.x * a.x) + (a.y * a.y) + (a.z + a.z));
    return result;
}

pub fn v3f_normalize(a: v3f) v3f {
    const abs = v3f_length(a);
    const result = .{
        .x = a.x / abs,
        .y = a.y / abs,
        .z = a.z / abs,
    };
    return result;
}
