pub mod file;
pub mod parse;

use file::*;

fn main() -> std::io::Result<()> {
    let filename = "test.s";
    let data = readfile(filename);
    let (_, parsed_data) = parse_file(&data).ok().unwrap();
    let parsed_data = check_symbol(parsed_data).ok().unwrap();
    write_to_file("a.out", parsed_data)
}
