#!/usr/bin/env bash
# Copyright 2014-2018, Rackspace US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

export LIBVIRT_DEFAULT_URI=qemu:///system

function prepare_venv {
    if [ ! -d "$HOME/osp" ]; then
        if ! [ -x "$(command -v virtualenv)" ]; then
            sudo yum install -y python-virtualenv
        fi
        virtualenv $HOME/osp
        source $HOME/osp/bin/activate
        pip install ansible ara
    fi
    source $HOME/osp/bin/activate
}

function prepare_vm_host {
    prepare_venv
    pushd $PWD/playbooks
    ansible-playbook -i inventory -i plugins/libvirt_inv.py prepare_vm.yml
}

function configure_undercloud {
    # At this point we have ansible installed
    prepare_venv 
    pushd $PWD/playbooks
    export ANSIBLE_HOST_KEY_CHECKING=False
    ansible-playbook -i inventory -i plugins/libvirt_inv.py deploy_director.yml
}

function configure_overcloud {
    prepare_venv 
    pushd $PWD/playbooks
    ansible-playbook -i inventory -i plugins/libvirt_inv.py deploy_overcloud.yml
}
