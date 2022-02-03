#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

#define CHAIN_TO_MACHINE "chain_to_machine"
#define MACHINE_TO_CHAIN "machine_to_chain"

int main(void)
{
    int write_result, read_result;
    int chain_to_machine, machine_to_chain;
    int counter = 0;

    mknod(CHAIN_TO_MACHINE, S_IFIFO | 0666, 0);
    printf("opened chain to machine\n");
    mknod(MACHINE_TO_CHAIN, S_IFIFO | 0666, 0);
    printf("opened machine to chain\n");

    chain_to_machine = open(CHAIN_TO_MACHINE, O_RDONLY);
    machine_to_chain = open(MACHINE_TO_CHAIN, O_WRONLY);

    while (1)
    {
        if ((write_result = read(chain_to_machine, &counter, sizeof(counter))) == -1)
            perror("read");
        else
        {
            printf("read counter %d\n", counter);
            counter++;
            if ((write_result = write(machine_to_chain, &counter, sizeof(counter))) == -1)
                perror("write");
            else
            {
                printf("wrote counter %d\n", counter);
            }
        }
        sleep(1);
    }

    return 0;
}
