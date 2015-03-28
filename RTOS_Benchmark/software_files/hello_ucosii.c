#include <stdio.h>
#include "includes.h"
#include "altera_avalon_pio_regs.h"
#include "alt_timer.h"

#define QUEUE
#define ALL_BUTTONS 0xFF

struct alt_timer timer = {
		.base = TIMER_0_BASE,
		.irq_no = TIMER_0_IRQ,
		.irq_ctrl_id = TIMER_0_IRQ_INTERRUPT_CONTROLLER_ID
};

/* Definition of Task Stacks */
#define   TASK_STACKSIZE       2048
#ifdef SEMAPHORE
OS_STK sem_task_stk[TASK_STACKSIZE];
#endif
#ifdef FLAGS
OS_STK flags_task_and_stk[TASK_STACKSIZE];
OS_STK flags_task_or_stk[TASK_STACKSIZE];
#endif
#ifdef MAILBOX
OS_STK mbox_task_stk[TASK_STACKSIZE];
#endif
#ifdef QUEUE
OS_STK queue_task_stk[TASK_STACKSIZE];
#endif

/* Definition of Task Priorities */
#ifdef SEMAPHORE
#define SEM_TASK_PRIORITY          1
#endif
#ifdef FLAGS
#define FLAGS_TASK_AND_PRIORITY    2
#define FLAGS_TASK_OR_PRIORITY     3
#endif
#ifdef MAILBOX
#define MBOX_TASK_PRIORITY         4
#endif
#ifdef QUEUE
#define	QUEUE_TASK_PRIORITY        5
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

#ifdef MAILBOX
OS_EVENT* mbox;
INT8U mbox_err;

struct button_event {
	INT8U buttons; /* RISING(1)/FALLING(0) + Buttons number*/
	INT32U time;   /* Time of the event */
};

void mbox_task(void* pdata) {
	while(1) {
		struct button_event* be = OSMboxPend(mbox, 0, &mbox_err);
		printf("mbox: event on buttons: ");

		int i = 0;
		for (i = 0; i < 4; ++i) {
			if(be->buttons & (1 << i)) {
				printf("%d ", i);
				if(be->buttons & (16 << i))
					printf("(rising) ");
				else
					printf("(falling) ");
			}
		}
		printf("at time %u\n", (unsigned int) (-1) - (unsigned int) be->time);
		//OSTimeDlyHMSM(0, 0, 0, 500);
	}
}
#endif

#ifdef QUEUE
OS_EVENT* queue;
INT8U queue_err;

struct button_event {
	INT8U buttons; /* RISING(1)/FALLING(0) + Buttons number*/
	INT32U time;   /* Time of the event */
};

void* storage[10];

void queue_task(void* pdata) {
	while(1) {
		struct button_event* be = OSQPend(queue, 0, &queue_err);
		printf("queue: event on buttons: ");

		int i = 0;
		for (i = 0; i < 4; ++i) {
			if(be->buttons & (1 << i)) {
				printf("%d ", i);
				if(be->buttons & (16 << i))
					printf("(rising) ");
				else
					printf("(falling) ");
			}
		}
		printf("at time %u\n", (unsigned int) (-1) - (unsigned int) be->time);
		//OSTimeDlyHMSM(0, 0, 0, 500);
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

	INT8U edge_value = IORD_ALTERA_AVALON_PIO_EDGE_CAP(INPUTS_BASE) & ALL_BUTTONS;
	INT8U edge[4];
	for (i = 0; i < 4; ++i) {
		edge[i] = (edge_value >> i) & 0x1;
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

#ifdef MAILBOX
	OS_MBOX_DATA mbox_data;
	OSMboxQuery(mbox, &mbox_data);
	if(mbox_data.OSEventGrp > 0) {
		static struct button_event be;
		be.buttons = 0;
		for (i = 0; i < 4; ++i) {
			if(edge[i]) {
				be.buttons |= (1 << i);
				if(buttons[i])
					be.buttons |= (16 << i);
			}
		}
		be.time = alt_timer_read(&timer);
		OSMboxPost(mbox, &be);
	}
#endif

#ifdef QUEUE
	OS_Q_DATA queue_data;
	OSQQuery(queue, &queue_data);
	if(queue_data.OSEventGrp > 0) {
		static struct button_event be;
		be.buttons = 0;
		for (i = 0; i < 4; ++i) {
			if(edge[i]) {
				be.buttons |= (1 << i);
				if(buttons[i])
					be.buttons |= (16 << i);
			}
		}
		be.time = alt_timer_read(&timer);
		OSQPost(queue, &be);
	}
#endif

	// Clear All IRQ
	IOWR_ALTERA_AVALON_PIO_EDGE_CAP(INPUTS_BASE, 0xF);
}

int main(void) {

	alt_timer_init(&timer, (alt_u32) -1, 0, NULL);
	alt_timer_start(&timer);

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

#ifdef MAILBOX
	mbox = OSMboxCreate(NULL);
	OSTaskCreateExt(mbox_task,
			NULL,
			(void *) &mbox_task_stk[TASK_STACKSIZE - 1],
			MBOX_TASK_PRIORITY,
			MBOX_TASK_PRIORITY,
			mbox_task_stk,
			TASK_STACKSIZE,
			NULL,
			0);
#endif

#ifdef QUEUE
	queue = OSQCreate(&storage[0], 10);
	OSTaskCreateExt(queue_task,
			NULL,
			(void *) &queue_task_stk[TASK_STACKSIZE - 1],
			QUEUE_TASK_PRIORITY,
			QUEUE_TASK_PRIORITY,
			queue_task_stk,
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
