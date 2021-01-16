#!/bin/bash
cat <<'EOF' > /home/ec2-user/main.go
package main

import (
        "fmt"
        "net/http"
        "os"
)

func main() {
        http.HandleFunc("/", HelloServer)
        http.ListenAndServe(":8080", nil)
}

func HelloServer(w http.ResponseWriter, r *http.Request) {
        hostname, _ := os.Hostname()
        fmt.Fprintf(w, "Hello, World! From %v\n", hostname)
}
EOF
yum install golang -y
(crontab -l 2>/dev/null; echo "@reboot nohup go run /home/ec2-user/main.go") | crontab -
export GOCACHE=/tmp/go-cache
nohup go run /home/ec2-user/main.go
