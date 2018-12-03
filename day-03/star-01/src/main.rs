#[macro_use]
extern crate lazy_static;
extern crate regex;

use regex::Regex;
use std::collections::HashMap;

type Point = (usize, usize);
type Count = usize;

struct Claim {
    x: usize,
    y: usize,
    width: usize,
    height: usize,
}

impl Claim {
    fn from_description(description: &str) -> Self {
        lazy_static! {
            static ref DESCRIPTION_REGEX: Regex =
                Regex::new(r"^(#\d+) @ (\d+),(\d+): (\d+)x(\d+)$").unwrap();
        }
        let caps = DESCRIPTION_REGEX.captures(description).unwrap();
        let x = caps.get(2).unwrap().as_str().parse().unwrap();
        let y = caps.get(3).unwrap().as_str().parse().unwrap();
        let width = caps.get(4).unwrap().as_str().parse().unwrap();
        let height = caps.get(5).unwrap().as_str().parse().unwrap();

        Claim {
            x,
            y,
            width,
            height,
        }
    }
}

fn main() {
    let claims = include_str!("../input.txt")
        .lines()
        .map(|line| Claim::from_description(line));

    let mut claims_counter: HashMap<Point, Count> = HashMap::new();

    for claim in claims {
        for x in (claim.x)..(claim.x + claim.width) {
            for y in (claim.y)..(claim.y + claim.height) {
                *claims_counter.entry((x, y)).or_insert(0) += 1
            }
        }
    }

    let result = claims_counter.values().filter(|v| *v >= &2).count();

    println!("Result: {}", result);
}
