const Random = @This();

rng: std.Random,

fn move(c: *anyopaque, b: *Board) bool {
    const r: *Random = @ptrCast(@alignCast(c));
    const v = b.validMoves();
    const i = std.Random.weightedIndex(r.rng, usize, &v);
    return b.move(i) catch unreachable;
}

pub fn agent(self: *Random) Agent {
    return .{ .ctx = self, .moveFn = move };
}

const std = @import("std");
const Agent = @import("agent.zig");
const Board = @import("../board.zig");
