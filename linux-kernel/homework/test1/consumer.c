#define DEBUG

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/stat.h>
#include <linux/slab.h>
#include <linux/random.h>
#include <linux/delay.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Cecil Wang");

extern struct list_head head;

typedef struct list_node {
	struct list_head node;
	char info[100];
}list_node;

extern struct list_head head;

int count = 0;

void printInfo(void ){
	struct list_head *p;
	struct list_head *prev;
	list_node *now;
	//count = 0;
	list_for_each(p, &head){
		prev = p->prev;
		if(prev != &head){
			now = list_entry(prev, list_node, node);
			pr_debug("%s\n", now->info);
			list_del(prev);
			kfree(now);
			count++;
		}
	}	
}

void runConsumer(void){
	int times = 0;
	while(times++ < 3){
		msleep(1000);
		printInfo();
		pr_debug("%d\n", count);
	}
}
EXPORT_SYMBOL(runConsumer);


static int __init consumer_init(void)
{
	pr_debug("Hello consumer\n");
	pr_debug("==============\n");
	return 0;
}

static void __exit consumer_exit(void)
{
	pr_debug("Goodbye consumer\n");
}

module_init(consumer_init);
module_exit(consumer_exit);
