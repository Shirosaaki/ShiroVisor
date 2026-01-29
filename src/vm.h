/**==============================================
 *                 vm.h
 *  file header for vm
 *  Author: Shirosaaki
 *  Date: 2026-01-29
 *=============================================**/

#ifndef VM_H_
    #define VM_H_
    #include <stdint.h>
    #include <linux/kvm.h>

// Configuration
#define RAM_SIZE 0x100000 // 1MB

typedef struct {
    int kvm_fd;              // File descriptor of /dev/kvm
    int vm_fd;               // File descriptor of the VM
    int vcpu_fd;             // File descriptor of the vCPU
    uint8_t *ram;            // Pointer to the guest RAM (host user-space)
    struct kvm_run *run;     // Shared structure with the kernel
} vm_t;

// Init of the VM
void vm_init(vm_t *vm);
void vm_load_image(vm_t *vm, const char *filename);

// Init of the CPU
void vcpu_init(vm_t *vm);

// Start execution
void vcpu_run(vm_t *vm);

#endif /* !VM_H_ */
