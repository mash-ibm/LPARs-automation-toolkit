clear
echo "################"
echo "##VERSION_16.6##"
echo "#####################################################################"
echo "Hello! My name's Mash ©,  This program will help you create 2 virtual"
echo "Ethernet adapters with their additional VLAN IDs and trunk priorities"
echo "In each VIOS server. The program is only for internal use and should"
echo "Not be supplied to customers"
echo " Copyright 2015 by Ahmed (Mash)Mashhour <ahdmashr@eg.ibm.com>"
echo "###################################################################"
sleep 3
echo ""
unset eth i lln lname lparid newnum num vfc1 vfc2 vfc3 vfc4 vios1 vios2 VLANS

echo "You have The following system(s) managed by this HMC:"
echo ""
lssyscfg -r sys -F name

echo ""
echo "Please enter your preferred managed sysyem in which you will configure the VLANs"
read MS

echo ""
echo "Please enter your first VIOS partition Name"
read vios1

echo ""

echo "Please enter your second VIOS partition name"
read vios2
export MS vios1 vios2
echo ""

echo "Please enter the additional VLAN ID(s) you want to add separated by a simple comma"
echo "Example"
echo "          If you want to add a single VLAN only like 55, then just write 55 and press enter"
echo "          If you want to add multiple VLAN IDs like 55 66 77.., then just write them separated by simple comma:"
echo "          55,66,77"
echo ""
#mksyscfg -r lpar -m $MS -i "name=$vios1, profile_name=default_profile, lpar_env=vioserver, min_mem=1024, desired_mem=1024, max_mem=2048, proc_mode=shared, min_procs=1, desired_procs=2, max_procs=4, min_proc_units=0.5, desired_proc_units=1, max_proc_units=2, sharing_mode=uncap, uncap_weight=128, conn_monitoring=1, boot_mode=norm, sync_curr_profile=1, max_virtual_slots=3000"

#mksyscfg -r lpar -m $MS -i "name=$vios2, profile_name=default_profile, lpar_env=vioserver, min_mem=1024, desired_mem=1024, max_mem=2048, proc_mode=shared, min_procs=1, desired_procs=2, max_procs=4, min_proc_units=0.5, desired_proc_units=1, max_proc_units=2, sharing_mode=uncap, uncap_weight=128, conn_monitoring=1, boot_mode=norm, sync_curr_profile=1, max_virtual_slots=3000"

read VLANS
export VLANS
sleep 1
chsyscfg -r prof -m $MS -i "name=default_profile,lpar_name=$vios1,\"virtual_eth_adapters+=\"\"2/1/1/$VLANS/1/1\"\",3/0/999///1\"" --force
#chsyscfg -r prof -m $MS -i "name=default_profile,lpar_name=$vio1,\"virtual_eth_adapters+=\"\"2/1/1/$VLANS/1/1\"\",3/0/999///1\"" --force
#chsyscfg -r prof -m $MS -i "name=default_profile,lpar_name=$vios1,\"virtual_eth_adapters+=\"\"20/1/1/$VLANS/1/1\"\"\"" --force
#chsyscfg -r prof -m $MS -i "name=default_profile,lpar_name=$vios1,\"virtual_eth_adapters=30/0/999//0/1/\"" --force
sleep 6

chsyscfg -r prof -m $MS -i "name=default_profile,lpar_name=$vios2,\"virtual_eth_adapters+=\"\"2/1/1/$VLANS/2/1\"\",3/0/999///1\"" --force
#chsyscfg -r prof -m $MS -i "name=default_profile,lpar_name=$vio2,\"virtual_eth_adapters+=\"\"3/1/1/$VLANS/2/1\"\",3/0/999///1\"" --force
#chsyscfg -r prof -m $MS -i "name=default_profile,lpar_name=$vios2,\"virtual_eth_adapters=30/0/999//0/1/\"" --force
#chsyscfg -r prof -m $MS -i "name=default_profile,lpar_name=$vios2,\"virtual_eth_adapters+=\"\"20/1/1/$VLANS/1/1\"\"\"" --force
sleep 6

for i in $vios1 $vios2
do
chsysstate -o on -r lpar -m $MS -n $i -f default_profile
sleep 1
chsysstate -o shutdown --immed -r lpar -m $MS -n $i
done
#sleep 1
#lshwres -m $MS -r virtualio --rsubtype eth --level lpar --filter "lpar_names=$vios1"
#echo ""
#echo ""
#lshwres -m $MS -r virtualio --rsubtype eth --level lpar --filter "lpar_names=$vios2"

echo ""
echo ""
lshwres -m $MS -r virtualio --rsubtype eth --level lpar --filter "lpar_names=$vios1"
echo ""
echo ""
lshwres -m $MS -r virtualio --rsubtype eth --level lpar --filter "lpar_names=$vios2"
