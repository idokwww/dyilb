#ifndef kfd_h
#define kfd_h

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>

bool kfd_initialize(void);
bool kfd_get_kernel_access(void);
bool kfd_read_kernel_memory(uint64_t addr, uint8_t *buffer, int size);
bool kfd_write_kernel_memory(uint64_t addr, uint8_t *buffer, int size);
uint64_t kfd_get_proc_struct(int pid);
uint64_t kfd_get_syscall_table(void);
uint64_t kfd_get_vfs_mount_table(void);
uint64_t kfd_get_sandbox_policy(int pid);
char *kfd_get_environment_variable(const char *name);

#endif /* kfd_h */