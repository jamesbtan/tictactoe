const MCTS = @This();

// if at leaf expand, simulate, backpropogate
// else select

allr: std.mem.Allocator,
ag: Agent,

const MCTSNode = struct {
    current: Board,
    parent: ?*MCTSNode,
    children: ?[]MCTSNode = null,
    chmoves: ?[]usize = null,
    wins: u32 = 0,
    sims: u32 = 0,

    pub fn deinit(self: *MCTSNode, allr: std.mem.Allocator) void {
        if (self.children) |*c| {
            for (c.*) |*C| {
                C.deinit(allr);
            }
            allr.free(self.children.?);
        }
    }

    pub fn bestChild(self: MCTSNode) *MCTSNode {
        std.debug.assert(self.children != null);
        for (self.children.?) |*c| {
            if (c.sims == 0) return c;
        }
        var mi: usize = 0;
        var mv: f32 = 0;
        for (self.children.?, 0..) |c, i| {
            const fw: f32 = @floatFromInt(c.wins);
            const fs: f32 = @floatFromInt(c.sims);
            const fps: f32 = @floatFromInt(c.parent.?.sims);
            const v = fw / fs + 1.4 * std.math.sqrt(std.math.log2(fps) / std.math.log2e / fs);
            if (v > mv) {
                mv = v;
                mi = i;
            }
        }
        return &self.children.?[mi];
    }
};

fn expand(self: MCTS, r: *MCTSNode) void {
    var c = r;
    while (c.children != null) {
        c = c.bestChild();
    }
    const b = &c.current;
    const n = 9 - b.filled;
    if (b.winner != null) {
        backpropogate(c, 2);
        return;
    }
    if (n == 0) {
        backpropogate(c, 1);
        return;
    }
    // add each valid move
    const ch = self.allr.alloc(MCTSNode, n) catch unreachable;
    const v = b.validMoves();
    var i: usize = 0;
    for (v, 0..) |V, m| {
        if (V == 0) continue;
        ch[i] = .{ .current = c.current, .parent = c };
        _ = ch[i].current.move(m) catch unreachable;
        i += 1;
    }
    c.children = ch;
    const cc = c.bestChild();
    var cb = cc.current;
    while (true) {
        if (cb.filled == 9 or cb.winner != null) break;
        _ = self.ag.move(&cb);
    }
    if (cb.winner) |w| {
        backpropogate(cc, if (cc.current.turn == w) 2 else 0);
    } else {
        backpropogate(cc, 1);
    }
}

fn backpropogate(n: *MCTSNode, v: u32) void {
    var c: ?*MCTSNode = n;
    var t = v;
    while (c) |C| {
        C.wins += t;
        C.sims += 2;
        t = 2 - t;
        c = C.parent;
    }
}

fn move(ctx: *anyopaque, b: *Board) bool {
    const self: *MCTS = @ptrCast(@alignCast(ctx));
    var r: MCTSNode = .{ .current = b.*, .parent = null };
    defer r.deinit(self.allr);
    for (0..10000) |_| self.expand(&r);
    const v = b.validMoves();
    var i: usize = 0;
    var ms: u32 = 0;
    var mm: usize = 0;
    for (v, 0..) |V, m| {
        if (V == 0) continue;
        std.debug.print("{}: {} / {}\n", .{i, r.children.?[i].wins, r.children.?[i].sims});
        if (r.children.?[i].sims > ms) {
            ms = r.children.?[i].sims;
            mm = m;
            //std.debug.print("{}: {}\n", .{mm, ms});
        }
        i += 1;
    }
    return b.move(mm) catch unreachable;
}

pub fn agent(self: *MCTS) Agent {
    return .{ .ctx = self, .moveFn = move };
}

const std = @import("std");
const Board = @import("../board.zig");
const Agent = @import("agent.zig");
const Random = @import("random.zig");
