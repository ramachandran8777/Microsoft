
# Virtualization based security (VBS) and  Credentials Guard

Virtualization Based Security (VBS) is a Microsoft Windows feature that was introduced in Windows 10, Windows Server 2016 and higher. Microsoft VBS uses hardware virtualization features to create and isolate a secure region of memory from the normal operating system. For example, Windows can use this isolated memory space to store credentials (Credential Guard) to mitigate the pass the hash vulnerability.
Virtualization Based Security effectively reduces the Windows attack surface, so even if a malicious actor gains access to the OS kernel, the protected content can prevent code execution and the access of secrets, such as system credentials

The communication between the Windows OS and the credentials that are stored in an isolated memory space, will be done over RPC calls.


## Requirements
    VM Hardware Requirements:
    - VM hardware 14 or higher.
    - Guest OS that supports Virtualized based Security that exists of the following VM hardware settings.
    - IOMMU
    - Hardware virtualization
    - EUFI boot firmware
    - Secureboot
    - vTPM (Optionally)

The following will also be needed when using vTPM:

    vCenter Requirements
    - Enterprise plus license (for the native key provider)
    - ESXI Cluster
    - Key Provider (Native or 3th party)

## Configure VMware Native Key Provider
Let me start by saying vTPM is not required to have to implement Microsoft VBS with Credential Guard. Credential Guard will work, but it will be less secure.

The only way to assign a Trusted Platform module device to a VM, is by having a configured key provider in vCenter (Native or 3th party). The key provider need to be maintained, so it will be an additional dependency in the infrastructure.

- Login to the vCenter web GUI, click on the vCenter object, click on Configure and select Key Providers.
- Click on the ADD button and select ADD NATIVE KEY PROVIDERS to open the wizard.

    ![image](https://github.com/user-attachments/assets/872b2935-ccf3-48e1-b079-fab1fb453dee)

- Enter a name for the vSphere Native Key Provider and enable the Use Key Provider only with TPM protected ESXI hosts if needed. 

    Note: Use Key Provider only with TPM protected ESXI hosts will only enable the vSphere Key Provider on hosts that that physcially has a TPM 2.0 chip.

    ![image](https://github.com/user-attachments/assets/e46436a3-fa09-4b51-bce6-e90791bad1ab)

- Create a backup of the vSphere Native Key Provider.

    ![image](https://github.com/user-attachments/assets/54b2fcdc-9e6d-4f8e-8452-3ae9e0240806)

- Backup Key Provider

    ![image](https://github.com/user-attachments/assets/408bb97b-dc54-4910-b052-068b4c4d4222)

- Protect Native Key Provider data with password

    ![image](https://github.com/user-attachments/assets/c174a33d-2ebd-4052-b16b-8ab3202ab7ef)

- Native Key Provider is up and running

# Microsoft VBS
## Configure VBS in an existing Windows VM

Note: You should only enable the Virtualized Based Security option when the Windows Guest OS has been installed with an EUFI firmware. Converting from BIOS to EUFI could be a hard time in Windows.

- Select the Windows VM and click on edit settings.
- Click on the VM Options tab.
- Enable the Virtualized Based Security option.
- Click on Save to commit the changes.

Configure VBS in a new Windows VM:
- Create a new Windows VM (Windows 10, Windows 2016 or higher).
- Select the latest compatibility mode to get the latest VM Hardware version.
	- Minimum VM Hardware 14
- Select a compatible Windows Guest OS Family that supports Microsoft Virtualized Based Security.
	- Enable Windows Virtualization Based Security
       ![image](https://github.com/user-attachments/assets/152eeffd-1d58-4882-a21c-bfecc13c9405)
- Guest OS shows VBS is enabled

## Configure VBS in Guest OS
- The virtual machine has been configured with the required VM hardware components and is now ready to be configured for VBS in the Guest OS. Let’s have a look at the current System Information > System Summary on the VM without VBS enabled in the Guest OS:
    ![image](https://github.com/user-attachments/assets/004a8c64-8df1-4f5d-b1fb-02fa45066a2c)
- Verify VBS status
- Next step is to enable the Microsoft VBS within the Guest OS with the security options you would like to have configured. 
- Open the local group policy with gpedit.msc and browse to Computer Configuration > Administrative Templates > System > Device Guard.
- Enable the setting: Turn On Virtualization Based Security.
- Configure the VBS options: (Configure the options according your needs.)

| Option | Value | Info |
| ------ | ------ |------ |
| Select Platform Security Level | **Secure Boot and DMA protection** | Among the commands that follow, you can choose settings for Secure Boot and Secure Boot with DMA. In most situations, we recommend that you choose Secure Boot. This option provides Secure Boot with as much protection as is supported by a given computer’s hardware. A computer with input/output memory management units (IOMMUs) will have Secure Boot with DMA protection. A computer without IOMMUs will simply have Secure Boot enabled. |
| Virtualization Based Protection Of Code Integrity | **Enabled with EUFI Lock** | This setting enables virtualization based protection of Kernel Mode Code Integrity. When this is enabled, kernel mode memory protections are enforced and the Code Integrity validation path is protected by the Virtualization Based Security feature. The “Enabled with UEFI lock” option ensures that Virtualization Based Protection of Code Integrity cannot be disabled remotely. In order to disable the feature, you must set the Group Policy to “Disabled” as well as remove the security functionality from each computer, with a physically present user, in order to clear configuration persisted in UEFI |
| Require EUFI Memory Attributes Table | **Checked** | The “Require UEFI Memory Attributes Table” option will only enable Virtualization Based Protection of Code Integrity on devices with UEFI firmware support for the Memory Attributes Table. Devices without the UEFI Memory Attributes Table may have firmware that is incompatible with Virtualization Based Protection of Code Integrity which in some cases can lead to crashes or data loss or incompatibility with certain plug-in cards. If not setting this option the targeted devices should be tested to ensure compatibility.|
| Credential Guard Configuration | **Enabled with EUFI Lock** | This setting lets users turn on Credential Guard with virtualization-based security to help protect credentials. The “Enabled with UEFI lock” option ensures that Virtualization Based Protection of Code Integrity cannot be disabled remotely. In order to disable the feature, you must set the Group Policy to “Disabled” as well as remove the security functionality from each computer, with a physically present user, in order to clear configuration persisted in UEFI|
| Secure Launch Configuration | **Enabled** | This setting sets the configuration of Secure Launch to secure the boot chain. |

![image](https://github.com/user-attachments/assets/ff4800d6-3ecf-496a-ac36-4e014e5ee5dd)

- Enable VBS in the Guest OS
- Reboot the server to activate the VBS functionalities.
    ![image](https://github.com/user-attachments/assets/9fc1d9a2-94c4-4a40-9771-27e95fedee26)
- Verify VBS Status

## Verify with Device Guard and Credential Guard hardware readiness tool

Microsoft released a PowerShell script to verify the readiness of VBS with those security options on your Windows system. You can also enable and disable VBS security options with it. The script can be downloaded from here.

- Download the Device Guard and Credential Guard hardware readiness tool powershell script.
- Run the following command to verify if this device is Device Guard and Credential Guard capable.
    .\DG_Readiness_Tool_v3.6.ps1 -Capable
    ![image](https://github.com/user-attachments/assets/14cd216c-1f0c-4da3-9edd-ad5b91013a7d)
    Note: Running the script for the first time requires a reboot, because of the Driver verifier that needs to be enabled.
- Re-run the script again and this time you would see something like this.
    HVCI and Credential Guard is enabled, the only thing that is absent is TPM.
    ![image](https://github.com/user-attachments/assets/ca2da328-543c-4933-9954-43db977a6b59)

    TPM is absent and secure boot is not enabled.
- Power off the Windows VM and enable Virtualization Based Security, EFI Firmware and Security Boot.
  ![image](https://github.com/user-attachments/assets/45fe294d-33a3-40e4-a894-677bc2812a97)

- Power off the Windows VM and add a Trusted Platform Module (vTPM).
    Note: if you cannot see Trusted Platform Module under Other devices you probably don’t have a configured Key Provider in vCenter.
    ![image](https://github.com/user-attachments/assets/42e17a6a-adc3-470b-b866-dcf76e0680be)

    Add vTPM device
- Power on the Windows VM and perform the same powershell command.
   ![image](https://github.com/user-attachments/assets/a8312751-6b77-4e3f-b2d3-cc5cdebd17da)


Verify status with the readiness tool again.

We now have VBS running with Credential Guard on our Windows 2019 test VM.
