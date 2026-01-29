/**==============================================
 *                 main.c
 *  main file
 *  Author: Shirosaaki
 *  Date: 2026-01-29
 *=============================================**/

#include "vm.h"
#include <stdio.h>

int main(int argc, char *argv[]) {
    vm_t vm;

    if (argc != 2) {
        printf("Usage: %s <payload.bin>\n", argv[0]);
        return 1;
    }
    vm_init(&vm);
    vm_load_image(&vm, argv[1]);
    vcpu_init(&vm);
    vcpu_run(&vm);
    return 0;
}
