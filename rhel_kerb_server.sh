#!/bin/bash

subscription-manager repos --enable=rhel-8-for-x86_64-baseos-rpms
subscription-manager repos --enable=rhel-8-for-x86_64-appstream-rpms

yum module enable idm:DL1
yum distro-sync
yum module install idm:DL1/server

ipa-server-install --realm OCTO-EMERGING.REDHATAICOE.COM --ds-password $DS_PASSWORD --admin-password $ADMIN_PASSWORD --unattended

