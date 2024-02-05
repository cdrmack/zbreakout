const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

const Ball = struct { position: ray.Vector2, radius: f32, color: ray.Color };

pub fn main() void {
    const screenWidth = 400;
    const screenHeight = 800;

    ray.InitWindow(screenWidth, screenHeight, "zbreakout");
    defer ray.CloseWindow();

    ray.SetTargetFPS(60);

    const startPosition = ray.Vector2{
        .x = screenWidth / 2,
        .y = screenHeight - 50, // TODO(cdrmack), remove magic number
    };

    var ball = Ball{
        .position = startPosition,
        .radius = 8,
        .color = ray.RED,
    };

    while (!ray.WindowShouldClose()) {
        ray.BeginDrawing();
        defer ray.EndDrawing();

        ray.DrawCircleV(ball.position, ball.radius, ball.color);
    }
}
