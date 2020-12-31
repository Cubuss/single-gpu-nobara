#include <stdio.h>
#include <stdlib.h>
#include <zconf.h>
#include "linuxapilayer.h"

/* ERROR CODE      MEANING
 *     12       NO DEDICATED GPU DETECTED.
 *     42       NEEDS ROOT
 * */

int main(){
	if(geteuid() != 0)
	{
		printf("ERROR 42 \n Please run this script as root! \n");
		exit(42);
	} else {
		printf("\n Root access obtained! \n");
	}
	bool amdgpu = is_module_in_use("amdgpu");
	bool nvidia = is_module_in_use("nvidia");
	bool noveau = is_module_in_use("noveau");
	bool amdgpu_pro = is_module_in_use("amdgpu-pro");

	if (!amdgpu && !nvidia && !noveau && !amdgpu_pro){
		printf("ERROR 12: \n NO DEDICATED GPU DRIVER DETECTED. \n EXITING...\n IF THIS IS AN ERROR, PLEASE FILE A BUG REPORT. \n");
		exit(12);
	}
	bool grub = file_exists("/etc/default/grub");
	bool systemdboot = file_exists("/usr/bin/kernelstub");

	bool intel = is_intel();
	bool amd = is_amd();
	
	if (grub) {
		if (amd){
			add_grub_param("amd_iommu=on");
		}
		if (intel){
			add_grub_param("intel_iommu=on");
		}
		add_grub_param("iommu=pt");
		add_grub_param("kvm.ignore_msrs=1");
		add_grub_param("vfio_pci.disable_idle_d3=1");
		add_grub_param("pci=noaer");

		if ((amdgpu)||(noveau)||(amdgpu_pro)){
			add_grub_param("video=efifb:off");
		}
	}

	if (systemdboot){
		if (amd){
			add_systemdboot_param("amd_iommu=on");
		}
		if (intel){
			add_systemdboot_param("intel_iommu=on");
		}
		add_systemdboot_param("iommu=pt");
		add_systemdboot_param("kvm.ignore_msrs=1");
		add_systemdboot_param("vfio_pci.disable_idle_d3=1");
		add_systemdboot_param("pci=noaer");

	 if ((amdgpu)||(noveau)||(amdgpu_pro)){
			add_systemdboot_param("video=efifb:off");
		}
	}	
	update_bootloaders();
	return 0;
}

