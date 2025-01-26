#include "../lib/kt.h"
#include "../lib/re.h"

#define SIZE 4
#define BUF_SIZE 128
#define OP_TOTAL 16

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
    int a, b, c;
} instruction_t;

static instruction_t instruction_from(const int* codes)
{
    instruction_t ins;
    ins.type = codes[0];
    ins.a = codes[1];
    ins.b = codes[2];
    ins.c = codes[3];
    return ins;
}

typedef void (*opcode_exec_fn)(instruction_t ins, int* regs);

#define ASSERT_OPTYPE(expect, got)                                            \
    ASSERT_MSG(expect == got, "mismatched opcode, expect %d, got %d", expect, \
               got);

static void op_addr_exec(instruction_t ins, int* regs)
{
    ASSERT_OPTYPE(op_addr, ins.type);
    int rav = regs[ins.a];
    int rbv = regs[ins.b];
    regs[ins.c] = rav + rbv;
}

static void op_addi_exec(instruction_t ins, int* regs)
{
    ASSERT_OPTYPE(op_addi, ins.type);
    int rav = regs[ins.a];
    regs[ins.c] = rav + ins.b;
}

static void op_mulr_exec(instruction_t ins, int* regs)
{
    ASSERT_OPTYPE(op_mulr, ins.type);
    int rav = regs[ins.a];
    int rbv = regs[ins.b];
    regs[ins.c] = rav * rbv;
}

static void op_muli_exec(instruction_t ins, int* regs)
{
    ASSERT_OPTYPE(op_muli, ins.type);
    int rav = regs[ins.a];
    regs[ins.c] = rav * ins.b;
}

static void op_banr_exec(instruction_t ins, int* regs)
{
    ASSERT_OPTYPE(op_banr, ins.type);
    int rav = regs[ins.a];
    int rbv = regs[ins.b];
    regs[ins.c] = rav & rbv;
}

static void op_bani_exec(instruction_t ins, int* regs)
{
    ASSERT_OPTYPE(op_bani, ins.type);
    int rav = regs[ins.a];
    regs[ins.c] = rav & ins.b;
}

static void op_borr_exec(instruction_t ins, int* regs)
{
    ASSERT_OPTYPE(op_borr, ins.type);
    int rav = regs[ins.a];
    int rbv = regs[ins.b];
    regs[ins.c] = rav | rbv;
}

static void op_bori_exec(instruction_t ins, int* regs)
{
    ASSERT_OPTYPE(op_bori, ins.type);
    int rav = regs[ins.a];
    regs[ins.c] = rav | ins.b;
}

static void op_setr_exec(instruction_t ins, int* regs)
{
    ASSERT_OPTYPE(op_setr, ins.type);
    int rav = regs[ins.a];
    regs[ins.c] = rav;
}

static void op_seti_exec(instruction_t ins, int* regs)
{
    ASSERT_OPTYPE(op_seti, ins.type);
    regs[ins.c] = ins.a;
}

static void op_gtir_exec(instruction_t ins, int* regs)
{
    ASSERT_OPTYPE(op_gtir, ins.type);
    int rbv = regs[ins.b];
    regs[ins.c] = ins.a > rbv ? 1 : 0;
}

static void op_gtri_exec(instruction_t ins, int* regs)
{
    ASSERT_OPTYPE(op_gtri, ins.type);
    int rav = regs[ins.a];
    regs[ins.c] = rav > ins.b ? 1 : 0;
}

static void op_gtrr_exec(instruction_t ins, int* regs)
{
    ASSERT_OPTYPE(op_gtrr, ins.type);
    int rav = regs[ins.a];
    int rbv = regs[ins.b];
    regs[ins.c] = rav > rbv ? 1 : 0;
}

static void op_eqir_exec(instruction_t ins, int* regs)
{
    ASSERT_OPTYPE(op_eqir, ins.type);
    int rbv = regs[ins.b];
    regs[ins.c] = ins.a == rbv ? 1 : 0;
}

static void op_eqri_exec(instruction_t ins, int* regs)
{
    ASSERT_OPTYPE(op_eqri, ins.type);
    int rav = regs[ins.a];
    regs[ins.c] = rav == ins.b ? 1 : 0;
}

static void op_eqrr_exec(instruction_t ins, int* regs)
{
    ASSERT_OPTYPE(op_eqrr, ins.type);
    int rav = regs[ins.a];
    int rbv = regs[ins.b];
    regs[ins.c] = rav == rbv ? 1 : 0;
}

static opcode_exec_fn opcode_fns[OP_TOTAL] = {
    op_addr_exec, op_addi_exec, op_mulr_exec, op_muli_exec,
    op_banr_exec, op_bani_exec, op_borr_exec, op_bori_exec,
    op_setr_exec, op_seti_exec, op_gtir_exec, op_gtri_exec,
    op_gtrr_exec, op_eqir_exec, op_eqri_exec, op_eqrr_exec,
};

static b8 regs_equal(const int* r1, const int* r2)
{
    for (int i = 0; i < SIZE; i++) {
        if (r1[i] != r2[i]) {
            return FALSE;
        }
    }
    return TRUE;
}

static void count_behaves_impl(const int* regs_before,  //
                               const int* regs_after,   //
                               const int* codes,        //
                               int* counts)             //
{
    int regs_copy[SIZE];
    instruction_t ins = instruction_from(codes);

    for (int i = 0; i < OP_TOTAL; i++) {
        memcpy(regs_copy, regs_before, sizeof(int) * SIZE);
        ins.type = i;
        opcode_fns[i](ins, regs_copy);
        if (regs_equal(regs_copy, regs_after)) {
            counts[i] += 1;
        }
    }
}

static instruction_t parse_instruction(const char* s)
{
    re_t pattern = re_compile("\\d+");
    int len;

    int codes[SIZE];
    for (int i = 0; i < SIZE; i++) {
        s += re_matchp(pattern, s, &len);
        codes[i] = kt_atoi_s(s, len);
        s += len;
    }

    return instruction_from(codes);
}

static void parse_sample(const char* before,   //
                         const char* opcodes,  //
                         const char* after,    //
                         int* regs_before, int* codes, int* regs_after)
{
    re_t pattern = re_compile("\\d+");
    int len;

    for (int i = 0; i < SIZE; i++) {
        before += re_matchp(pattern, before, &len);
        regs_before[i] = kt_atoi_s(before, len);
        before += len;
    }

    for (int i = 0; i < SIZE; i++) {
        opcodes += re_matchp(pattern, opcodes, &len);
        codes[i] = kt_atoi_s(opcodes, len);
        opcodes += len;
    }

    for (int i = 0; i < SIZE; i++) {
        after += re_matchp(pattern, after, &len);
        regs_after[i] = kt_atoi_s(after, len);
        after += len;
    }
}

static void guess_opcodes(int counts[OP_TOTAL][OP_TOTAL], int* rels)
{
    for (int i = 0; i < OP_TOTAL; i++) {
        rels[i] = -1;
    }
    int left = OP_TOTAL;

    for (;;) {
        for (int i = 0; i < OP_TOTAL; i++) {
            if (rels[i] >= 0) continue;
            int dup = 0;
            int idx = 0;
            for (int j = 0; j < OP_TOTAL; j++) {
                int v = counts[i][j];
                if (v > 0) {
                    dup += 1;
                    idx = j;
                }
            }
            if (dup == 1) {
                rels[i] = idx;
                left -= 1;
                for (int i = 0; i < OP_TOTAL; i++) {
                    counts[i][idx] = 0;
                }
                break;
            }
        }
        if (left == 0) break;
    }
}

int count_behaves(const char* input_file)
{
    void* scanner = kt_scanner_init(input_file);

    const char* line;
    int i = 0;

    char before[BUF_SIZE];
    char opcodes[BUF_SIZE];
    char after[BUF_SIZE];

    int regs_before[SIZE];
    int codes[SIZE];
    int regs_after[SIZE];
    int counts[OP_TOTAL];

    int count = 0;

    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        if (*line == 0) {
            if (i == 3) {
                i = 0;
                continue;
            }
            break;
        }

        if (i == 0) {
            strcpy(before, line);
        }
        if (i == 1) {
            strcpy(opcodes, line);
        }
        if (i == 2) {
            strcpy(after, line);
            memset(counts, 0, sizeof(int) * OP_TOTAL);
            parse_sample(before, opcodes, after,  //
                         regs_before, codes, regs_after);
            count_behaves_impl(regs_before, regs_after, codes, counts);
            int v = 0;
            for (int i = 0; i < OP_TOTAL; i++) {
                if (counts[i] > 0) {
                    v += 1;
                }
            }
            if (v >= 3) {
                count += 1;
            }
        }

        i += 1;
    }
    kt_scanner_deinit(scanner);

    return count;
}

int exec_program(const char* input_file)
{
    void* scanner = kt_scanner_init(input_file);

    const char* line;
    int i = 0;

    char before[BUF_SIZE];
    char opcodes[BUF_SIZE];
    char after[BUF_SIZE];

    int regs_before[SIZE];
    int codes[SIZE];
    int regs_after[SIZE];
    int counts[OP_TOTAL][OP_TOTAL] = {0};

    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        if (*line == 0) {
            if (i == 3) {
                i = 0;
                continue;
            }
            break;
        }

        if (i == 0) {
            strcpy(before, line);
        }
        if (i == 1) {
            strcpy(opcodes, line);
        }
        if (i == 2) {
            strcpy(after, line);
            parse_sample(before, opcodes, after,  //
                         regs_before, codes, regs_after);
            count_behaves_impl(regs_before, regs_after, codes,
                               counts[codes[0]]);
        }

        i += 1;
    }

    // opcode value -> opcode enum
    int rels[OP_TOTAL];
    guess_opcodes(counts, rels);

    int regs[SIZE] = {0};
    while ((line = kt_scanner_next(scanner, '\n')) != 0) {
        if (*line == 0) continue;
        instruction_t ins = parse_instruction(line);
        ins.type = rels[ins.type];
        opcode_fns[ins.type](ins, regs);
    }

    kt_scanner_deinit(scanner);

    return regs[0];
}
