/**==============================================
 *                 vcpu.c
 *  file where function for emulate a cpu will be
 *  Author: Shirosaaki
 *  Date: 2026-01-29
 *=============================================**/

#include "vm.h"
#include <stdio.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <sys/mman.h>

extern void err_exit(const char *msg);

void vcpu_init(vm_t *vm) {
    // 1. Make the vCPU
    vm->vcpu_fd = ioctl(vm->vm_fd, KVM_CREATE_VCPU, 0);
    if (vm->vcpu_fd < 0) err_exit("KVM_CREATE_VCPU failed");

    // 2. Map the shared kvm_run structure
    int mmap_size = ioctl(vm->kvm_fd, KVM_GET_VCPU_MMAP_SIZE, 0);
    if (mmap_size < 0) err_exit("KVM_GET_VCPU_MMAP_SIZE failed");

    vm->run = mmap(NULL, mmap_size, PROT_READ | PROT_WRITE, MAP_SHARED, vm->vcpu_fd, 0);
    if (vm->run == MAP_FAILED) err_exit("mmap kvm_run failed");

    // 3. Configure the CPU in Real Mode
    struct kvm_sregs sregs;
    if (ioctl(vm->vcpu_fd, KVM_GET_SREGS, &sregs) < 0) err_exit("KVM_GET_SREGS failed");

    sregs.cs.base = 0; sregs.cs.selector = 0;
    sregs.ds.base = 0; sregs.ds.selector = 0;
    sregs.es.base = 0; sregs.es.selector = 0;
    sregs.ss.base = 0; sregs.ss.selector = 0;
    sregs.fs.base = 0; sregs.fs.selector = 0;
    sregs.gs.base = 0; sregs.gs.selector = 0;

    // KVM demande souvent que ces flags soient mis même en mode réel
    sregs.cs.type = 11; sregs.cs.s = 1; // Code segment
    sregs.ds.type = 3;  sregs.ds.s = 1; // Data segment
    sregs.ss.type = 3;  sregs.ss.s = 1; // Stack segment

    struct kvm_regs regs = {
        .rip = 0,
        .rflags = 0x2,
    };

    // --- On envoie TOUT au kernel ---
    if (ioctl(vm->vcpu_fd, KVM_SET_SREGS, &sregs) < 0) err_exit("KVM_SET_SREGS failed");
    if (ioctl(vm->vcpu_fd, KVM_SET_REGS, &regs) < 0) err_exit("KVM_SET_REGS failed");
    
    printf("[VCPU] Initialized in 16-bit Real Mode.\n");
}

void vcpu_run(vm_t *vm) {
    printf("[VCPU] Starting execution loop...\n");
    
    while (1) {
        int ret = ioctl(vm->vcpu_fd, KVM_RUN, 0);
        if (ret < 0) err_exit("KVM_RUN failed");

        switch (vm->run->exit_reason) {
            case KVM_EXIT_IO:
                if (vm->run->io.direction == KVM_EXIT_IO_OUT && vm->run->io.port == 0x10) {
                    char *data = (char *)((uint8_t *)vm->run + vm->run->io.data_offset);
                    printf("%c", *data);
                    fflush(stdout);
                } else {
                    fprintf(stderr, "[KVM_EXIT_IO] direction=%s port=0x%x size=%u count=%u\n",
                        vm->run->io.direction == KVM_EXIT_IO_OUT ? "OUT" : "IN",
                        vm->run->io.port,
                        vm->run->io.size,
                        vm->run->io.count);
                    fflush(stderr);
                }
                // Continue the loop for unhandled I/O
                break;

            case KVM_EXIT_HLT:
                return;

            case KVM_EXIT_FAIL_ENTRY:
                fprintf(stderr, "KVM_EXIT_FAIL_ENTRY: hardware reason 0x%llx\n",
                    (unsigned long long)vm->run->fail_entry.hardware_entry_failure_reason);
                return;

            default:
                fprintf(stderr, "Unhandled VM Exit: %d\n", vm->run->exit_reason);
                return;
        }
    }
}
