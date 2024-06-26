{ ovmf, pkgs, ... }: pkgs.writeText "hassos.xml" /* xml */ ''
  <domain type='kvm'>
    <name>hassos</name>
    <uuid>d732646e-f206-46b5-ad6f-2e78b0c277a3</uuid>
    <metadata>
      <libosinfo:libosinfo xmlns:libosinfo="http://libosinfo.org/xmlns/libvirt/domain/1.0">
        <libosinfo:os id="http://redhat.com/rhel/8.1"/>
      </libosinfo:libosinfo>
    </metadata>
    <memory unit='KiB'>4194304</memory>
    <currentMemory unit='KiB'>4194304</currentMemory>
    <vcpu placement='static'>4</vcpu>
    <os>
      <type arch='x86_64' machine='pc-q35-5.2'>hvm</type>
      <loader readonly='yes' type='pflash'>${ovmf}/FV/OVMF_CODE.fd</loader>
      <nvram>/home/akos/libvirt/hassos_VARS.fd</nvram>
      <boot dev='hd'/>
    </os>
    <features>
      <acpi/>
      <apic/>
    </features>
    <cpu mode='host-model' check='partial'/>
    <clock offset='utc'>
      <timer name='rtc' tickpolicy='catchup'/>
      <timer name='pit' tickpolicy='delay'/>
      <timer name='hpet' present='no'/>
    </clock>
    <on_poweroff>destroy</on_poweroff>
    <on_reboot>restart</on_reboot>
    <on_crash>destroy</on_crash>
    <pm>
      <suspend-to-mem enabled='no'/>
      <suspend-to-disk enabled='no'/>
    </pm>
    <devices>
    <emulator>/run/current-system/sw/bin/qemu-system-x86_64</emulator>
      <disk type='file' device='disk'>
        <driver name='qemu' type='qcow2'/>
        <source file='/home/akos/libvirt/images/hassos.qcow2'/>
        <target dev='vda' bus='virtio'/>
        <address type='pci' domain='0x0000' bus='0x04' slot='0x00' function='0x0'/>
      </disk>
      <controller type='usb' index='0' model='qemu-xhci' ports='15'>
        <address type='pci' domain='0x0000' bus='0x02' slot='0x00' function='0x0'/>
      </controller>
      <controller type='sata' index='0'>
        <address type='pci' domain='0x0000' bus='0x00' slot='0x1f' function='0x2'/>
      </controller>
      <controller type='pci' index='0' model='pcie-root'/>
      <controller type='pci' index='1' model='pcie-root-port'>
        <model name='pcie-root-port'/>
        <target chassis='1' port='0x8'/>
        <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x0' multifunction='on'/>
      </controller>
      <controller type='pci' index='2' model='pcie-root-port'>
        <model name='pcie-root-port'/>
        <target chassis='2' port='0x9'/>
        <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x1'/>
      </controller>
      <controller type='pci' index='3' model='pcie-root-port'>
        <model name='pcie-root-port'/>
        <target chassis='3' port='0xa'/>
        <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x2'/>
      </controller>
      <controller type='pci' index='4' model='pcie-root-port'>
        <model name='pcie-root-port'/>
        <target chassis='4' port='0xb'/>
        <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x3'/>
      </controller>
      <controller type='pci' index='5' model='pcie-root-port'>
        <model name='pcie-root-port'/>
        <target chassis='5' port='0xc'/>
        <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x4'/>
      </controller>
      <controller type='pci' index='6' model='pcie-root-port'>
        <model name='pcie-root-port'/>
        <target chassis='6' port='0xd'/>
        <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x5'/>
      </controller>
      <controller type='pci' index='7' model='pcie-root-port'>
        <model name='pcie-root-port'/>
        <target chassis='7' port='0xe'/>
        <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x6'/>
      </controller>
      <controller type='virtio-serial' index='0'>
        <address type='pci' domain='0x0000' bus='0x03' slot='0x00' function='0x0'/>
      </controller>
      <interface type='bridge'>
        <mac address='52:54:00:64:11:7b'/>
        <source bridge='br0'/>
        <model type='virtio'/>
        <link state='up'/>
        <address type='pci' domain='0x0000' bus='0x01' slot='0x00' function='0x0'/>
      </interface>
      <serial type='pty'>
        <target type='isa-serial' port='0'>
          <model name='isa-serial'/>
        </target>
      </serial>
      <console type='pty'>
        <target type='serial' port='0'/>
      </console>
      <channel type='unix'>
        <target type='virtio' name='org.qemu.guest_agent.0'/>
        <address type='virtio-serial' controller='0' bus='0' port='1'/>
      </channel>
      <input type='mouse' bus='ps2'/>
      <input type='keyboard' bus='ps2'/>
      <audio id='1' type='none'/>
      <memballoon model='virtio'>
        <address type='pci' domain='0x0000' bus='0x05' slot='0x00' function='0x0'/>
      </memballoon>
      <rng model='virtio'>
        <backend model='random'>/dev/urandom</backend>
        <address type='pci' domain='0x0000' bus='0x06' slot='0x00' function='0x0'/>
      </rng>
    </devices>
  </domain>
''
