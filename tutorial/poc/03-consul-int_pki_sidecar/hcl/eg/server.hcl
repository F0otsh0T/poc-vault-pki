{
  "bootstrap_expect": 3,
  "client_addr": "0.0.0.0",
  "datacenter": "Us-Central",
  "data_dir": "/var/consul",
  "domain": "consul",
  "enable_script_checks": true,
  "dns_config": {
    "enable_truncate": true,
    "only_passing": true
  },
  "enable_syslog": true,
  "encrypt": "goplCZgdmOFMZ2Q43To0jw==",
  "leave_on_terminate": true,
  "log_level": "INFO",
  "rejoin_after_leave": true,
  "server": true,
  "start_join": [
    "10.128.0.2",
    "10.128.0.3",
    "10.128.0.4"
  ],
  "ui": true
}
