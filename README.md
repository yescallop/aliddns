# aliddns

A bash script with systemd units providing DDNS service through Aliyun OpenAPI.

## Installation

Edit `aliddns.sh` as instructed in the file and run the following commands as root.

```bash
install -m700 aliddns.sh /usr/local/sbin/
install -m644 aliddns.service aliddns.timer /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now aliddns.timer
```

Use `journalctl -u aliddns` to see the log messages.
The service logs only when a domain record is updated or an error occurs,
so you might not be seeing any messages.
One way to test if the service actually works is to manually edit the domain record
and see if there will be a log message saying `Update: IP ADDRESS` when the timer triggers.
