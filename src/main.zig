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

const ball_radius = 8;

const Ball = struct {
    position: ray.Vector2,
    velocity: ray.Vector2,
    radius: f32,
    color: ray.Color,

    fn render(self: *Ball) void {
        ray.DrawCircleV(self.position, self.radius, self.color);
    }

    fn bounceFromEdges(self: *Ball) void {
        if (self.position.y >= screen_height) {
            ray.TraceLog(ray.LOG_INFO, "Game Over!");
            ray.TraceLog(ray.LOG_INFO, "Score: %d", g_score);
        }

        const hit_left_edge = self.position.x <= ball_radius;
        const hit_right_edge = self.position.x >= (screen_width - ball_radius);

        if (hit_left_edge or hit_right_edge) {
            self.velocity.x *= -1.0;
            return;
        }

        if (self.position.y <= ball_radius) {
            self.velocity.y *= -1.0;
            return;
        }
    }

    fn bounceFromBrick(self: *Ball) void {
        for (&g_bricks) |*brick| {
            if (ray.CheckCollisionCircleRec(self.position, ball_radius, brick.rectangle)) {
                g_score += 1;
                brick.rectangle.x = -200.0; // move enemy outside the screen
                self.velocity.y *= -1.0;
                return;
            }
        }
    }

    fn bounce(self: *Ball, player: *Player) void {
        // world bounds
        bounceFromEdges(self);

        // bricks
        bounceFromBrick(self);

        // player
        if (ray.CheckCollisionCircleRec(self.position, ball_radius, player.rectangle)) {
            self.velocity.y *= -1.0;
            return;
        }
    }

    fn tick(self: *Ball, player: *Player) void {
        self.position.x += self.velocity.x;
        self.position.y += self.velocity.y;

        self.bounce(player);
    }
};
const Player = struct { rectangle: ray.Rectangle, color: ray.Color };
const Brick = struct { rectangle: ray.Rectangle, color: ray.Color };

const Direction = enum { left, right };

var g_bricks: [bricks_count]Brick = undefined;
var g_score: u32 = 0;

fn makeVector2(x: f32, y: f32) ray.Vector2 {
    return ray.Vector2{
        .x = x,
        .y = y,
    };
}

fn makeRectangle(x: f32, y: f32, width: f32, height: f32) ray.Rectangle {
    return ray.Rectangle{
        .x = x,
        .y = y,
        .width = width,
        .height = height,
    };
}

fn playerCanMove(player: *Player, direction: Direction) bool {
    if (direction == Direction.left) {
        return if (player.rectangle.x > 0) true else false;
    } else {
        return if ((player.rectangle.x + player.rectangle.width) < screen_width) true else false;
    }
}

fn input(player: *Player) void {
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

fn initializeBricks() void {
    var column: u32 = 0;
    var brick_index: u32 = 0;
    var position_y: f32 = @floatFromInt(brick_gap);

    while (true) {
        g_bricks[brick_index].rectangle.x = @floatFromInt((column + 1) * brick_gap + (column * brick_width));
        g_bricks[brick_index].rectangle.y = position_y;
        g_bricks[brick_index].rectangle.width = brick_width;
        g_bricks[brick_index].rectangle.height = brick_height;
        g_bricks[brick_index].color = ray.BLUE;

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

fn renderBricks() void {
    for (&g_bricks) |*brick| {
        ray.DrawRectangleRec(brick.rectangle, brick.color);
    }
}

fn renderPlayer(player: *Player) void {
    ray.DrawRectangleRec(player.rectangle, player.color);
}

pub fn main() !void {
    ray.InitWindow(screen_width, screen_height, "zbreakout");
    defer ray.CloseWindow();

    ray.SetTargetFPS(60);

    var ball = Ball{
        .position = makeVector2(screen_width / 2, screen_height / 2),
        .velocity = makeVector2(4.0, -2.0),
        .radius = ball_radius,
        .color = ray.RED,
    };

    var player = Player{
        .rectangle = makeRectangle((screen_width / 2) - (player_width / 2), screen_height - 50, player_width, player_height),
        .color = ray.GREEN,
    };

    initializeBricks();

    var score_buffer: [20]u8 = undefined;
    while (!ray.WindowShouldClose()) {
        // input
        input(&player);

        // tick
        ball.tick(&player);

        // render
        ray.BeginDrawing();
        defer ray.EndDrawing();

        ray.ClearBackground(ray.BLACK);

        renderPlayer(&player);
        ball.render();
        renderBricks();

        const score_string: [:0]u8 = try std.fmt.bufPrintZ(&score_buffer, "Score: {d}", .{g_score});
        ray.DrawText(@as([*c]const u8, @ptrCast(score_string)), 10, screen_height - 34, 24, ray.WHITE);
    }
}
