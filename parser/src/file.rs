use super::parse::IOrder::*;
use super::parse::*;
use nom::IResult;
use std::convert::TryInto;
use std::fs::File;
use std::io::Write;
use std::io::{BufRead, BufReader};
use std::str::from_utf8;

pub fn readfile(filename: &str) -> Vec<String> {
    let mut lines = Vec::new();
    let file = File::open(filename).unwrap();
    let reader = BufReader::new(file);
    for line in reader.lines() {
        lines.push(line.unwrap() + "\n");
    }
    return lines;
}

pub fn parse_file<'a>(lines: &'a Vec<String>) -> IResult<&[u8], IFile<'a>> {
    let mut ifile = IFile::default();
    let mut pos: u16 = 0;
    for i in 0..lines.len() {
        let (_, ast) = parse(lines[i].as_bytes())?;
        match ast {
            AST::Pos(p) => pos = p,
            AST::Symbol(s) => {
                ifile.symbols.insert(s, pos);
            }
            AST::Order(order) => {
                let len: u16 = order.len.try_into().unwrap();
                ifile.complies.insert(pos, order);
                pos = pos + len;
            }
        };
    }
    return Ok((b"", ifile));
}

pub fn check_symbol(mut ifile: IFile) -> Result<IFile, String> {
    for (_, val) in ifile.complies.iter_mut() {
        if val.symbol.is_some() {
            let s = val.symbol.unwrap();
            match ifile.symbols.get(s) {
                Some(pos) => {
                    *val = IComplie {
                        val_c: pos.clone(),
                        ..(val.clone())
                    }
                }
                None => return Err(format!("not found symbol {}", from_utf8(s).unwrap())),
            }
        }
    }
    return Ok(ifile);
}

pub fn write_to_file(filename: &str, ifile: IFile) -> std::io::Result<()> {
    let mut pos: u16 = 0;
    let mut file = File::create(filename)?;
    for (p, val) in ifile.complies.iter() {
        while pos < p.clone() {
            write!(file, "{:08b}\n", IOrder::HALT as u8)?;
            pos += 1;
        }
        match val.iorder {
            HALT | RET | NOP | IRET => {
                write!(file, "{:08b}\n", val.iorder as u8)?;
                pos += 1
            }
            CALL | JMP | JLE | JL | JE | JNE | JGE | JG | JS | JNS | JA | JAE | JB | JBE => {
                write!(file, "{:08b}\n", val.iorder as u8)?;
                for byte in val.val_c.to_le_bytes().iter() {
                    write!(file, "{:08b}\n", byte)?;
                }
                pos += 3
            }
            RRMOVQ | ADDQ | SUBQ | MULQ | DIVQ | ANDQ | ORQ | XORQ | OUT => {
                write!(file, "{:08b}\n", val.iorder as u8)?;
                write!(file, "{:04b}{:04b}\n", val.r_a, val.r_b)?;
                pos += 2
            }
            IRMOVQ | MRMOVQ | RMMOVQ => {
                write!(file, "{:08b}\n", val.iorder as u8)?;
                write!(file, "{:04b}{:04b}\n", val.r_a, val.r_b)?;
                for byte in val.val_c.to_le_bytes().iter() {
                    write!(file, "{:08b}\n", byte)?;
                }
                pos += 4
            }
            CONST => {
                for byte in val.val_c.to_le_bytes().iter() {
                    write!(file, "{:08b}\n", byte)?;
                }
                pos += 2
            }
        }
    }
    while pos < 512 {
        write!(file, "{:08b}\n", IOrder::HALT as u8)?;
        pos += 1;
    }
    Ok(())
}
