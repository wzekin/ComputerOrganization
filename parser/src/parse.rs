use nom::branch::alt;
use nom::bytes::complete::{tag, take_until};
use nom::character::complete::{digit0, space0};
use nom::character::is_alphabetic;
use nom::sequence::tuple;
use nom::{dbg_dmp, named, tag, take_while, IResult};
use std::collections::BTreeMap;
use std::convert::TryInto;

#[derive(Debug, PartialEq)]
pub enum AST<'a> {
    Pos(u16),
    Symbol(&'a [u8]),
    Order(IComplie<'a>),
}

#[derive(Debug, PartialEq, Clone, Copy)]
pub enum IOrder {
    HALT = 0x0,
    NOP = 0x10,
    IRMOVQ = 0x28,
    RRMOVQ = 0x38,
    MRMOVQ = 0x48,
    RMMOVQ = 0x58,
    OUT = 0x80,
    ADDQ = 0x61,
    SUBQ = 0x62,
    MULQ = 0x63,
    DIVQ = 0x64,
    ANDQ = 0x65,
    ORQ = 0x66,
    XORQ = 0x67,
    JMP = 0x70,
    JE = 0x71,
    JNE = 0x72,
    JS = 0x73,
    JNS = 0x74,
    JG = 0x75,
    JGE = 0x76,
    JL = 0x77,
    JLE = 0x78,
    JA = 0x79,
    JAE = 0x7A,
    JB = 0x7B,
    JBE = 0x7C,
    CALL = 0xA0,
    RET = 0xB0,
    IRET = 0xE0,
    CONST = 0xFF,
}

impl Default for IOrder {
    fn default() -> Self {
        IOrder::NOP
    }
}

#[derive(Default, Debug, PartialEq, Clone)]
pub struct IComplie<'a> {
    pub iorder: IOrder,

    pub r_a: u8,
    pub r_b: u8,
    pub val_c: u16,
    pub symbol: Option<&'a [u8]>,
    pub len: u8,
}

#[derive(Default, Debug)]
pub struct IFile<'a> {
    pub complies: BTreeMap<u16, IComplie<'a>>,
    pub symbols: BTreeMap<&'a [u8], u16>,
}

named!(method, take_while!(is_alphabetic));

named!(rsp, tag!("rsp"));
named!(r1, tag!("r1"));
named!(r2, tag!("r2"));
named!(r3, tag!("r3"));
named!(r4, tag!("r4"));
named!(r5, tag!("r5"));
named!(r6, tag!("r6"));
named!(r7, tag!("r7"));
named!(r8, tag!("r8"));
named!(r9, tag!("r9"));
named!(r10, tag!("r10"));
named!(r11, tag!("r11"));
named!(r12, tag!("r12"));
named!(r13, tag!("r13"));
named!(r14, tag!("r14"));
const REGS: [for<'r> fn(
    &'r [u8],
) -> std::result::Result<
    (&'r [u8], &'r [u8]),
    nom::Err<(&'r [u8], nom::error::ErrorKind)>,
>; 15] = [
    r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, rsp,
];

//fn parse(input: &[u8]) -> IResult<&[u8], IComplie> {
//let (input, symbol): (&[u8], Option<&[u8]>) = match symbol(input) {
//Ok((input, symbol)) => (input, Some(symbol)),
//Err(nom::Err::Error((input, _))) => (input, None),
//};
//if symbol.is_none() {
//let (input, method) = method(input)?;
//let (input, _) = space(input)?;
//}
//unimplemented!();
//}

fn parse_reg(input: &[u8]) -> IResult<&[u8], u8> {
    let (input, _) = tag("%")(input)?;
    for (i, reg) in REGS.iter().enumerate() {
        match reg(input) {
            Ok((input, _)) => return Ok((input, i.try_into().unwrap())),
            _ => (),
        };
    }
    return Err(nom::Err::Failure((input, nom::error::ErrorKind::NoneOf)));
}

fn parse_val(input: &[u8]) -> IResult<&[u8], u16> {
    let (input, (_, value)) = tuple((tag("$"), digit0))(input)?;
    let value = std::str::from_utf8(value)
        .unwrap()
        .parse::<u16>()
        .ok()
        .unwrap();
    return Ok((input, value));
}

fn parse_val_and_reg(input: &[u8]) -> IResult<&[u8], (u16, u8)> {
    let (input, (value, _, reg, _)) = tuple((digit0, tag("("), parse_reg, tag(")")))(input)?;
    let value = std::str::from_utf8(value)
        .unwrap()
        .parse::<u16>()
        .ok()
        .unwrap();
    return Ok((input, (value, reg)));
}

fn parse_jxx_call(input: &[u8]) -> IResult<&[u8], AST> {
    let (input, (method, _, symbol)) = tuple((method, space0, method))(input)?;
    let iorder = match method {
        b"JMP" | b"jmp" => IOrder::JMP,
        b"JE" | b"je" => IOrder::JE,
        b"JNE" | b"jne" => IOrder::JNE,
        b"JS" | b"js" => IOrder::JS,
        b"JNS" | b"jns" => IOrder::JNS,
        b"JG" | b"jg" => IOrder::JG,
        b"JGE" | b"jge" => IOrder::JGE,
        b"JL" | b"jl" => IOrder::JL,
        b"JLE" | b"jle" => IOrder::JLE,
        b"JA" | b"ja" => IOrder::JA,
        b"JAE" | b"jae" => IOrder::JAE,
        b"JB" | b"jb" => IOrder::JB,
        b"JBE" | b"jbe" => IOrder::JBE,
        b"CALL" | b"call" => IOrder::CALL,
        _ => return Err(nom::Err::Error((input, nom::error::ErrorKind::Tag))),
    };
    return Ok((
        input,
        AST::Order(IComplie {
            iorder: iorder,
            symbol: Some(symbol),
            len: 3,
            ..IComplie::default()
        }),
    ));
}

fn parse_out(input: &[u8]) -> IResult<&[u8], AST> {
    let (input, (method, _, valA)) = tuple((method, space0, parse_reg))(input)?;
    let iorder = match method {
        b"OUT" | b"out" => IOrder::OUT,
        _ => return Err(nom::Err::Error((input, nom::error::ErrorKind::Tag))),
    };
    return Ok((
        input,
        AST::Order(IComplie {
            iorder: iorder,
            len: 2,
            r_a: valA,
            ..IComplie::default()
        }),
    ));
}

fn parse_ret_nop_halt(input: &[u8]) -> IResult<&[u8], AST> {
    let (input, method) = method(input)?;
    let iorder = match method {
        b"HALT" | b"halt" => IOrder::HALT,
        b"NOP" | b"nop" => IOrder::NOP,
        b"RET" | b"ret" => IOrder::RET,
        b"IRET" | b"iret" => IOrder::IRET,
        _ => return Err(nom::Err::Error((input, nom::error::ErrorKind::Tag))),
    };
    return Ok((
        input,
        AST::Order(IComplie {
            iorder: iorder,
            len: 1,
            ..IComplie::default()
        }),
    ));
}

fn parse_opq_rrmovq(input: &[u8]) -> IResult<&[u8], AST> {
    let (input, (method, _, r_a, _, r_b)) =
        tuple((method, space0, parse_reg, tag(","), parse_reg))(input)?;
    let iorder = match method {
        b"ADDQ" | b"addq" => IOrder::ADDQ,
        b"SUBQ" | b"subq" => IOrder::SUBQ,
        b"MULQ" | b"mulq" => IOrder::MULQ,
        b"DIVQ" | b"divq" => IOrder::DIVQ,
        b"ANDQ" | b"andq" => IOrder::ANDQ,
        b"ORQ" | b"orq" => IOrder::ORQ,
        b"XORQ" | b"xorq" => IOrder::XORQ,
        b"RRMOVQ" | b"rrmovq" => IOrder::RRMOVQ,
        _ => return Err(nom::Err::Error((input, nom::error::ErrorKind::Tag))),
    };
    return Ok((
        input,
        AST::Order(IComplie {
            iorder,
            r_a,
            r_b,
            len: 2,
            ..IComplie::default()
        }),
    ));
}

fn parse_irmovq(input: &[u8]) -> IResult<&[u8], AST> {
    let (input, (_, _, val_c, _, r_b)) =
        tuple((method, space0, parse_val, tag(","), parse_reg))(input)?;
    return Ok((
        input,
        AST::Order(IComplie {
            iorder: IOrder::IRMOVQ,
            val_c,
            r_b,
            len: 4,
            ..IComplie::default()
        }),
    ));
}

fn parse_irmovq_symbol(input: &[u8]) -> IResult<&[u8], AST> {
    let (input, (_, _, symbol, _, r_b)) =
        tuple((tag("irmovq"), space0, method, tag(","), parse_reg))(input)?;
    return Ok((
        input,
        AST::Order(IComplie {
            iorder: IOrder::IRMOVQ,
            symbol: Some(symbol),
            r_b,
            len: 4,
            ..IComplie::default()
        }),
    ));
}

fn parse_mrmovq(input: &[u8]) -> IResult<&[u8], AST> {
    let (input, (_, _, (val_c, r_b), _, r_a)) =
        tuple((method, space0, parse_val_and_reg, tag(","), parse_reg))(input)?;
    return Ok((
        input,
        AST::Order(IComplie {
            iorder: IOrder::MRMOVQ,
            val_c,
            r_b,
            r_a,
            len: 4,
            ..IComplie::default()
        }),
    ));
}

fn parse_rmmovq(input: &[u8]) -> IResult<&[u8], AST> {
    let (input, (_, _, r_a, _, (val_c, r_b))) =
        tuple((method, space0, parse_reg, tag(","), parse_val_and_reg))(input)?;
    return Ok((
        input,
        AST::Order(IComplie {
            iorder: IOrder::RMMOVQ,
            val_c,
            r_b,
            r_a,
            len: 4,
            ..IComplie::default()
        }),
    ));
}

fn parse_order(input: &[u8]) -> IResult<&[u8], AST> {
    return alt((
        dbg_dmp(parse_irmovq, "parse_irmovq"),
        dbg_dmp(parse_irmovq_symbol, "parse_irmovq_symbol"),
        parse_opq_rrmovq,
        parse_rmmovq,
        parse_mrmovq,
        parse_jxx_call,
        parse_ret_nop_halt,
        parse_out,
    ))(input);
}

fn parse_point(input: &[u8]) -> IResult<&[u8], AST> {
    let (input, (_, _, val)) = tuple((tag(".pos"), space0, digit0))(input)?;
    let val = std::str::from_utf8(val)
        .unwrap()
        .parse::<u16>()
        .ok()
        .unwrap();
    return Ok((input, AST::Pos(val)));
}

fn parse_quad(input: &[u8]) -> IResult<&[u8], AST> {
    let (input, (_, _, val_c)) = tuple((tag(".quad"), space0, digit0))(input)?;
    let val_c = std::str::from_utf8(val_c)
        .unwrap()
        .parse::<u16>()
        .ok()
        .unwrap();
    return Ok((
        input,
        AST::Order(IComplie {
            iorder: IOrder::CONST,
            val_c,
            len: 2,
            ..IComplie::default()
        }),
    ));
}

fn parse_symbol(input: &[u8]) -> IResult<&[u8], AST> {
    let (input, symbol) = take_until(":")(input)?;
    return Ok((input, AST::Symbol(symbol)));
}

pub fn parse(input: &[u8]) -> IResult<&[u8], AST> {
    let (input, (_, ast)) = tuple((
        space0,
        alt((parse_point, parse_quad, parse_symbol, parse_order)),
    ))(input)?;
    return Ok((input, ast));
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_halt_test() {
        let answer: IResult<&[u8], AST> = Ok((
            b"\n",
            AST::Order(IComplie {
                iorder: IOrder::HALT,
                len: 1,
                ..IComplie::default()
            }),
        ));
        assert_eq!(parse(b"   halt\n"), answer)
    }

    #[test]
    fn parse_nop_test() {
        let answer: IResult<&[u8], AST> = Ok((
            b"\n",
            AST::Order(IComplie {
                iorder: IOrder::NOP,
                len: 1,
                ..IComplie::default()
            }),
        ));
        assert_eq!(parse(b"   nop\n"), answer)
    }

    #[test]
    fn parse_irmovq_test() {
        let answer: IResult<&[u8], AST> = Ok((
            b"\n",
            AST::Order(IComplie {
                iorder: IOrder::IRMOVQ,
                val_c: 3456,
                r_b: 0,
                len: 10,
                ..IComplie::default()
            }),
        ));
        assert_eq!(parse(b" irmovq $123456,%r1\n"), answer)
    }

    #[test]
    fn parse_mrmovq_test() {
        let answer: IResult<&[u8], AST> = Ok((
            b"\n",
            AST::Order(IComplie {
                iorder: IOrder::MRMOVQ,
                val_c: 9,
                r_a: 0,
                r_b: 1,
                len: 10,
                ..IComplie::default()
            }),
        ));
        assert_eq!(parse(b"mrmovq 9(%r2),%r1\n"), answer)
    }

    #[test]
    fn parse_rmmovq_test() {
        let answer: IResult<&[u8], AST> = Ok((
            b"\n",
            AST::Order(IComplie {
                iorder: IOrder::RMMOVQ,
                val_c: 9,
                r_a: 0,
                r_b: 1,
                len: 10,
                ..IComplie::default()
            }),
        ));
        assert_eq!(parse(b"rmmovq %r1,9(%r2)\n"), answer)
    }

    #[test]
    fn parse_rrmovq_test() {
        let answer: IResult<&[u8], AST> = Ok((
            b"\n",
            AST::Order(IComplie {
                iorder: IOrder::RRMOVQ,
                r_a: 0,
                r_b: 1,
                len: 2,
                ..IComplie::default()
            }),
        ));
        assert_eq!(parse(b"rrmovq %r1,%r2\n"), answer)
    }

    #[test]
    fn parse_ret_test() {
        let answer: IResult<&[u8], AST> = Ok((
            b"\n",
            AST::Order(IComplie {
                iorder: IOrder::RET,
                len: 1,
                ..IComplie::default()
            }),
        ));
        assert_eq!(parse(b"   ret\n"), answer)
    }

    #[test]
    fn parse_pos_test() {
        let answer: IResult<&[u8], AST> = Ok((b"\n", AST::Pos(87)));
        assert_eq!(parse(b"   .pos 87\n"), answer)
    }

    #[test]
    fn parse_symbol_test() {
        let answer: IResult<&[u8], AST> = Ok((b":\n", AST::Symbol(b"Stack")));
        assert_eq!(parse(b"Stack:\n"), answer)
    }

    #[test]
    fn parse_call_test() {
        let answer: IResult<&[u8], AST> = Ok((
            b"\n",
            AST::Order(IComplie {
                iorder: IOrder::CALL,
                symbol: Some(b"main"),
                len: 9,
                ..IComplie::default()
            }),
        ));
        assert_eq!(parse(b" call main\n"), answer)
    }
}
