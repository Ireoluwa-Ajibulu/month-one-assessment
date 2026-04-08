#!/bin/bash
yum update -y
amazon-linux-extras enable postgresql14
yum install -y postgresql-server
postgresql-setup initdb
systemctl start postgresql
systemctl enable postgresql


sudo -u postgres psql -c "CREATE USER techcorp WITH PASSWORD 'techcorp123';"
sudo -u postgres psql -c "CREATE DATABASE techcorpdb OWNER techcorp;"