pub fn main() !void {
    const h = Human.agent();
    //_ = h;

    var rng = std.Random.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = rng.random();
    var rnd: Random = .{ .rng = rand };
    const ra = rnd.agent();

    var mcts: MCTS = .{ .allr = std.heap.smp_allocator, .ag = ra };
    const ma = mcts.agent();

    const players = [_]Player{
        .{
            .name = "human",
            .agent = h,
        },

        .{
            .name = "mcts",
            .agent = ma,
        },
    };

    var b: Board = .{};
    var turn = std.Random.boolean(rand);
    while (true) {
        const r = players[@intFromBool(turn)].agent.move(&b);
        b.print();
        if (r) break;
        turn = !turn;
    }
    if (b.winner) |w| {
        std.debug.print("{s} won!\n", .{switch (w) {
            .white => players[0].name,
            .black => players[1].name,
        }});
    } else {
        std.debug.print("It was a tie.\n", .{});
    }
}

const Player = struct {
    name: []const u8,
    agent: Agent,
};

test {
    std.testing.refAllDecls(@This());
}

const std = @import("std");
const Board = @import("board.zig");
const Agent = @import("agent/agent.zig");
const Human = @import("agent/human.zig");
const Random = @import("agent/random.zig");
const MCTS = @import("agent/mcts.zig");
