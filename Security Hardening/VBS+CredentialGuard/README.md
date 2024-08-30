
# Virtualization based security (VBS) and Guard Credentials

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

    ![App Screenshot](https://via.placeholder.com/468x300?text=App+Screenshot+Here)

- Enter a name for the vSphere Native Key Provider and enable the Use Key Provider only with TPM protected ESXI hosts if needed. 

    Note: Use Key Provider only with TPM protected ESXI hosts will only enable the vSphere Key Provider on hosts that that physcially has a TPM 2.0 chip.

    ![App Screenshot](https://via.placeholder.com/468x300?text=App+Screenshot+Here)

- Create a backup of the vSphere Native Key Provider.

    ![App Screenshot](https://via.placeholder.com/468x300?text=App+Screenshot+Here)

- Backup Key Provider

    ![App Screenshot](https://via.placeholder.com/468x300?text=App+Screenshot+Here)

- Protect Native Key Provider data with password

    ![App Screenshot](https://via.placeholder.com/468x300?text=App+Screenshot+Here)

- Native Key Provider is up and running

    ![App Screenshot](https://via.placeholder.com/468x300?text=App+Screenshot+Here)
