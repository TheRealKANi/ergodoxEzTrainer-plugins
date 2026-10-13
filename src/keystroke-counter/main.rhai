// Keystroke counter: an overlay for ergodoxEzTrainer.
// Copyright (C) 2026 TheRealKANi · SPDX-License-Identifier: GPL-3.0-or-later

fn init() {
    this.count = 0;
}

// Overlays do not get typed characters (only the training module in front does), but they
// hear the "next_key" event that the built-in modules send for every key to press.
fn on_event(name, data) {
    if name == "next_key" {
        this.count += 1;
    }
}

fn on_click(id) {
    if id == "reset" { this.count = 0; }
}

fn view() {
    if !setting("show") { return []; }
    let right = setting("corner") == "right";
    let x = if right { canvas_w() - 12.0 } else { 12.0 };
    [
        #{ t: "text", x: x, y: 10.0, align: if right { "right" } else { "left" },
           text: t("{0} keys to press so far", [this.count]), size: 13.0, color: "weak" },
        #{ t: "button", id: "reset", x: x, y: 30.0, align: if right { "right" } else { "left" },
           label: t("Reset"), icon: "arrow-counter-clockwise", size: 12.0 },
    ]
}
