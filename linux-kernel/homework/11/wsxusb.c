#define DEBUG

#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/stat.h>
#include <linux/usb/hcd.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Cecil Wang");


static int __init wsxusb_init(void)
{

	return 0;
}

static void __exit wsxusb_exit(void)
{
}

module_init(wsxusb_init);
module_exit(wsxusb_exit);
