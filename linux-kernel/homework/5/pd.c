#include <linux/module.h>   /* Needed by all modules */
#include <linux/kernel.h>   /* Needed for KERN_INFO */
#include <linux/init.h>

MODULE_LICENSE("GPL");

extern char __initdata boot_command_line[];
extern char *saved_command_line;

  int init_module(void)
{
	char **pt;
	char *ppt;
	long tmp;
	printk(KERN_INFO "Hello\n");

	print_hex_dump(KERN_DEBUG, "boot_command_line",
		       DUMP_PREFIX_ADDRESS, 16, 4,
		       (void*)0xffffffff81de6900, 200, true);
	
	pt = (char**)0xffffffff81e98008;
	tmp = &pt;
	ppt = (char*)(tmp);
	print_hex_dump(KERN_DEBUG, "saved_command_line",
		       DUMP_PREFIX_ADDRESS, 16, 4,
		       (pt[0]), 100, true);
/*	
	print_hex_dump(KERN_DEBUG, "boot_command_line",
		       DUMP_PREFIX_ADDRESS, 16, 4,
		       boot_command_line, strlen(boot_command_line), true);		      

	print_hex_dump(KERN_DEBUG, "saved_command_line",
		       DUMP_PREFIX_ADDRESS, 16, 4,
		       saved_command_line, strlen(saved_command_line), true);

*/



	trace_printk("Oooooooh\n");

	return 0;
}

void cleanup_module(void)
{
	printk(KERN_INFO "Goodbye\n");
}
