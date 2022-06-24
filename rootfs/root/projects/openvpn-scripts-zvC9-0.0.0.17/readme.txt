# openvpn-scripts-zvC9

These scripts and usage instruction were created by an amateur. Don't use them
until you check that they are suitable and secure.

These are amateur scripts to setup OpenVPN with TLS for Linux. Scripts generate
keys (ED25519), CSRs, CERTs, configs and dhparam(s).

(these scripts don't install OpenVPN/OpenSSL and don't work under Windows;
scroll to the end of this file to read about Windows)

ed25519 keys are used.

You have 3 machines: CA, client, server.
Can be CA=server or CA=client.
Can NOT be client=server.

Note: where you are going to type "${netname}", type value of variable "netname", which
you have set in "bashlib/openvpn-openssl-vars.bash". If it's set to "mytestnet1",
string "${netname}" becomes "mytestnet1".

What to do (how to use scripts):
- Edit "bashlib/openvpn-openssl-vars.bash"
- Copy whole project directory "openvpn-scripts-zvC9" with edited
  "openvpn-scripts-zvC9/bashlib/openvpn-openssl-vars.bash"
  to client, server, CA (easier to use CA=server or CA=client).
- On client and on server launch  "generate-openvpn-configs.bash"
- On client launch "client-generate-openvpn-client-key-and-CSR.bash"
- On server launch "server-generate-openvpn-server-key-and-CSR-and-dhparam.bash"
  (this is going to take long time)
- On CA, launch "CA-generate-openvpn-CAkey.bash"
- copy from client "created_files_for_use/client/generated/${netname}/${netname}-tls-client.csr.pem"
  into same directory on CA
- copy from server "created_files_for_use/server/generated/${netname}/${netname}-tls-server.csr.pem"
  into same directory on CA
- launch "CA-sign-CSRs.bash" on CA
- from CA copy file "created_files_for_use/client/generated/${netname}/${netname}-tls-client.ca-signed.cert.pem"
  into same directory on client
- from CA copy file "created_files_for_use/server/generated/${netname}/${netname}-tls-server.ca-signed.cert.pem"
  into same directory on server
- On server, copy "created_files_for_use/server/generated/${netname}" into "/etc/openvpn/generated/"
- On server, copy "created_files_for_use/server/${netname}-tls-server.conf" into "/etc/openvpn/"
- On client, copy "created_files_for_use/client/generated/${netname}" into "/etc/openvpn/generated/"
- On client, copy "created_files_for_use/client/${netname}-tls-client.conf" into "/etc/openvpn/"
- On server, if you are using systemd init system, run in bash as root
  "systemctl enable openvpn@${netname}-tls-server", where variable "netname" has value which
  you configured in "bashlib/openvpn-openssl-vars.bash"
Note: you can run "source bashlib/openvpn-openssl-vars.bash" in bash to set variables.
- On client, if you are using systemd init system, run in bash as root
  "systemctl enable openvpn@${netname}-tls-client", where variable "netname" has value which
  you configured in "bashlib/openvpn-openssl-vars.bash"
Note: you can run "source bashlib/openvpn-openssl-vars.bash" in bash to set variables.
- If you are using non-systemd init system, find other way to configure openvpn to start on boot.
- Reboot to launch openvpn or use terminal to launch it (with systemd can do this:
  "systemctl start openvpn@${netname}-tls-server" on server,
  "systemctl start openvpn@${netname}-tls-client" on client. Before running set
  "netname" variable as it is set in "bashlib/openvpn-openssl-vars.bash")


Note: can manually launch openvpn this way:
  server: "openvpn --config /etc/openvpn/${netname}-tls-server.conf",
  client: "openvpn --config /etc/openvpn/${netname}-tls-client.conf",
 or this way:
  server: "screen -S openvpn-${netname} openvpn --config /etc/openvpn/${netname}-tls-server.conf",
  client: "screen -S openvpn-${netname} openvpn --config /etc/openvpn/${netname}-tls-client.conf",
 (install GNU Screen)
 (!) don't forget to set "netname" variable as it is set in "bashlib/openvpn-openssl-vars.bash"
 or 1st, run in bash "source .../openvpn-scripts-zvC9/bashlib/openvpn-openssl-vars.bash"




---------------------------------CUT----HERE----------------------------------
(don't read next unless you want to use under Windows)
(if you can copy secret files securely from Linux to Windows (like if you are running
Linux inside a VirtualMachine under Windows and have shared folders or SSH access
from Win to Linux (use OpenSSH-server, PuTTY,  VirtualBOX, QEmu, ...) configured;
or like if you have Windows VirtualMachine running under Linux (use brasero or k3b
or xorrisofs to create .iso file with secret files and with other files; use
QEmu/VirtualBox/... to run VirtualMachine with Windows; attach that .iso file to
VirtualMachine)), you can use these scripts for Windows (may be, also need to
change extension of .conf files to ".ovpn" and change .conf files, setting "topology net30",
setting "ifconfig ... ..." ("ifconfig ip netmask" or "ifconfig ip ip")))

from man 8 openvpn:
"
--topology mode
...
net30  --  Use  a point-to-point topology, by allocating one /30 subnet per client.
This is designed to allow point-to-point semantics when
some or all of the connecting clients might be Windows systems.  This is the default on OpenVPN 2.0.
...
"

