#!/bin/bash
#["http://f1361db2.m.daocloud.io", "http://hub-mirror.c.163.com", "https://registry.docker-cn.com"]

cat >> /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": ["http://hub-mirror.c.163.com"]
}
EOF

sudo systemctl restart docker.service
echo "registry-mirrors is ok"