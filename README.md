Note: The package mananger and the java versions should be changed depending on the OS of the jenkins server.
       Also remember to set the python interpreter for the remote host, if required. 

Steps to create a jenkins servers using ansible

1. Run the config-user.sh file on the jenkins servers

2. Copy the public key from the ansible control node for SSH access in the "authorized_keys"\n  
   file of the new user in jenkins server ( ssh-copy-id jenkins_user@jenkins_server_ip )

3. Configure ansible hosts on the ansible control node (jenk_inventory.ini)

4. Run the playbook
