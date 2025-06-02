const MCTS = @This();

// if at leaf expand, simulate, backpropogate
// else select

allr: std.mem.Allocator,
ag: Agent,
nodes: std.ArrayListUnmanaged(MCTSNode) = .empty,

const MCTSNode = struct {
    const ChildSlice = struct {
        off: usize,
        len: usize,
    };
    current: Board,
    parent: ?usize,
    children: ?ChildSlice = null,
    wins: u32 = 0,
    sims: u32 = 0,

};

pub fn bestChild(self: MCTS, ind: usize) usize {
    const n = self.nodes.items[ind];
    std.debug.assert(n.children != null);
    const c = n.children.?;
    for (self.nodes.items[c.off..][0..c.len], c.off..) |C, i| {
        if (C.sims == 0) return i;
    }
    var mi: usize = c.off;
    var mv: f32 = 0;
    const fps: f32 = @floatFromInt(self.nodes.items[ind].sims);
    for (self.nodes.items[c.off..][0..c.len], c.off..) |C, i| {
        const fw: f32 = @floatFromInt(C.wins);
        const fs: f32 = @floatFromInt(C.sims);
        const v = fw / fs + 1.4 * std.math.sqrt(std.math.log2(fps) / std.math.log2e / fs);
        if (v > mv) {
            mv = v;
            mi = i;
        }
    }
    return mi;
}

fn expand(self: *MCTS) void {
    var c: usize = 0;
    while (self.nodes.items[c].children != null) {
        c = self.bestChild(c);
    }
    const b = self.nodes.items[c].current;
    const n = 9 - b.filled;
    if (b.winner != null) {
        self.backpropogate(c, 2);
        return;
    }
    if (n == 0) {
        self.backpropogate(c, 1);
        return;
    }
    // add each valid move
    self.nodes.items[c].children = .{ .off = self.nodes.items.len, .len = n };
    const ch = self.nodes.addManyAsSlice(self.allr, n) catch unreachable;
    const v = b.validMoves();
    var i: usize = 0;
    for (v, 0..) |V, m| {
        if (V == 0) continue;
        ch[i] = .{ .current = self.nodes.items[c].current, .parent = c };
        _ = ch[i].current.move(m) catch unreachable;
        i += 1;
    }
    const cc = self.bestChild(c);
    var cb = self.nodes.items[cc].current;
    while (true) {
        if (cb.filled == 9 or cb.winner != null) break;
        _ = self.ag.move(&cb);
    }
    if (cb.winner) |w| {
        self.backpropogate(cc, if (self.nodes.items[cc].current.turn == w) 2 else 0);
    } else {
        self.backpropogate(cc, 1);
    }
}

fn backpropogate(self: MCTS, n: usize, v: u32) void {
    var c: ?usize = n;
    var t = v;
    while (c) |C| {
        self.nodes.items[C].wins += t;
        self.nodes.items[C].sims += 2;
        t = 2 - t;
        c = self.nodes.items[C].parent;
    }
}

fn move(ctx: *anyopaque, b: *Board) bool {
    const self: *MCTS = @ptrCast(@alignCast(ctx));
    self.nodes.append(self.allr, .{ .current = b.*, .parent = null }) catch unreachable;
    defer self.nodes.clearRetainingCapacity();
    for (0..1000000) |_| self.expand();
    const v = b.validMoves();
    var i: usize = 1;
    var ms: u32 = 0;
    var mm: usize = 0;
    for (v, 0..) |V, m| {
        if (V == 0) continue;
        std.debug.print("{}: {} / {}\n", .{m, self.nodes.items[i].wins, self.nodes.items[i].sims});
        if (self.nodes.items[i].sims > ms) {
            ms = self.nodes.items[i].sims;
            mm = m;
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
