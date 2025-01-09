#pragma once

void* kt_scanner_init(const char* filename);
void kt_scanner_deinit(void* self);
const char* kt_scanner_next(void* self, char delimiter);
