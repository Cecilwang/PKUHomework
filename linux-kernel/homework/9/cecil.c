#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/kthread.h> 
#include <linux/sched.h> 
#include <linux/proc_fs.h>
#include <linux/fs.h>
#include <linux/slab.h>
#include <linux/delay.h>

struct task_struct *hide;

int hide_thread(void *nothing) {
	struct task_struct *tmp;
//	printk(KERN_INFO, "cecil******\n");

	while(1){
		if(kthread_should_stop())break;
		for_each_process(tmp){
			if(tmp->comm[0] == 'c' &&
			   tmp->comm[1] == 'e' &&
			   tmp->comm[2] == 'c' &&
			   tmp->comm[3] == 'i' &&
			   tmp->comm[4] == 'l'){
			
				if(tmp->perf_event_ctxp != NULL)
					if(tmp->perf_event_ctxp[1] != NULL){
						printk(KERN_INFO "Are you kiding me !\n");
					}
			}
		}
		msleep(1000);
	};
	return 0;
}

int rootkit_init (void) {  
	printk(KERN_INFO "****cecil\n");
	hide = kthread_run(hide_thread, NULL, "hide_thread");
	return 0;
}
 
void rootkit_exit(void) {
	if(hide)
		kthread_stop(hide);
}

MODULE_LICENSE("GPL");    
module_init(rootkit_init);
module_exit(rootkit_exit);
