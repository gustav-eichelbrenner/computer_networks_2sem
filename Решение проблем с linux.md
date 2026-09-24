### Действие 1 - поменять образы linux

*Здесь я подставлял свои имена интерфейсов и цифры, вы по аналогии должны подставлять свои. Я скачивал образ Debian 13 trixie по этой ссылке - https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-13.7.0-amd64-netinst.iso* 

Скачать netinst debian'a и kali
Закинуть их по пути /opt/unetlab/addons/qemu/ в соответствующие папки, если их нет - создать
iso переименовать в cdrom.iso

потом подключиться по ssh в pnet и прописать следующее:
```bash
/opt/qemu/bin/qemu-img create -f qcow2 virtioa.qcow2 10G

/opt/qemu/bin/qemu-img info virtioa.qcow2

/opt/unetlab/wrappers/unl_wrapper -a fixpermissions
```

### Действие 2 - настройка linux-firewall

nano /etc/network/interfaces:
```text
source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The outer network interface
auto ens3
allow-hotplug ens3
iface ens3 inet static
	address 192.168.1.2/24
	gateway 192.168.1.1
	
# The inner network interface
auto ens4
allow-hotplug ens4
iface ens4 inet static
	address 172.16.1.254/24
```

поскольку образы кастрированные, надо подключить линукса к интернету и докачать все, что надо

Для этого создать такую сеть:
![[Pasted image 20260915121804.png]]

Подключить ее к линукс-машине, предварительно создав на ней еще 1 интерфейс (временный, после решения проблем его надо удалить):
![[Pasted image 20260915121823.png]]

Потом прописать вот это:
```bash
cat > /etc/apt/sources.list.d/debian.sources <<'EOF' 
Types: deb 
URIs: http://deb.debian.org/debian 
Suites: trixie trixie-updates 
Components: main 
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg 

Types: 
deb URIs: http://security.debian.org/debian-security 
Suites: trixie-security 
Components: main 
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg 
EOF
```

В сетевых настройках надо убрать gateway на Linux-FW тот, который подключается к роутеру, т.е. закомментить строку gateway 192.168.1.1 (пример)
Потом прописать вот это:
```bash
# The temporary internet interface
auto ens5
iface ens5 inet dhcp
```
потом перезагрузить службу 
```bash
systemctl restart networking.service
```

и потом писать apt update

### Сохранение исправленного шаблона линукса

Выключаем ноду, прописав poweroff. Делать только так! Не выключать ее из интерфейса PNET!

Подключаемся к виртуалке по ssh и ищем виртуальный диск этой "докачанной" ноды:
```bash
find /opt/unetlab/tmp -name virtioa.qcow2 -ls
```
Искать надо тот диск, который вы изменяли вот ровно сегодня, от вашего времени минус 3 часа +-
![[Pasted image 20260915123044.png]]

Сделаем резервную копию временного диска, чтобы потом по надобности откатить изменения:
```bash
cp /opt/unetlab/addons/qemu/linux-Debian-13-SRV/virtioa.qcow2 /opt/unetlab/addons/qemu/virtioa-clean-Debian-13.qcow2
```

Далее выполняем коммит в каталоге временного диска ноды:
```bash
mkdir -p /opt/unetlab/addons/qemu/linux-kali-custom

/opt/qemu/bin/qemu-img convert -p -O qcow2 \
  /opt/unetlab/tmp/3/92/virtioa.qcow2 \
  /opt/unetlab/addons/qemu/linux-kali-custom/virtioa.qcow2
```
