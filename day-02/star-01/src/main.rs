use std::collections::HashMap;

fn any_letter_exactly_n_times(id: &str, n: i32) -> bool {
    let map = HashMap::new();

    id.chars()
        .fold(map, |mut acc, c| {
            *acc.entry(c).or_insert(0) += 1;
            acc
        }).values()
        .any(|v| v == &n)
}

fn main() {
    let input = include_str!("../input.txt");

    let mut exactly_two_count = 0;
    let mut exactly_three_count = 0;

    for line in input.split_whitespace() {
        if any_letter_exactly_n_times(line, 2) {
            exactly_two_count += 1;
        }

        if any_letter_exactly_n_times(line, 3) {
            exactly_three_count += 1;
        }
    }

    println!("Result: {}", exactly_three_count * exactly_two_count);
}
