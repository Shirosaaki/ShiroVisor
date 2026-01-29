/**==============================================
 *                 vm.c
 *  file where utils for the vm will be write
 *  Author: Shirosaaki
 *  Date: 2026-01-29
 *=============================================**/

#include "vm.h"
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <sys/stat.h>

void err_exit(const char *msg) {
    perror(msg);
    exit(1);
}

void vm_init(vm_t *vm) {
    // 1. Open /dev/kvm
    vm->kvm_fd = open("/dev/kvm", O_RDWR | O_CLOEXEC);
    if (vm->kvm_fd < 0) err_exit("Impossible d'ouvrir /dev/kvm");

    // 2. Create the VM
    vm->vm_fd = ioctl(vm->kvm_fd, KVM_CREATE_VM, 0);
    if (vm->vm_fd < 0) err_exit("KVM_CREATE_VM failed");

    // 3. Allocate guest RAM
    vm->ram = mmap(NULL, RAM_SIZE, PROT_READ | PROT_WRITE, 
                   MAP_SHARED | MAP_ANONYMOUS, -1, 0);
    if (vm->ram == MAP_FAILED) err_exit("mmap RAM failed");

    // 4. Map the RAM into the VM's address space
    struct kvm_userspace_memory_region region = {
        .slot = 0,
        .flags = 0,
        .guest_phys_addr = 0x0,
        .memory_size = RAM_SIZE,
        .userspace_addr = (uint64_t)vm->ram
    };
    
    if (ioctl(vm->vm_fd, KVM_SET_USER_MEMORY_REGION, &region) < 0) 
        err_exit("KVM_SET_USER_MEMORY_REGION failed");
        
    printf("[VM] Initialized. RAM allocated at %p\n", vm->ram);
}

void vm_load_image(vm_t *vm, const char *filename) {
    int fd = open(filename, O_RDONLY);
    if (fd < 0) err_exit("Failed to open payload file");

    struct stat st;
    fstat(fd, &st);
    
    if (st.st_size > RAM_SIZE) {
        fprintf(stderr, "Error: File too large for RAM (%ld > %d)\n", st.st_size, RAM_SIZE);
        exit(1);
    }

    ssize_t ret = read(fd, vm->ram, st.st_size);
    if (ret != st.st_size) err_exit("Failed to read payload");
    
    close(fd);
    printf("[VM] Payload '%s' loaded (%ld bytes)\n", filename, st.st_size);
}
