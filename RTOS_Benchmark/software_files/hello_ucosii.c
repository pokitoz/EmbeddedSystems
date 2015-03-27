#include <stdio.h>
#include "includes.h"
#include "altera_avalon_pio_regs.h"

/* Definition of Task Stacks */
#define   TASK_STACKSIZE       2048
OS_STK sem_task_stk[TASK_STACKSIZE];

/* Definition of Task Priorities */
#define SEM_TASK_PRIORITY      1

/* A synchronization semaphore suspends a task until a falling edge
 *  is detected on Button_n[0] */
OS_EVENT* sem_task_sem;
INT8U sem_task_sem_err;
void sem_task(void* pdata) {
	while (1) {
		OSSemPend(sem_task_sem, 0, &sem_task_sem_err);
		printf("sem_task: Button_n[0] was pressed\n");
	}
}

void isr_buttons(void* context) {
	OS_SEM_DATA sem_task_sem_data;
	OSSemQuery(sem_task_sem, &sem_task_sem_data);
	if(sem_task_sem_data.OSEventGrp > 0)
		OSSemPost(sem_task_sem);
	// Clear All IRQ
	IOWR_ALTERA_AVALON_PIO_EDGE_CAP(INPUTS_BASE, 0xF);
}

int main(void) {

	sem_task_sem = OSSemCreate(0);

	OSTaskCreateExt(sem_task,
			NULL,
			(void *) &sem_task_stk[TASK_STACKSIZE - 1],
			SEM_TASK_PRIORITY,
			SEM_TASK_PRIORITY,
			sem_task_stk,
			TASK_STACKSIZE,
			NULL,
			0);

	// Enable Buttons' IRQ
	IOWR_ALTERA_AVALON_PIO_IRQ_MASK(INPUTS_BASE, 0xF);
	alt_ic_isr_register(INPUTS_IRQ_INTERRUPT_CONTROLLER_ID,
			INPUTS_IRQ, isr_buttons, 0, 0);

	OSStart();
	return 0;
}
