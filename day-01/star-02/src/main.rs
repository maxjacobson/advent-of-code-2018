use std::collections::HashSet;

fn main() {
    let input = include_str!("../input.txt");
    let mut frequency_occurences = HashSet::new();

    let changes = input
        .split_whitespace()
        .map(|line| line.parse::<i32>().unwrap())
        .cycle();

    frequency_occurences.insert(0);

    let mut frequency = 0;
    for change in changes {
        frequency += change;
        if frequency_occurences.contains(&frequency) {
            println!("Result: {}", frequency);
            break;
        } else {
            frequency_occurences.insert(frequency);
        }
    }
}
