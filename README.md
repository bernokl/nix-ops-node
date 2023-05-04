# Deploy caching ec2 and flake using terraform user_data

-   This is a very simple document going over how we deploy a caching server to aws
-   It assumes you have a *home*[user]/.aws/credentials_nix/config_nix
-   Lets get into our terraform directory

           cd terraform/caching-server

-   To nix run our flake we will need to add some extraOptions.
-   Add the following to terraform configuration.nix

          nix.extraOptions = ''
              extra-experimental-features = nix-command
              extra-experimental-features = flakes
            '';

-   Now to test our user_data block, add the following to the main.tf/aws_instance block
-   Note the content of the EOL file has no space in front of it
-   Also important to note the env bash -xe, because /bin/bash failed, but it allowed env I changed it

        user_data = <<-EOL
        #!env bash -xe
        # Orig with options being passed in before the configuration.nix update
        #nix run github:bernokl/nix-ops --no-write-lock-file --extra-experimental-features nix-command --extra-experimental-features flakes &>/tmp/outNix
        nix run github:bernokl/nix-ops --no-write-lock-file &> /tmp/nixOutput 
        EOL
        }

-   If this works the goal will be to put the content of the script into a seperate file
-   Lets go deploy our terraform and see what we got
-   NOTE: Everytime you apply this it will restart the machine meaning currently you will get in ip

         aws_terraform_apply

-   ssh to our instance, grab the ip from the aws-console

         ssh -i id_rsa.pem root@xx.xx.xx.xx 

-   Test for working store

         nix store ping --store http://127.0.0.1:8080 

-   Should return

         Store URL: http://127.0.0.1:8080

-   To test it locally you will need to whitelist your ip in iptables and see if our security group will let us hit the server from home
-   Note there will also need to be a security group for port 8080 whitelist of your ip in main.cf

        iptables -I INPUT 1 -s xx.xx.xx.xx/32 -j ACCEPT

-   Logged out of the machine and try:

        nix store ping --store http://xx.xx.xx.xx:8080 

-   Simple way to find out what it is serving:

        lsof /nix/store | grep starm
        ps faux | grep starma

-   Compare the pids between the two, you
-   If you have trouble hitting the server and want to confirm the traffic on the server side run:

        tcpdump -i any port 8080

