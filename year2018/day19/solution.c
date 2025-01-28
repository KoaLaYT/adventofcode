#include "../lib/kt.h"
#include "../lib/re.h"

#define OP_TOTAL 16
#define REG_SIZE 6

typedef enum {
    // addition
    op_addr,
    op_addi,

    // multiplication
    op_mulr,
    op_muli,

    // bitwise AND
    op_banr,
    op_bani,

    // bitwise OR
    op_borr,
    op_bori,

    // assignment
    op_setr,
    op_seti,

    // greater-than testing
    op_gtir,
    op_gtri,
    op_gtrr,

    // equality testing
    op_eqir,
    op_eqri,
    op_eqrr,
} opcode_t;

typedef struct {
    opcode_t type;
    i32 a, b, c;
} instruction_t;

typedef struct {
    instruction_t* inst;
    i32 len;

    i32* regs;
    i32 bound;
    i32 pc;
} device_t;

static opcode_t opcode_from(const char* s)
{
#define MAYBE(code) \
    if (strncmp(s, #code, 4) == 0) return op_##code

    MAYBE(addr);
    MAYBE(addi);

    MAYBE(mulr);
    MAYBE(muli);

    MAYBE(banr);
    MAYBE(bani);

    MAYBE(borr);
    MAYBE(bori);

    MAYBE(setr);
    MAYBE(seti);

    MAYBE(gtir);
    MAYBE(gtri);
    MAYBE(gtrr);

    MAYBE(eqir);
    MAYBE(eqri);
    MAYBE(eqrr);

#undef MAYBE

    ASSERT_MSG(0, "unknown opcode %s", s);
}

static instruction_t instruction_from(const char* s)
{
    opcode_t type = opcode_from(s);

    re_t pattern = re_compile("\\d+");
    i32 len, v[3];
    for (i32 i = 0; i < 3; i++) {
        s += re_matchp(pattern, s, &len);
        v[i] = kt_atoi_s(s, len);
        s += len;
    }

    instruction_t inst;
    inst.type = type;
    inst.a = v[0];
    inst.b = v[1];
    inst.c = v[2];
    return inst;
}

typedef void (*opcode_exec_fn)(instruction_t ins, i32* regs);

#define ASSERT_OPTYPE(expect, got)                                            \
    ASSERT_MSG(expect == got, "mismatched opcode, expect %d, got %d", expect, \
               got);

static void op_addr_exec(instruction_t ins, i32* regs)
{
    ASSERT_OPTYPE(op_addr, ins.type);
    i32 rav = regs[ins.a];
    i32 rbv = regs[ins.b];
    regs[ins.c] = rav + rbv;
}

static void op_addi_exec(instruction_t ins, i32* regs)
{
    ASSERT_OPTYPE(op_addi, ins.type);
    i32 rav = regs[ins.a];
    regs[ins.c] = rav + ins.b;
}

static void op_mulr_exec(instruction_t ins, i32* regs)
{
    ASSERT_OPTYPE(op_mulr, ins.type);
    i32 rav = regs[ins.a];
    i32 rbv = regs[ins.b];
    regs[ins.c] = rav * rbv;
}

static void op_muli_exec(instruction_t ins, i32* regs)
{
    ASSERT_OPTYPE(op_muli, ins.type);
    i32 rav = regs[ins.a];
    regs[ins.c] = rav * ins.b;
}

static void op_banr_exec(instruction_t ins, i32* regs)
{
    ASSERT_OPTYPE(op_banr, ins.type);
    i32 rav = regs[ins.a];
    i32 rbv = regs[ins.b];
    regs[ins.c] = rav & rbv;
}

static void op_bani_exec(instruction_t ins, i32* regs)
{
    ASSERT_OPTYPE(op_bani, ins.type);
    i32 rav = regs[ins.a];
    regs[ins.c] = rav & ins.b;
}

static void op_borr_exec(instruction_t ins, i32* regs)
{
    ASSERT_OPTYPE(op_borr, ins.type);
    i32 rav = regs[ins.a];
    i32 rbv = regs[ins.b];
    regs[ins.c] = rav | rbv;
}

static void op_bori_exec(instruction_t ins, i32* regs)
{
    ASSERT_OPTYPE(op_bori, ins.type);
    i32 rav = regs[ins.a];
    regs[ins.c] = rav | ins.b;
}

static void op_setr_exec(instruction_t ins, i32* regs)
{
    ASSERT_OPTYPE(op_setr, ins.type);
    i32 rav = regs[ins.a];
    regs[ins.c] = rav;
}

static void op_seti_exec(instruction_t ins, i32* regs)
{
    ASSERT_OPTYPE(op_seti, ins.type);
    regs[ins.c] = ins.a;
}

static void op_gtir_exec(instruction_t ins, i32* regs)
{
    ASSERT_OPTYPE(op_gtir, ins.type);
    i32 rbv = regs[ins.b];
    regs[ins.c] = ins.a > rbv ? 1 : 0;
}

static void op_gtri_exec(instruction_t ins, i32* regs)
{
    ASSERT_OPTYPE(op_gtri, ins.type);
    i32 rav = regs[ins.a];
    regs[ins.c] = rav > ins.b ? 1 : 0;
}

static void op_gtrr_exec(instruction_t ins, i32* regs)
{
    ASSERT_OPTYPE(op_gtrr, ins.type);
    i32 rav = regs[ins.a];
    i32 rbv = regs[ins.b];
    regs[ins.c] = rav > rbv ? 1 : 0;
}

static void op_eqir_exec(instruction_t ins, i32* regs)
{
    ASSERT_OPTYPE(op_eqir, ins.type);
    i32 rbv = regs[ins.b];
    regs[ins.c] = ins.a == rbv ? 1 : 0;
}

static void op_eqri_exec(instruction_t ins, i32* regs)
{
    ASSERT_OPTYPE(op_eqri, ins.type);
    i32 rav = regs[ins.a];
    regs[ins.c] = rav == ins.b ? 1 : 0;
}

static void op_eqrr_exec(instruction_t ins, i32* regs)
{
    ASSERT_OPTYPE(op_eqrr, ins.type);
    i32 rav = regs[ins.a];
    i32 rbv = regs[ins.b];
    regs[ins.c] = rav == rbv ? 1 : 0;
}

static opcode_exec_fn opcode_fns[OP_TOTAL] = {
    op_addr_exec, op_addi_exec, op_mulr_exec, op_muli_exec,
    op_banr_exec, op_bani_exec, op_borr_exec, op_bori_exec,
    op_setr_exec, op_seti_exec, op_gtir_exec, op_gtri_exec,
    op_gtrr_exec, op_eqir_exec, op_eqri_exec, op_eqrr_exec,
};

static i32 parse_ip(const char* s)
{
    re_t pattern = re_compile("\\d+");
    i32 len;

    s += re_matchp(pattern, s, &len);
    return kt_atoi(s);
}

static device_t device_init(void* arena, const char* input_file)
{
    void* scanner = kt_scanner_init(input_file);
    const char* line;
    i32 len = 0;

    kt_scanner_next(scanner, '\n');  // skip first row
    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        len += 1;
    }
    kt_scanner_reset(scanner);

    instruction_t* inst = kt_linear_arena_array(arena, instruction_t, len);
    i32* regs = kt_linear_arena_array_zero(arena, i32, REG_SIZE);
    len = 0;

    line = kt_scanner_next(scanner, '\n');
    i32 bound = parse_ip(line);
    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        inst[len++] = instruction_from(line);
    }
    kt_scanner_deinit(scanner);

    device_t d;
    d.inst = inst;
    d.len = len;
    d.regs = regs;
    d.bound = bound;
    d.pc = 0;
    return d;
}

static void device_exec(device_t* d)
{
    while (d->pc < d->len) {
        instruction_t inst = d->inst[d->pc];
        d->regs[d->bound] = d->pc;
        opcode_fns[inst.type](inst, d->regs);
        d->pc = d->regs[d->bound] + 1;
    }
}

i32 register0(const char* input_file)
{
    void* arena = kt_linear_arena_init(1024 * 1024);
    device_t d = device_init(arena, input_file);
    device_exec(&d);
    i32 result = d.regs[0];
    kt_linear_arena_deinit(arena);
    return result;
}

i32 register02(const char* input_file)
{
    i32 target = 10551347;
    i32 result = 0;

    for (i32 i = 1; i <= target; i++) {
        if (target % i == 0) {
            result += i;
        }
    }

    return result;
}
