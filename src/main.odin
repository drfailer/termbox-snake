package main

import tb "shared:odin-termbox2"
import "core:math/rand"
import "core:fmt"

GRID_WIDTH :: 20
GRID_HEIGHT :: 20
DELAY :: 200

Direction :: enum {
    North,
    East,
    South,
    West,
}

Point :: [2]i32

DirectionVectors :: [Direction]Point {
	.North = {  0, -1 },
	.East = { +1,  0 },
	.South = {  0, +1 },
	.West = { -1,  0 },
}

Grid :: struct {
    x_bgn: i32,
    y_bgn: i32,
    x_end: i32,
    y_end: i32,
    food: Point,
}

Snake :: struct {
    body: [GRID_WIDTH * GRID_HEIGHT]Point,
    head_idx: int,
    tail_idx: int,
    dir: Direction,
}

in_bound :: proc(p: Point) -> bool {
    x_in_bound := 0 <= p.x && p.x < GRID_WIDTH
    y_in_bound := 0 <= p.y && p.y < GRID_HEIGHT
    return x_in_bound && y_in_bound
}

draw_map :: proc(grid: Grid) {
    for y in grid.y_bgn..<grid.y_end {
        for x in grid.x_bgn..<grid.x_end {
            tb.printf(2 * x, y, .Default, .Green, "  ")
        }
    }
}

draw_snake_part :: proc(snake_part: Point, grid: Grid, chars: string) {
    part_x := grid.x_bgn + snake_part.x
    part_y := grid.y_bgn + snake_part.y
    tb.printf(2 * part_x, part_y, .Default, .Blue, "%s", chars)
}

draw_snake :: proc(snake: Snake, grid: Grid) {
    switch snake.dir {
    case .North:
        fallthrough
    case .South:
        draw_snake_part(snake.body[snake.head_idx], grid, "oo")
    case .East:
        draw_snake_part(snake.body[snake.head_idx], grid, " 8")
    case .West:
        draw_snake_part(snake.body[snake.head_idx], grid, "8 ")
    }
    for i := snake.tail_idx; i != snake.head_idx; i = (i + 1) % len(snake.body) {
        draw_snake_part(snake.body[i], grid, "  ")
    }
}

advance :: proc(snake: ^Snake, grid: ^Grid) -> (ok: bool) {
    dirs := DirectionVectors
    grid_size := len(snake.body)
    new_head_idx := (snake.head_idx + 1) % grid_size
    snake.body[new_head_idx] = snake.body[snake.head_idx] + dirs[snake.dir]
    snake.head_idx = new_head_idx

    if snake.body[snake.head_idx] == grid.food {
        grid.food = { rand.int31_max(GRID_WIDTH), rand.int31_max(GRID_HEIGHT) }
        return true
    }
    snake.tail_idx = (snake.tail_idx + 1) % grid_size

    if !in_bound(snake.body[snake.head_idx]) {
        return false
    }
    for i := snake.tail_idx; i != snake.head_idx; i = (i + 1) % grid_size {
        if snake.body[snake.head_idx] == snake.body[i] {
            return false
        }
    }

    return true
}

main :: proc() {
    snake: Snake
    run := true

    snake.body[0] = { GRID_WIDTH / 2, GRID_HEIGHT / 2}
    snake.body[1] = { GRID_WIDTH / 2, GRID_HEIGHT / 2 + 1}
    snake.tail_idx = 0
    snake.head_idx = 1
    snake.dir = .North

	tb.init();

    x_bgn := (tb.width() - GRID_WIDTH)/4
    y_bgn := (tb.height() - GRID_HEIGHT)/2
    grid := Grid {
        x_bgn = x_bgn,
        y_bgn = y_bgn,
        x_end = x_bgn + GRID_WIDTH,
        y_end = y_bgn + GRID_HEIGHT,
        food = { rand.int31_max(GRID_WIDTH), rand.int31_max(GRID_HEIGHT) }
    }

    for run {
        ev: tb.Event
        tb.peek_event(&ev, DELAY)

        #partial switch ev.key {
        case .Ctrl_Q:
            run = false
        case .Arrow_Up:
            snake.dir = .North
        case .Arrow_Down:
            snake.dir = .South
        case .Arrow_Left:
            snake.dir = .West
        case .Arrow_Right:
            snake.dir = .East
        case:
            tb.printf(0, 0, .Default, .Default, "unsupported")
        }

        if ok := advance(&snake, &grid); !ok {
            run = false
        }

        draw_map(grid)
        draw_snake(snake, grid)
        tb.printf(2 * (grid.x_bgn + grid.food.x), grid.y_bgn + grid.food.y, .Default, .Red, "XX")

        tb.present()
    }

    tb.shutdown()
}
