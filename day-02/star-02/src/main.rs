struct Id {
    chars: Vec<char>,
}

impl Id {
    fn new(id: &str) -> Self {
        Id {
            chars: id.chars().collect(),
        }
    }

    fn matches(&self, other: &Self) -> bool {
        self.chars
            .iter()
            .zip(other.chars.iter())
            .filter(|(a, b)| a != b)
            .count()
            == 1
    }
}

fn diff(a: &Id, b: &Id) -> String {
    a.chars
        .iter()
        .zip(b.chars.iter())
        .filter(|(a, b)| a == b)
        .map(|(a, _b)| a)
        .collect()
}

fn main() {
    let box_ids = include_str!("../input.txt")
        .split_whitespace()
        .map(|id| Id::new(id));

    'outer: for box_id in box_ids.clone() {
        for other_box_id in box_ids.clone() {
            if box_id.matches(&other_box_id) {
                println!("Result: {}", diff(&box_id, &other_box_id));
                break 'outer;
            }
        }
    }
}
