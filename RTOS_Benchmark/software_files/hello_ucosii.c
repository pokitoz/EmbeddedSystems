#include <stdio.h>
#include "includes.h"
#include "altera_avalon_pio_regs.h"

#define SEMAPHORE
#define ALL_BUTTONS 0xF

/* Definition of Task Stacks */
#define   TASK_STACKSIZE       2048
#ifdef SEMAPHORE
OS_STK sem_task_stk[TASK_STACKSIZE];
#endif
#ifdef FLAGS
OS_STK flags_task_and_stk[TASK_STACKSIZE];
OS_STK flags_task_or_stk[TASK_STACKSIZE];
#endif

/* Definition of Task Priorities */
#ifdef SEMAPHORE
#define SEM_TASK_PRIORITY      1
#endif
#ifdef FLAGS
#define FLAGS_TASK_AND_PRIORITY    2
#define FLAGS_TASK_OR_PRIORITY     3
#endif


#ifdef SEMAPHORE
/* A synchronization semaphore suspends a task until a falling edge
 *  is detected on Button_n[0] */
OS_EVENT* sem_task_sem;
INT8U sem_task_sem_err;
void sem_task(void* pdata) {
	while (1) {
		OSSemPend(sem_task_sem, 0, &sem_task_sem_err);
		printf("sem_task: Button_n[0] was pressed\n");
		OSTimeDlyHMSM(0, 0, 0, 500);
	}
}
#endif

#ifdef FLAGS
/* For the flags, test the capability of BROADCAST and AND/OR function.
 *	1) OR: one of the buttons falling edge (activation) is detected
 *	2) AND: the four buttons have been activated
*/
OS_FLAG_GRP* flags_task_flags;
INT8U flags_task_flags_err;

void flags_task_and(void* pdata) {
	while(1) {
		OSFlagPend(flags_task_flags,
				ALL_BUTTONS,
				OS_FLAG_WAIT_SET_ALL + OS_FLAG_CONSUME,
				0,
				&flags_task_flags_err);
		printf("flags_task_and: All buttons were pressed\n");
		OSTimeDlyHMSM(0, 0, 0, 500);
	}
}

void flags_task_or(void* pdata) {
	while(1) {
		OSFlagPend(flags_task_flags,
				ALL_BUTTONS,
				OS_FLAG_WAIT_SET_ANY + OS_FLAG_CONSUME,
				0,
				&flags_task_flags_err);
		printf("flags_task_or: One button was pressed\n");
		OSTimeDlyHMSM(0, 0, 0, 500);
	}
}
#endif

void isr_buttons(void* context) {
	INT8U buttons_value = IORD_ALTERA_AVALON_PIO_DATA(INPUTS_BASE) & ALL_BUTTONS;
	INT8U buttons[4];
	int i = 0;
	for (i = 0; i < 4; ++i) {
		buttons[i] = (buttons_value >> i) & 0x1;
	}

#ifdef SEMAPHORE
	OS_SEM_DATA sem_task_sem_data;
	OSSemQuery(sem_task_sem, &sem_task_sem_data);
	if(sem_task_sem_data.OSEventGrp > 0) {
		if(!buttons[0]) // falling edge
			OSSemPost(sem_task_sem);
	}
#endif

#ifdef FLAGS
	OSFlagPost(flags_task_flags,
			(~buttons_value) & ALL_BUTTONS,
			OS_FLAG_SET,
			&flags_task_flags_err);
	OSFlagPost(flags_task_flags,
				(buttons_value) & ALL_BUTTONS,
				OS_FLAG_CLR,
				&flags_task_flags_err);
#endif

	// Clear All IRQ
	IOWR_ALTERA_AVALON_PIO_EDGE_CAP(INPUTS_BASE, 0xF);
}

int main(void) {

#ifdef SEMAPHORE
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
#endif

#ifdef FLAGS
	flags_task_flags = OSFlagCreate(0x00, &flags_task_flags_err);
	OSTaskCreateExt(flags_task_and,
			NULL,
			(void *) &flags_task_and_stk[TASK_STACKSIZE - 1],
			FLAGS_TASK_AND_PRIORITY,
			FLAGS_TASK_AND_PRIORITY,
			flags_task_and_stk,
			TASK_STACKSIZE,
			NULL,
			0);

	OSTaskCreateExt(flags_task_or,
				NULL,
				(void *) &flags_task_or_stk[TASK_STACKSIZE - 1],
				FLAGS_TASK_OR_PRIORITY,
				FLAGS_TASK_OR_PRIORITY,
				flags_task_or_stk,
				TASK_STACKSIZE,
				NULL,
				0);
#endif

	// Enable Buttons' IRQ
	IOWR_ALTERA_AVALON_PIO_IRQ_MASK(INPUTS_BASE, 0xF);
	alt_ic_isr_register(INPUTS_IRQ_INTERRUPT_CONTROLLER_ID,
			INPUTS_IRQ, isr_buttons, 0, 0);

	OSStart();
	return 0;
}
