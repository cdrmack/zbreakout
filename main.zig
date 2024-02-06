const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

const Ball = struct { position: ray.Vector2, radius: f32, color: ray.Color };

pub fn main() void {
    const screen_width = 400;
    const screen_height = 800;

    ray.InitWindow(screen_width, screen_height, "zbreakout");
    defer ray.CloseWindow();

    ray.SetTargetFPS(60);

    const start_position = ray.Vector2{
        .x = screen_width / 2,
        .y = screen_height - 50, // TODO(cdrmack), remove magic number
    };

    var ball = Ball{
        .position = start_position,
        .radius = 8,
        .color = ray.RED,
    };

    while (!ray.WindowShouldClose()) {
        ray.BeginDrawing();
        defer ray.EndDrawing();

        ray.DrawCircleV(ball.position, ball.radius, ball.color);
    }
}
