const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

const screen_width = 800;
const screen_height = 600;

const player_width = 100;
const player_height = 20;

const brick_width = 50;
const brick_height = player_height;
const bricks_count = 40;
const bricks_per_row = 10;
const brick_gap = (screen_width - (bricks_per_row * brick_width)) / (bricks_per_row + 1);

const Ball = struct { position: ray.Vector2, radius: f32, color: ray.Color };
const Player = struct { rectangle: ray.Rectangle, color: ray.Color };
const Brick = struct { rectangle: ray.Rectangle, color: ray.Color };

const Direction = enum { left, right };

var g_bricks: [bricks_count]Brick = undefined;

pub fn makeVector2(x: f32, y: f32) ray.Vector2 {
    return ray.Vector2{
        .x = x,
        .y = y,
    };
}

pub fn makeRectangle(x: f32, y: f32, width: f32, height: f32) ray.Rectangle {
    return ray.Rectangle{
        .x = x,
        .y = y,
        .width = width,
        .height = height,
    };
}

pub fn playerCanMove(player: *Player, direction: Direction) bool {
    if (direction == Direction.left) {
        return if (player.rectangle.x > 0) true else false;
    } else {
        return if ((player.rectangle.x + player.rectangle.width) < screen_width) true else false;
    }
}

pub fn input(player: *Player) void {
    if (ray.IsKeyDown(ray.KEY_RIGHT)) {
        if (playerCanMove(player, Direction.right)) {
            player.rectangle.x += 10;
        }
    }

    if (ray.IsKeyDown(ray.KEY_LEFT)) {
        if (playerCanMove(player, Direction.left)) {
            player.rectangle.x -= 10;
        }
    }
}

pub fn initializeBricks() void {
    var column: u32 = 0;
    var brick_index: u32 = 0;
    var position_y: f32 = @floatFromInt(brick_gap);

    while (true) {
        g_bricks[brick_index].rectangle.x = @floatFromInt((column + 1) * brick_gap + (column * brick_width));
        g_bricks[brick_index].rectangle.y = position_y;
        g_bricks[brick_index].rectangle.width = brick_width;
        g_bricks[brick_index].rectangle.height = brick_height;
        g_bricks[brick_index].color = ray.BLUE;

        ray.TraceLog(ray.LOG_INFO, "Brick %d, x = %f, y = %f", brick_index, g_bricks[brick_index].rectangle.x, g_bricks[brick_index].rectangle.y);

        if ((brick_index + 1) % bricks_per_row == 0) {
            column = 0;
            position_y += (2 * brick_height);
        } else {
            column += 1;
        }

        brick_index += 1;

        if (brick_index >= bricks_count) {
            break;
        }
    }
}

pub fn renderBricks() void {
    for (g_bricks) |brick| {
        ray.DrawRectangleRec(brick.rectangle, brick.color);
    }
}

pub fn main() void {
    ray.InitWindow(screen_width, screen_height, "zbreakout");
    defer ray.CloseWindow();

    ray.SetTargetFPS(60);

    var ball = Ball{
        .position = makeVector2(screen_width / 2, screen_height - 100), // TODO(cdrmack), remove magic number
        .radius = 8,
        .color = ray.RED,
    };

    var player = Player{
        .rectangle = makeRectangle((screen_width / 2) - (player_width / 2), screen_height - 50, player_width, player_height),
        .color = ray.GREEN,
    };

    initializeBricks();

    while (!ray.WindowShouldClose()) {
        // input
        input(&player);

        // render
        ray.BeginDrawing();
        defer ray.EndDrawing();

        ray.ClearBackground(ray.BLACK);
        ray.DrawCircleV(ball.position, ball.radius, ball.color);
        ray.DrawRectangleRec(player.rectangle, player.color);
        renderBricks();
    }
}
