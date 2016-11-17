/* 
 * The necessary header files 
 */

/*
 * Standard in kernel modules 
 */
#include <linux/kernel.h>	/* We're doing kernel work */
#include <linux/module.h>	/* Specifically, a module, */
#include <linux/moduleparam.h>	/* which will have params */
#include <linux/unistd.h>	/* The list of system calls */
#include <linux/kprobes.h>
#include <asm/traps.h>

MODULE_LICENSE("GPL");

/* 
 * For the current (process) structure, we need
 * this to know who the current user is. 
 */
#include <linux/sched.h>
#include <asm/uaccess.h>

unsigned long **sys_call_table;

static uid_t uid;
module_param(uid, int, 0644);

asmlinkage int (*original_call) (const char *, int, int);

asmlinkage int our_sys_open(const char *filename, int flags, int mode)
{
	int i = 0;
	char ch;

	/* 
	 * Check if this is the user we're spying on 
	 */
	if (uid == current->cred->uid.val) {
		/* 
		 * Report the file, if relevant 
		 */
		printk("Opened file by %d: ", uid);
		do {
			get_user(ch, filename + i);
			i++;
			printk("%c", ch);
		} while (ch != 0);
		printk("\n");
	}

	/* 
	 * Call the original sys_open - otherwise, we lose
	 * the ability to open files 
	 */
	return original_call(filename, flags, mode);
}

/*	
 *	Change the page permission
 */
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

/* 
 * Initialize the module - replace the system call 
 */
int init_module()
{
	printk(KERN_ALERT "dump stack start\n");
	dump_stack();
	printk(KERN_ALERT "dump stack end\n\n");
	printk(KERN_ALERT "I'm dangerous. I hope you did a ");
	printk(KERN_ALERT "sync before you insmod'ed me.\n");
	printk(KERN_ALERT "My counterpart, cleanup_module(), is even");
	printk(KERN_ALERT "more dangerous. If\n");
	printk(KERN_ALERT "you value your file system, it will ");
	printk(KERN_ALERT "be \"sync; rmmod\" \n");
	printk(KERN_ALERT "when you remove this module.\n");

	sys_call_table = (unsigned long **)0xffffffff81801460; 
	original_call = (int(*)(const char*, int, int))sys_call_table[__NR_open];
	set_page_rw((unsigned long)sys_call_table);
	sys_call_table[__NR_open] = (unsigned long *)our_sys_open;
	set_page_ro((unsigned long)sys_call_table);

	printk(KERN_INFO "Spying on UID:%d\n", uid);

	return 0;
}

/* 
 * Cleanup - unregister the appropriate file from /proc 
 */
void cleanup_module()
{
	/*  
	 * Return the system call back to normal 
	 */
	if (sys_call_table[__NR_open] != (unsigned long *)our_sys_open) {
		printk(KERN_ALERT "Somebody else also played with the ");
		printk(KERN_ALERT "open system call\n");
		printk(KERN_ALERT "The system may be left in ");
		printk(KERN_ALERT "an unstable state.\n");
	}
	set_page_rw((unsigned long)sys_call_table);
	sys_call_table[__NR_open] = (unsigned long *)original_call;
	set_page_ro((unsigned long)sys_call_table);
	printk(KERN_INFO "REMOVE open\n");
}
