#include <linux/module.h>
#include <linux/vermagic.h>
#include <linux/compiler.h>

MODULE_INFO(vermagic, VERMAGIC_STRING);

__visible struct module __this_module
__attribute__((section(".gnu.linkonce.this_module"))) = {
	.name = KBUILD_MODNAME,
	.init = init_module,
#ifdef CONFIG_MODULE_UNLOAD
	.exit = cleanup_module,
#endif
	.arch = MODULE_ARCH_INIT,
};

static const struct modversion_info ____versions[]
__used
__attribute__((section("__versions"))) = {
	{ 0x1e94b2a0, __VMLINUX_SYMBOL_STR(module_layout) },
	{ 0x652a70e2, __VMLINUX_SYMBOL_STR(device_remove_file) },
	{ 0xda22cdde, __VMLINUX_SYMBOL_STR(kmalloc_caches) },
	{ 0xd2b09ce5, __VMLINUX_SYMBOL_STR(__kmalloc) },
	{ 0xda3e43d1, __VMLINUX_SYMBOL_STR(_raw_spin_unlock) },
	{ 0x86013486, __VMLINUX_SYMBOL_STR(usb_add_hcd) },
	{ 0x9e5900aa, __VMLINUX_SYMBOL_STR(usb_remove_hcd) },
	{ 0x81dd3acd, __VMLINUX_SYMBOL_STR(usb_create_hcd) },
	{ 0x92b3e87a, __VMLINUX_SYMBOL_STR(usb_hcd_poll_rh_status) },
	{ 0xbbc2b0e7, __VMLINUX_SYMBOL_STR(driver_for_each_device) },
	{ 0xd7804f5e, __VMLINUX_SYMBOL_STR(mutex_unlock) },
	{ 0xb564724c, __VMLINUX_SYMBOL_STR(usb_hcd_giveback_urb) },
	{ 0x4629334c, __VMLINUX_SYMBOL_STR(__preempt_count) },
	{ 0xdc139794, __VMLINUX_SYMBOL_STR(__platform_driver_register) },
	{ 0x3e6590c3, __VMLINUX_SYMBOL_STR(usb_put_hcd) },
	{ 0xfb578fc5, __VMLINUX_SYMBOL_STR(memset) },
	{ 0xe852ef02, __VMLINUX_SYMBOL_STR(usb_hcd_link_urb_to_ep) },
	{ 0x1c59e233, __VMLINUX_SYMBOL_STR(dev_err) },
	{ 0x8f64aa4, __VMLINUX_SYMBOL_STR(_raw_spin_unlock_irqrestore) },
	{ 0x27e1a049, __VMLINUX_SYMBOL_STR(printk) },
	{ 0x745d3b1d, __VMLINUX_SYMBOL_STR(platform_device_alloc) },
	{ 0x6ff92103, __VMLINUX_SYMBOL_STR(platform_device_add) },
	{ 0x4e9eed93, __VMLINUX_SYMBOL_STR(mutex_lock) },
	{ 0xf583891b, __VMLINUX_SYMBOL_STR(platform_device_unregister) },
	{ 0xc08aa409, __VMLINUX_SYMBOL_STR(device_create_file) },
	{ 0xe7a60ca2, __VMLINUX_SYMBOL_STR(usb_hcd_check_unlink_urb) },
	{ 0x87e897fa, __VMLINUX_SYMBOL_STR(module_put) },
	{ 0x3416aa48, __VMLINUX_SYMBOL_STR(_dev_info) },
	{ 0x351b51d9, __VMLINUX_SYMBOL_STR(usb_get_dev) },
	{ 0xd13ac951, __VMLINUX_SYMBOL_STR(driver_create_file) },
	{ 0xdb7305a1, __VMLINUX_SYMBOL_STR(__stack_chk_fail) },
	{ 0x5224f91, __VMLINUX_SYMBOL_STR(usb_put_dev) },
	{ 0xc0dcebfc, __VMLINUX_SYMBOL_STR(platform_device_add_data) },
	{ 0xbdfb6dbb, __VMLINUX_SYMBOL_STR(__fentry__) },
	{ 0x3d1f7a21, __VMLINUX_SYMBOL_STR(kmem_cache_alloc_trace) },
	{ 0xd52bf1ce, __VMLINUX_SYMBOL_STR(_raw_spin_lock) },
	{ 0xf62d5a7a, __VMLINUX_SYMBOL_STR(__dynamic_dev_dbg) },
	{ 0x9327f5ce, __VMLINUX_SYMBOL_STR(_raw_spin_lock_irqsave) },
	{ 0x19a304ba, __VMLINUX_SYMBOL_STR(usb_disabled) },
	{ 0x37a0cba, __VMLINUX_SYMBOL_STR(kfree) },
	{ 0x69acdf38, __VMLINUX_SYMBOL_STR(memcpy) },
	{ 0x6375136, __VMLINUX_SYMBOL_STR(dev_warn) },
	{ 0xdbd83fd0, __VMLINUX_SYMBOL_STR(driver_remove_file) },
	{ 0x28318305, __VMLINUX_SYMBOL_STR(snprintf) },
	{ 0xac27f7d3, __VMLINUX_SYMBOL_STR(platform_driver_unregister) },
	{ 0x8bb70334, __VMLINUX_SYMBOL_STR(usb_hcd_unlink_urb_from_ep) },
	{ 0x8dd9198e, __VMLINUX_SYMBOL_STR(usb_hcd_resume_root_hub) },
	{ 0x4f1eff, __VMLINUX_SYMBOL_STR(try_module_get) },
	{ 0x7ff520f1, __VMLINUX_SYMBOL_STR(platform_device_put) },
};

static const char __module_depends[]
__used
__attribute__((section(".modinfo"))) =
"depends=";


MODULE_INFO(srcversion, "9E700B46FBDA1647A9A2865");
