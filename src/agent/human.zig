const i = std.io.getStdIn();
const ir = i.reader();

pub fn move(_: *anyopaque, b: *Board) bool {
    while (true) {
        const m = ir.readByte() catch unreachable;
        if (m < '1' or '9' < m) continue;
        if (b.move(m - '1')) |r| {
            return r;
        } else |_| continue;
    }
}

pub fn agent() Agent {
    return .{ .moveFn = move };
}

const std = @import("std");
const Agent = @import("agent.zig");
const Board = @import("../board.zig");
