const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

pub fn main() void {
    const screenWidth = 800;
    const screenHeight = 600;

    ray.InitWindow(screenWidth, screenHeight, "zbreakout");
    defer ray.CloseWindow();

    ray.SetTargetFPS(60);

    while (!ray.WindowShouldClose()) {
        ray.BeginDrawing();
        defer ray.EndDrawing();
    }
}
