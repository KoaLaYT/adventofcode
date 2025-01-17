#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#include "kt.h"

#define CAP 1024

typedef struct {
    int fd;
    int p;
    int len;
} kt_scanner;

void* kt_scanner_init(const char* filename)
{
    int fd = open(filename, O_RDONLY);
    if (fd < 0) {
        perror("open");
        exit(1);
    }

    void* mem = kt_malloc(sizeof(kt_scanner) + CAP);
    memset(mem, 0, sizeof(kt_scanner) + CAP);
    if (mem == NULL) {
        perror("malloc");
        exit(1);
    }

    int* header = (int*)mem;
    header[0] = fd;

    return mem;
}

void kt_scanner_deinit(void* self)
{
    int* header = (int*)self;
    int fd = header[0];
    if (close(fd) != 0) {
        perror("close");
        exit(1);
    }
    free(self);
}

void kt_scanner_reset(void* self)
{
    kt_scanner* scanner = self;
    if (lseek(scanner->fd, 0, SEEK_SET) < 0) {
        perror("lseek");
        exit(1);
    }
    scanner->p = 0;
    scanner->len = 0;
}

const char* kt_scanner_next(void* self, char delimiter)
{
    char* buf = (char*)self + sizeof(kt_scanner);
    kt_scanner* scanner = self;

    for (int i = scanner->p; i < scanner->len; i++) {
        if (buf[i] == '\0' && i == scanner->p) {
            return 0;
        }

        if (buf[i] == delimiter || buf[i] == '\0') {
            buf[i] = '\0';
            const char* line = buf + scanner->p;
            scanner->p = i + 1;
            return line;
        }
    }

    size_t left = scanner->len - scanner->p;
    if (left == CAP) {
        fprintf(stderr, "buf overflow");
        exit(1);
    }

    if (scanner->p != 0 && left > 0) {
        memmove(buf, buf + scanner->p, left);
    }

    ssize_t n = read(scanner->fd, buf + left, CAP - left);
    if (n < 0) {
        perror("read");
        exit(1);
    }

    scanner->p = 0;
    scanner->len = left + n;

    if (n == 0) {
        buf[left] = '\0';
        scanner->len += 1;
    }

    return kt_scanner_next(self, delimiter);
}

static off_t get_file_size(int fd)
{
    struct stat st;
    if (fstat(fd, &st) < 0) {
        perror("fstat");
        exit(1);
    }
    if (S_ISREG(st.st_mode)) return st.st_size;
    fprintf(stderr, "unknown file mode %d\n", st.st_mode);
    exit(1);
}

char* kt_read_all(const char* filename)
{
    int fd = open(filename, O_RDONLY);
    if (fd < 0) {
        perror("open");
        exit(1);
    }

    off_t size = get_file_size(fd);
    char* buf = kt_malloc(size + 1);

    ssize_t n = read(fd, buf, size);
    if (n < 0) {
        perror("read");
        exit(1);
    }
    for (int i = n - 1; i >= 0; i--) {
        if (buf[i] != '\n') break;

        buf[i] = 0;
    }
    buf[n] = 0;

    return buf;
}
