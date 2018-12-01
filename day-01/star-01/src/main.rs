fn main() {
    let input = include_str!("../input.txt");

    let result: i32 = input
        .split_whitespace()
        .fold(0, |acc, line| acc + line.parse::<i32>().unwrap());

    println!("Result: {}", result);
}
