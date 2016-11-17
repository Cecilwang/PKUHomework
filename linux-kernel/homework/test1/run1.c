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

struct task_struct *producer;
struct task_struct *consumer;
int err;
int countp = 0;
int countc = 0;

typedef struct POOL{
	char info[100][100];
	int head;
}POOL;

POOL pool;
static DEFINE_MUTEX(mutex);

void produceInfo(POOL *pool, int countp, int randomms){
	strcpy(pool->info[pool->head], "");
	sprintf(pool->info[pool->head], "%s (%d):count %d random %d",
		__func__, __LINE__, countp, randomms);
	pool->head++;	
}

int printInfo(POOL *pool){
	int tmp = pool->head;
	int i;
	for(i = 0; i < pool->head; ++i)
		pr_debug("%s\n", pool->info[i]);
	pool->head = 0;
	return tmp;
}

int getRandom(int maxval){
	int ret = 0;
	get_random_bytes(&ret, sizeof(int));
	if(ret < 0) ret = -ret;
	ret = (ret % maxval) + 1;
	return ret;
}

int runProducer(void *nothing){
	int randomms;
	while(1){
		set_current_state(TASK_UNINTERRUPTIBLE);
		if(kthread_should_stop()) break;
		randomms = getRandom(1024);
		msleep(randomms);
		mutex_lock(&mutex);
		produceInfo(&pool, ++countp, randomms);
		mutex_unlock(&mutex);
	}
	return 0;
}

int runConsumer(void *nothing){
	while(1){
		set_current_state(TASK_UNINTERRUPTIBLE);
		if(kthread_should_stop()) break;
		msleep(1000);
		mutex_lock(&mutex);
		countc += printInfo(&pool);
		mutex_unlock(&mutex);
		pr_debug("%d\n", countc);
	}
	return 0;
}

static int __init run_init(void)
{
	pr_debug("Hello runner\n");
	pr_debug("==============\n");
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
