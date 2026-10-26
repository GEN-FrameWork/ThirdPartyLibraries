#include <linux/module.h>
#include <linux/export-internal.h>
#include <linux/compiler.h>

MODULE_INFO(name, KBUILD_MODNAME);

__visible struct module __this_module
__section(".gnu.linkonce.this_module") = {
	.name = KBUILD_MODNAME,
	.init = init_module,
#ifdef CONFIG_MODULE_UNLOAD
	.exit = cleanup_module,
#endif
	.arch = MODULE_ARCH_INIT,
};



static const struct modversion_info ____versions[]
__used __section("__versions") = {
	{ 0xe2964344, "__wake_up" },
	{ 0x06413e80, "__platform_driver_register" },
	{ 0x959e36a7, "platform_driver_unregister" },
	{ 0x84293102, "misc_deregister" },
	{ 0x3b946e26, "dma_release_channel" },
	{ 0xb6e6d99d, "clk_disable" },
	{ 0xb077e70a, "clk_unprepare" },
	{ 0x99d3c821, "devm_iounmap" },
	{ 0x12a4e128, "__arch_copy_from_user" },
	{ 0x6cbbfc54, "__arch_copy_to_user" },
	{ 0xf0fdf6cb, "__stack_chk_fail" },
	{ 0x89940875, "mutex_lock_interruptible" },
	{ 0x3213f038, "mutex_unlock" },
	{ 0xfe487975, "init_wait_entry" },
	{ 0x01000e51, "schedule" },
	{ 0x8c26d495, "prepare_to_wait_event" },
	{ 0x92540fbf, "finish_wait" },
	{ 0xdcb764ad, "memset" },
	{ 0xf1fb9ce4, "platform_get_resource" },
	{ 0xffedacbf, "devm_ioremap_resource" },
	{ 0xb4cdd826, "devm_clk_get" },
	{ 0x7c9a7371, "clk_prepare" },
	{ 0x0df8e7f1, "_dev_err" },
	{ 0x815588a6, "clk_enable" },
	{ 0x830859b7, "dma_request_chan" },
	{ 0xdac09e74, "dma_set_mask" },
	{ 0x3302bdb7, "misc_register" },
	{ 0xc7c8a118, "pin_user_pages_fast" },
	{ 0xd2139f70, "sg_alloc_table_from_pages_segment" },
	{ 0x8eb97cb4, "dma_map_sgtable" },
	{ 0xe3bdec78, "dma_unmap_sg_attrs" },
	{ 0xc8c85086, "sg_free_table" },
	{ 0x0e30db78, "unpin_user_pages" },
	{ 0x633326e9, "param_ops_int" },
	{ 0x150028cc, "module_layout" },
};

MODULE_INFO(depends, "");

MODULE_ALIAS("of:N*T*Crp1-ws281x-pwm");
MODULE_ALIAS("of:N*T*Crp1-ws281x-pwmC*");

MODULE_INFO(srcversion, "ECB086EB3455CB5908BEA92");
