#include <linux/module.h>
#define INCLUDE_VERMAGIC
#include <linux/build-salt.h>
#include <linux/elfnote-lto.h>
#include <linux/export-internal.h>
#include <linux/vermagic.h>
#include <linux/compiler.h>

BUILD_SALT;
BUILD_LTO_INFO;

MODULE_INFO(vermagic, VERMAGIC_STRING);
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

#ifdef CONFIG_RETPOLINE
MODULE_INFO(retpoline, "Y");
#endif


static const struct modversion_info ____versions[]
__used __section("__versions") = {
	{ 0xe2964344, "__wake_up" },
	{ 0x410a7f31, "__platform_driver_register" },
	{ 0xd4e60229, "platform_driver_unregister" },
	{ 0x3e8acca9, "misc_deregister" },
	{ 0x9d9c2ac3, "dma_release_channel" },
	{ 0xb6e6d99d, "clk_disable" },
	{ 0xb077e70a, "clk_unprepare" },
	{ 0xfff2f18c, "devm_iounmap" },
	{ 0x12a4e128, "__arch_copy_from_user" },
	{ 0x6cbbfc54, "__arch_copy_to_user" },
	{ 0x8da6585d, "__stack_chk_fail" },
	{ 0x89940875, "mutex_lock_interruptible" },
	{ 0x3213f038, "mutex_unlock" },
	{ 0xfe487975, "init_wait_entry" },
	{ 0x1000e51, "schedule" },
	{ 0x8c26d495, "prepare_to_wait_event" },
	{ 0x92540fbf, "finish_wait" },
	{ 0xdcb764ad, "memset" },
	{ 0xef189478, "platform_get_resource" },
	{ 0x69c7b830, "devm_ioremap_resource" },
	{ 0xd9f50d91, "devm_clk_get" },
	{ 0x7c9a7371, "clk_prepare" },
	{ 0xa9c64948, "_dev_err" },
	{ 0x815588a6, "clk_enable" },
	{ 0x60aa3874, "dma_request_chan" },
	{ 0xd906b334, "dma_set_mask" },
	{ 0x4aa2d47, "misc_register" },
	{ 0x5b674cd, "pin_user_pages_fast" },
	{ 0xd720fa04, "sg_alloc_table_from_pages_segment" },
	{ 0xa288aa16, "dma_map_sgtable" },
	{ 0x9ee36c75, "dma_unmap_sg_attrs" },
	{ 0x7f5b4fe4, "sg_free_table" },
	{ 0x39af0116, "unpin_user_pages" },
	{ 0x8a93aadd, "param_ops_int" },
	{ 0xf7038a43, "module_layout" },
};

MODULE_INFO(depends, "");

MODULE_ALIAS("of:N*T*Crp1-ws281x-pwm");
MODULE_ALIAS("of:N*T*Crp1-ws281x-pwmC*");

MODULE_INFO(srcversion, "771F09BABBD3B589F6F66A8");
