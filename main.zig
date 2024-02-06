const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

const screen_width = 400;
const screen_height = 400;
const player_width = 100;
const player_height = 10;

const Ball = struct { position: ray.Vector2, radius: f32, color: ray.Color };
const Player = struct { rectangle: ray.Rectangle, color: ray.Color };

const Direction = enum { left, right };

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

    const start_position = ray.Vector2{
        .x = screen_width / 2,
        .y = screen_height / 2,
    };

    var ball = Ball{
        .position = start_position,
        .radius = 8,
        .color = ray.RED,
    };

    const player_rectangle = ray.Rectangle{
        .x = (screen_width / 2) - (player_width / 2),
        .y = screen_height - 50,
        .width = player_width,
        .height = player_height,
    };

    var player = Player{
        .rectangle = player_rectangle,
        .color = ray.GREEN,
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
    }
}
