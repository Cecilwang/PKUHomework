#define DEBUG

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/stat.h>
#include <linux/slab.h>
#include <linux/random.h>
#include <linux/delay.h>
#include <linux/sched.h>
#include <linux/kthread.h>
#include <linux/err.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Cecil Wang");

typedef struct list_node {
	struct list_head node;
	char info[100];
}list_node; 
struct list_head head;
struct task_struct *producer;
struct task_struct *consumer;
int err;
int countp = 0;
int countc = 0;

int getRandom(int maxval){
	int ret = 0;
	get_random_bytes(&ret, sizeof(int));
	if(ret < 0) ret = -ret;
	ret = (ret % maxval) + 1;
	return ret;
}

static void produceInfo(int countp, int randomms){
	list_node *now = (list_node*)kmalloc(sizeof(list_node), GFP_KERNEL);
	strcpy(now->info, "");
	sprintf(now->info, "%s (%d):count %d random %d",
		__func__, __LINE__, countp, randomms);
	list_add_tail(&(now->node), &head);
}

void printInfo(void){
	struct list_head *p;
	struct list_head *prev;
	list_node *now;
	//count = 0;
	prev = &head;
	for(p = head.next; p != &head; p = p->next){
		if(prev != &head){
			now = list_entry(prev, list_node, node);
			pr_debug("%s\n", now->info);
			list_del(prev);
			kfree(now);
			countc++;
		}
		prev = p;
	}
	if(prev != &head){
		now = list_entry(prev, list_node, node);
		pr_debug("%s\n", now->info);
		list_del(prev);
		kfree(now);
		countc++;
	}
}

int runProducer(void *nothing){
	int randomms;
	while(1){
		set_current_state(TASK_UNINTERRUPTIBLE);
		if(kthread_should_stop()) break;
		randomms = getRandom(1024);
		msleep(randomms);
		produceInfo(++countp, randomms);
	}
	return 0;
}

int runConsumer(void *nothing){
	while(1){
		set_current_state(TASK_UNINTERRUPTIBLE);
		if(kthread_should_stop()) break;
		msleep(1000);
		printInfo();
		pr_debug("%d\n", countc);
	}
	return 0;
}

static int __init run_init(void)
{
	pr_debug("Hello runner\n");
	pr_debug("==============\n");
	INIT_LIST_HEAD(&head);
	producer = kthread_run(runProducer, NULL, "producer");
	if(IS_ERR(producer)){
		pr_debug("Cann't start producer\n");
		err = PTR_ERR(producer);
		producer = NULL;
		return err;
	}
	consumer = kthread_run(runConsumer, NULL, "consumer");
	if(IS_ERR(consumer)){
		pr_debug("Cann't start consumer\n");
		err = PTR_ERR(consumer);
		consumer = NULL;
		return err;
	}
	return 0;
}

static void __exit run_exit(void)
{
	struct list_head *p;
	list_node *entry;
	list_for_each(p, &head){
		if(p->prev != &head){
			entry = list_entry(p->prev, list_node, node);
			list_del(&(entry->node));
			kfree(entry);
		}
	}
	if(producer){
		kthread_stop(producer);
		producer = NULL;
	}
	if(consumer){
		kthread_stop(consumer);
		consumer = NULL;
	}
	pr_debug("Goodbye runner\n");
}

module_init(run_init);
module_exit(run_exit);
