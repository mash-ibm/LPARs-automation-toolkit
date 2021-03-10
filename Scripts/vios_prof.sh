clear
echo "################"
echo "##VERSION_16.6##"
echo "##################################################################"
echo "Hello! My name's Mash ©,  This program will help you create 2 VIO"
echo "Servers. It's only for internal use and should not be supplied to"
echo "Customers. Copyright 2015 by Ahmed Mashhour <ahdmashr@eg.ibm.com>"
echo "##################################################################"
sleep 3
echo ""
unset eth i lln lname lparid newnum num vfc1 vfc2 vfc3 vfc4 vios1 vios2

echo "You have The following system(s) managed by this HMC:"
echo ""
lssyscfg -r sys -F name

echo ""
echo "Please enter your preferred managed sysyem in which you will create both VIO servers in"
read MS

echo ""
echo "Please enter your first VIOS partition Name"
read vios1

echo ""

echo "Please enter your second VIOS partition name"
read vios2

echo ""

mksyscfg -r lpar -m $MS -i "name=$vios1, profile_name=default_profile, lpar_env=vioserver, min_mem=1024, desired_mem=1024, max_mem=2048, proc_mode=shared, min_procs=1, desired_procs=2, max_procs=4, min_proc_units=0.5, desired_proc_units=1, max_proc_units=2, sharing_mode=uncap, uncap_weight=128, conn_monitoring=1, boot_mode=norm, sync_curr_profile=1, max_virtual_slots=3000"

mksyscfg -r lpar -m $MS -i "name=$vios2, profile_name=default_profile, lpar_env=vioserver, min_mem=1024, desired_mem=1024, max_mem=2048, proc_mode=shared, min_procs=1, desired_procs=2, max_procs=4, min_proc_units=0.5, desired_proc_units=1, max_proc_units=2, sharing_mode=uncap, uncap_weight=128, conn_monitoring=1, boot_mode=norm, sync_curr_profile=1, max_virtual_slots=3000"

lssyscfg -r lpar -m $MS -F name | egrep "$vios1|$vios2"
if [[ $? -eq 0 ]]
then


lssyscfg -r lpar -m $MS --filter lpar_names="$vios1"

echo ""
echo ""

lssyscfg -r lpar -m $MS --filter lpar_names="$vios2"
echo ""
echo ""
echo $vios1 and $vios2 created successfully at your $MS managed system.
else
echo ""
echo ""
echo ""
echo "Something went wrong while creating VIO servers.."
fi
