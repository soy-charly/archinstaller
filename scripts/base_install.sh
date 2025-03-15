#!/bin/bash

pacstrap /mnt base linux linux-firmware nano sudo
genfstab -U /mnt >> /mnt/etc/fstab
