#!/bin/bash

yum install -y nfs-utils
yum module install -y idm
ipa-client-install

