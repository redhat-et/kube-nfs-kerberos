#!/bin/bash

set -e

ipa-client-install --principal admin --password $PASSWORD --server idm.octo-emerging.redhataicoe.com --domain octo-emerging.redhataicoe.com --realm OCTO-EMERGING.REDHATAICOE.COM --unattended

kinit admin

# ipa-client-automount --no-sssd
