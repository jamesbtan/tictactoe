const Agent = @This();

ctx: *anyopaque = undefined,
moveFn: *const fn (ctx: *anyopaque, board: *Board) bool,

pub fn move(self: Agent, board: *Board) bool {
    return self.moveFn(self.ctx, board);
}
const Board = @import("../board.zig");
