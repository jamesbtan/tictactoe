const Board = @This();
const Color = enum {
    white,
    black,
};

turn: Color = .white,
filled: usize = 0,
winner: ?Color = null,
board: [9]?Color = .{null} ** 9,

pub fn validMoves(s: Board) [9]usize {
    var r: [9]usize = undefined;
    for (&r, s.board) |*R, B| {
        R.* = @intFromBool(B == null);
    }
    return r;
}

pub fn isWin(s: Board) bool {
    for (0..3) |i| {
        if (s.board[i * 3] != null) {
            for (1..3) |j| {
                if (s.board[i * 3 + j] != s.board[i * 3]) break;
            } else return true;
        }
        if (s.board[i] != null) {
            for (1..3) |j| {
                if (s.board[i + j * 3] != s.board[i]) break;
            } else return true;
        }
    }
    if (s.board[0] != null) {
        for (1..3) |j| {
            if (s.board[j * 4] != s.board[0]) break;
        } else return true;
    }
    if (s.board[2] != null) {
        for (1..3) |j| {
            if (s.board[2 + j * 2] != s.board[2]) break;
        } else return true;
    }
    return false;
}

const MoveError = error{InvalidMove};
// returns true if game is over, and error for invalid move
pub fn move(s: *Board, i: usize) MoveError!bool {
    if (s.board[i] != null) return error.InvalidMove;
    s.board[i] = s.turn;
    if (s.isWin()) {
        s.winner = s.turn;
        return true;
    }
    s.turn = @enumFromInt(1 - @intFromEnum(s.turn));
    s.filled += 1;
    return s.filled == 9;
}

pub fn print(s: Board) void {
    for (0..3) |i| {
        for (0..3) |j| {
            const ch: u8 = if (s.board[i * 3 + j]) |c| switch (c) {
                .white => 'X',
                .black => 'O',
            } else '.';
            std.debug.print("{c}", .{ch});
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("---\n", .{});
}

test "row win" {
    const T = std.testing;
    var b: Board = .{};
    try T.expectEqualSlices(usize, &[_]usize{1} ** 9, &b.validMoves());
    try T.expectEqual(.white, b.turn);
    try T.expect(!try b.move(0));
    try T.expectEqualSlices(usize, &([_]usize{0} ++ [_]usize{1} ** 8), &b.validMoves());
    try T.expectEqual(.black, b.turn);
    try T.expectError(error.InvalidMove, b.move(0));
    try T.expect(!try b.move(3));
    try T.expect(!try b.move(1));
    try T.expect(!try b.move(4));
    try T.expect(try b.move(2));
    try T.expectEqual(.white, b.winner);
}

test "black win" {
    const T = std.testing;
    var b: Board = .{};
    try T.expect(!try b.move(0));
    try T.expect(!try b.move(1));
    try T.expect(!try b.move(3));
    try T.expect(!try b.move(4));
    try T.expect(!try b.move(5));
    try T.expect(try b.move(7));
    try T.expectEqual(.black, b.winner);
}

test "col win" {
    const T = std.testing;
    var b: Board = .{};
    try T.expect(!try b.move(0));
    try T.expect(!try b.move(1));
    try T.expect(!try b.move(3));
    try T.expect(!try b.move(4));
    try T.expect(try b.move(6));
    try T.expectEqual(.white, b.winner);
}

test "diag\\ win" {
    const T = std.testing;
    var b: Board = .{};
    try T.expect(!try b.move(0));
    try T.expect(!try b.move(1));
    try T.expect(!try b.move(4));
    try T.expect(!try b.move(2));
    try T.expect(try b.move(8));
    try T.expectEqual(.white, b.winner);
}

test "diag/ win" {
    const T = std.testing;
    var b: Board = .{};
    try T.expect(!try b.move(2));
    try T.expect(!try b.move(1));
    try T.expect(!try b.move(4));
    try T.expect(!try b.move(0));
    try T.expect(try b.move(6));
    try T.expectEqual(.white, b.winner);
}

test "tie" {
    const T = std.testing;
    var b: Board = .{};
    try T.expect(!try b.move(1));
    try T.expect(!try b.move(0));
    try T.expect(!try b.move(2));
    try T.expect(!try b.move(4));
    try T.expect(!try b.move(3));
    try T.expect(!try b.move(5));
    try T.expect(!try b.move(6));
    try T.expect(!try b.move(7));
    try T.expect(try b.move(8));
    try T.expectEqual(null, b.winner);
}

const std = @import("std");
