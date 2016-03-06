### Login to Azure. First time you have to use your browser :( In order to use on-premise instance you have to add it as additional environment. See "./azure-cli.sh account env" for more details

  ./azure-cli.sh login

### Download *.publishsettings file - you have to use your browser again :( Move to this directory and rename to credentials.publishsettings. Possible way to automate is to preinstall this file to the build host. This file is needed for packer to login to Azure. Also, next time when you want to login you can execute "./azure-cli.sh account import credentials.publishsettings" - this command will automatically log you in without browser.

  ./azure-cli.sh account download

### Create storage account - will be used to store created images. Known problem - unclear how to pass in location because of the space in location name. Anyhow most of the commands require at least some interaction with user

  ./azure-cli.sh storage account create  --type LRS packerdemo0

### Find image that you want to use as a base image and use show command to get its label - requered for packer template

  ./azure-cli.sh vm image show a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-20160126-en.us-127GB.vhd

### Build image!

  ./packer.sh build -var "scripts=." -var "ps=credentials.publishsettings" -var "sa=packerdemo0" -var "image_label=Windows Server 2012 R2 Datacenter, January 2016" template.json

### Find your image

  ./azure-cli.sh vm image list | grep Packer

### Create a Virtual Machine out of it

  ./azure-cli.sh vm create PackerMadeSlave PackerMadeWindowsSlave_2016-03-06_18-43 -g jenkins -p Password123! -r -e -z Medium

### Start VM

  ./azure-cli.sh vm start PackerMadeSlave
