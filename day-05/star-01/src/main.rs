struct Polymer {
    units: Vec<char>,
}

impl Polymer {
    fn new(input: &str) -> Self {
        let units = input.chars().collect();

        Polymer { units }
    }

    fn react(&self) -> Polymer {
        println!("Reacting... (len={})", self.units.len());
        let debug: String = self.units.iter().collect();
        // println!("Head: {}", debug);

        let mut peekable = self.units.iter().peekable();

        let mut idx: Option<usize> = None;
        let mut counter = 0;

        loop {
            let next = peekable.next();
            let peek = peekable.peek();

            if next.is_none() {
                break;
            }

            if self.trigger_reaction(next, peek) {
                idx = Some(counter);
                break;
            }

            counter += 1;
        }

        let mut new_units: Vec<char> = self.units.clone();

        if let Some(i) = idx {
            let after = new_units.split_off(i);

            new_units = new_units
                .iter()
                .chain(after.iter().skip(2))
                .map(|c| *c)
                .collect();
        }

        if new_units == self.units {
            Polymer { units: new_units }
        } else {
            (Polymer { units: new_units }).react()
        }
    }

    fn trigger_reaction(&self, next: Option<&char>, peek: Option<&&char>) -> bool {
        match next {
            Some(ref n) => match peek {
                Some(p) => n != p && n.to_ascii_uppercase() == p.to_ascii_uppercase(),
                None => false,
            },
            None => false,
        }
    }
}

fn main() {
    let input = include_str!("../input.txt");

    let polymer = Polymer::new(input).react();

    println!("Result: {}", polymer.units.len());
}
