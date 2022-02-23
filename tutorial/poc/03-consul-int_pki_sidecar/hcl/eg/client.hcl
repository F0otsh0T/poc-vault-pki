{
  "service": {
    "name": "wordpress",
    "tags": [
      "wordpress",
      "production"
    ],
    "port": 80,
    "connect": {"sidecar_service": {} },
    "check": {
      "id": "wordpress",
      "name": "wordpress TCP on port 80",
      "tcp": "localhost:80",
      "interval": "10s",
      "timeout": "1s"
    }
  }
}