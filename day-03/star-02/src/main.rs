#[macro_use]
extern crate lazy_static;
extern crate regex;

use regex::Regex;
use std::collections::HashMap;

type Point = (usize, usize);
type Count = usize;

struct Claim {
    id: String,
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
        let id = caps.get(1).unwrap().as_str().to_string();
        let x = caps.get(2).unwrap().as_str().parse().unwrap();
        let y = caps.get(3).unwrap().as_str().parse().unwrap();
        let width = caps.get(4).unwrap().as_str().parse().unwrap();
        let height = caps.get(5).unwrap().as_str().parse().unwrap();

        Claim {
            id,
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

    for claim in claims.clone() {
        for x in (claim.x)..(claim.x + claim.width) {
            for y in (claim.y)..(claim.y + claim.height) {
                *claims_counter.entry((x, y)).or_insert(0) += 1
            }
        }
    }

    for claim in claims {
        let mut all_good = true;

        'xes: for x in (claim.x)..(claim.x + claim.width) {
            for y in (claim.y)..(claim.y + claim.height) {
                if claims_counter.get(&(x, y)) != Some(&1) {
                    all_good = false;
                    break 'xes;
                }
            }
        }

        if all_good {
            println!("Result: {}", claim.id);
            break;
        }
    }
}
