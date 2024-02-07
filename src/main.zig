const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

const screen_width = 600;
const screen_height = 400;

const player_width = 100;
const player_height = 20;

const brick_width = player_width;
const brick_height = player_height;

const Ball = struct { position: ray.Vector2, radius: f32, color: ray.Color };
const Player = struct { rectangle: ray.Rectangle, color: ray.Color };
const Brick = struct { rectangle: ray.Rectangle, color: ray.Color };

const Direction = enum { left, right };

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

pub fn main() void {
    ray.InitWindow(screen_width, screen_height, "zbreakout");
    defer ray.CloseWindow();

    ray.SetTargetFPS(60);

    var ball = Ball{
        .position = makeVector2(screen_width / 2, screen_height / 2),
        .radius = 8,
        .color = ray.RED,
    };

    var player = Player{
        .rectangle = makeRectangle((screen_width / 2) - (player_width / 2), screen_height - 50, player_width, player_height),
        .color = ray.GREEN,
    };

    var brick = Brick{
        .rectangle = makeRectangle(50, 50, brick_width, brick_height),
        .color = ray.BLUE,
    };

    while (!ray.WindowShouldClose()) {
        // input
        input(&player);

        // render
        ray.BeginDrawing();
        defer ray.EndDrawing();

        ray.ClearBackground(ray.BLACK);
        ray.DrawCircleV(ball.position, ball.radius, ball.color);
        ray.DrawRectangleRec(player.rectangle, player.color);
        ray.DrawRectangleRec(brick.rectangle, brick.color);
    }
}
