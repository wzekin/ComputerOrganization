pub mod file;
pub mod parse;
use clap::{App, Arg};
use file::*;

fn main() -> std::io::Result<()> {
    let matches = App::new("My Super Program")
        .version("1.0")
        .author("Kevin K. <kbknapp@gmail.com>")
        .about("Does awesome things")
        .arg(
            Arg::with_name("input")
                .short("i")
                .long("input")
                .help("输入文件")
                .required(true)
                .takes_value(true),
        )
        .arg(
            Arg::with_name("out")
                .short("o")
                .long("out")
                .help("输出文件")
                .takes_value(true),
        )
        .get_matches();
    let input = matches.value_of("input").unwrap();
    let out = matches.value_of("out");
    let data = readfile(input);
    let (_, parsed_data) = parse_file(&data).ok().expect("parse failed");
    let parsed_data = check_symbol(parsed_data).expect("check symbol failed");
    if out.is_some() {
        write_to_file(out.unwrap(), parsed_data)
    } else {
        write_to_file("a.out", parsed_data)
    }
}
