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

typedef struct list_node {
	struct list_head node;
	char info[100];
}list_node; 
struct list_head head;
EXPORT_SYMBOL(head);

int count = 0;
unsigned int randomms;

int getRandom(int maxval){
	int ret = 0;
	get_random_bytes(&ret, sizeof(int));
	if(ret < 0) ret = -ret;
	ret = (ret % maxval) + 1;
	return ret;
}

static void produceInfo(int count, int randomms){
	list_node *now = (list_node*)kmalloc(sizeof(list_node), GFP_KERNEL);
	strcpy(now->info, "");
	sprintf(now->info, "%s (%d):count %d random %d",
		__func__, __LINE__, count, randomms);
	//pr_debug("%s\n", now->info);
	//pr_debug("%s (%d):count %d random %d\n",
	//	__func__, __LINE__, count, randomms);
	
	list_add_tail(&(now->node), &head);
}

void runProducer(void){
	int times = 0;
	while(times++ < 50){
		randomms = getRandom(1024);
		msleep(randomms);
		produceInfo(count++, randomms);
	}

}
EXPORT_SYMBOL(runProducer);

static int __init producer_init(void)
{
	pr_debug("Hello producer\n");
	pr_debug("==============\n");

	INIT_LIST_HEAD(&head);
	//list_for_each(p, &head){
	//	entry = list_entry(p, list_node, node);
	//	pr_debug("%s\n", entry->info);
	//}
	return 0;
}

static void __exit producer_exit(void)
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
	pr_debug("Goodbye producer\n");
}

module_init(producer_init);
module_exit(producer_exit);
