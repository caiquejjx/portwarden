#ifndef LIB_H
#define LIB_H

#include <stddef.h>
#include <stdint.h>

typedef struct {
    int32_t pid;
    uint16_t port;
    uint8_t name[128];
    uint8_t name_len;
} PidInfo;

const PidInfo* get_ports(size_t* out_len);

void scanner_init();
void scanner_deinit();

#endif
