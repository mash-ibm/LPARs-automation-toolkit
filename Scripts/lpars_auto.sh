                                                
clear
sleep 1
echo "################"
echo "##VERSION_20##"
sleep 1
echo "#####################################################################"
echo "Hello! My name's Mash ©, This program will help you automate LPAR's"
echo "Creaion. It's only for internal use and should not be supplied"
echo "To Customers. Copyright 2015 by Ahmed Mashhour <ahdmashr@eg.ibm.com>"
echo "######################################################################"
sleep 5
echo ""



while true
do
echo "Please make up your selection by entering the corresponding two-digit number"
sleep 2
echo "
01) Creating AIX/Linux LPARs
02) Creating System I LPARs
03) Abort the program"
read selection
case $selection in
01)
echo "You have selected to create AIX/Linux LPARs"
echo ""
sleep 2

unset eth i lln lname lparid newnum num vfc1 vfc2 vfc3 vfc4 vios1 vios2
echo "You have The following system(s) managed by this HMC:"
echo ""
lssyscfg -r sys -F name

echo "Please enter your preferred managed sysyem in which you will create the LPAR's In"
read MS
sleep 1


echo ""
lssyscfg -r lpar -m $MS -F name,lpar_env | grep -i vioserver | cut -d "," -f 1 | sort
echo ""
echo "You have the above VIO servers in your $MS"

echo ""
echo "Please enter your first selected VIOS host partition Name"
read vios1
sleep 1


echo "Please enter your second selected VIOS host partition name"
read vios2
sleep 1

export V1P=`lssyscfg -r lpar -m $MS -F name,lpar_env,default_profile | grep -i vioserver | grep $vios1 |sort | cut -d "," -f 3 | sort`
export V2P=`lssyscfg -r lpar -m $MS -F name,lpar_env,default_profile | grep -i vioserver | grep $vios1 |sort | cut -d "," -f 3 | sort`


echo "Please enter The number of AIX/Linux LPAR's you want to create"
read num

echo ""

echo "Please enter the LPAR names you want to create separated by a normal space, then press the enter button once finished"
read lname
export MS vios1 vios2 num lname


export lparid=1
#export eth=10
export vfc1=1
export vfc2=2
export vfc3=3
export vfc4=4
newnum=$(expr $num + 1)

while [[ $lparid -lt $newnum ]]
do
for lln in `echo $lname`
do
export OLDID=`lssyscfg -r lpar -m $MS -F lpar_id | sort -n | tail -1`
export NEWID=$(expr $OLDID + 1)
mksyscfg -r lpar -m $MS -i "name=$lln, profile_name=default_profile,
lpar_env=aixlinux, lpar_id=$NEWID, min_mem=1024, desired_mem=2048, max_mem=2048,
proc_mode=shared, min_procs=1, desired_procs=2, max_procs=4,
min_proc_units=0.5, desired_proc_units=1, max_proc_units=2,
sharing_mode=uncap, uncap_weight=128, conn_monitoring=1,
boot_mode=norm, max_virtual_slots=3000,
\"virtual_eth_adapters=2/0/1//0/0/\",
\"virtual_fc_adapters=$NEWID$vfc1/client//$vios1/$NEWID$vfc1//1,$NEWID$vfc2/client//$vios2/$NEWID$vfc2//1,$NEWID$vfc3/client//$vios1/$NEWID$vfc3//1,$NEWID$vfc4/client//$vios2/$NEWID$vfc4//1\" "
echo " "
echo ""
echo ""
echo #####################################################
export LPNAME=`lssyscfg -m $MS -r prof --filter "lpar_names=$lln" -F lpar_name,virtual_fc_adapters | cut -d "," -f 1`

echo "For $LPNAME LPAR:"
echo The 1st virtual fiber adapter id is: $NEWID$vfc1
echo The 2nd virtual fiber adapter id is: $NEWID$vfc2
echo The 3rd virtual fiber adapter id is: $NEWID$vfc3
echo The 4th virtual fiber adapter id is: $NEWID$vfc4

sleep 2
##########################
##VIOS1_VFC1_CONFIGURATION
##########################
echo ""
echo ""
chhwres -m $MS -r virtualio --rsubtype fc -o a -p $vios1  -a "adapter_type=server,remote_lpar_name=$LPNAME,remote_slot_num=$NEWID$vfc1" -s $NEWID$vfc1
if [[ $? -eq 0 ]]

then
mksyscfg -r prof -m $MS -o save -p $vios1 -n $V1P --force

else
echo ""
echo ""
echo "Something went wrong while dynamically adding the VFC slot number $NEWID$vfc1 in $vios1"
echo ""
echo ""
echo "It will be manually added to $vios1 instead, you just need to shutdown and activate $vios1 after the program ends"
echo ""

chsyscfg -r prof -m $MS -i "name=$V1P, lpar_name=$vios1, \"virtual_fc_adapters+=$NEWID$vfc1/server//$LPNAME/$NEWID$vfc1//1\"" --force

sleep 2
fi



##########################
##VIOS1_VFC3_CONFIGURATION
##########################
echo ""
echo ""
chhwres -m $MS -r virtualio --rsubtype fc -o a -p $vios1  -a "adapter_type=server,remote_lpar_name=$LPNAME,remote_slot_num=$NEWID$vfc3" -s $NEWID$vfc3
if [[ $? -eq 0 ]]
then
mksyscfg -r prof -m $MS -o save -p $vios1 -n $V1P --force

else
echo ""
echo ""

echo "Something went wrong while dynamically adding the VFC slot number $NEWID$vfc3 in $vios1"
echo ""
echo "It will be manually added to $vios1 instead, you just need to shutdown and activate $vios1 after the program ends"
echo ""

chsyscfg -r prof -m $MS -i "name=$V1P, lpar_name=$vios1, \"virtual_fc_adapters+=$NEWID$vfc3/server//$LPNAME/$NEWID$vfc3//1\"" --force

sleep 2
fi



##########################
##VIOS2_VFC2_CONFIGURATION
##########################
echo ""
echo ""
chhwres -m $MS -r virtualio --rsubtype fc -o a -p $vios2  -a "adapter_type=server,remote_lpar_name=$LPNAME,remote_slot_num=$NEWID$vfc2" -s $NEWID$vfc2

if [[ $? -eq 0 ]]
then
mksyscfg -r prof -m $MS -o save -p $vios2 -n $V2P --force

else
echo ""
echo ""

echo "Something went wrong while dynamically adding the VFC slot number $NEWID$vfc2 in $vio2"
echo ""
echo "It will be manually added to $vios2 instead, you just need to shutdown and activate $vios2 after the program ends"

chsyscfg -r prof -m $MS -i "name=$V2P, lpar_name=$vios2, \"virtual_fc_adapters+=$NEWID$vfc2/server//$LPNAME/$NEWID$vfc2//1\"" --force

sleep 2
fi



##########################
##VIOS2_VFC4_CONFIGURATION
##########################
echo ""
echo ""
chhwres -m $MS -r virtualio --rsubtype fc -o a -p $vios2  -a "adapter_type=server,remote_lpar_name=$LPNAME,remote_slot_num=$NEWID$vfc4" -s $NEWID$vfc4

if [[ $? -eq 0 ]]
then
mksyscfg -r prof -m $MS -o save -p $vios2 -n $V2P --force

else
echo ""
echo ""
echo "Something went wrong while dynamically adding the VFC slot number $NEWID$vfc4 in $vio2"
echo ""
echo "It will be manually added to $vios2 instead, you just need to shutdown and activate $vios2 after the program ends"
chsyscfg -r prof -m $MS -i "name=$V2P, lpar_name=$vios2, \"virtual_fc_adapters+=$NEWID$vfc4/server//$LPNAME/$NEWID$vfc4//1\"" --force

sleep 2
fi

export lparid=$(expr $lparid + 1)
done
done
sleep 3
echo ""
echo ""
echo "Saving current configuration.."
sleep 4
clear
echo '   |'
sleep 1
clear
echo '   /'
sleep 1
clear
echo '   -'
sleep 1
clear
echo '   \'
sleep 1
clear
echo '   |'
sleep 1
clear
echo '   /'
sleep 1
clear
echo '   -'
sleep 1
clear
echo '   \'
sleep 1
clear

######################################################

#export V1P=`lssyscfg -r lpar -m $MS -F name,lpar_env,default_profile | grep -i vioserver | grep $vios1 |sort | cut -d "," -f 3 | sort`
#export V2P=`lssyscfg -r lpar -m $MS -F name,lpar_env,default_profile | grep -i vioserver | grep $vios1 |sort | cut -d "," -f 3 | sort`

#mksyscfg -r prof -m $MS -o save -p $vios1 -n $V1P --force
#mksyscfg -r prof -m $MS -o save -p $vios2 -n $V2P --force

echo #####################################################
echo ""
echo "$num LPAR(s) Successfully Created
All with one virtual ethernet adapter and four virtual fibre cards from both $vios1 and $vios2 servers"
sleep 2
echo ""
echo ""
echo ""
echo "You have all the following LPAR's in your $MS"
echo " "
lssyscfg -r lpar -m $MS -F name
echo " "
echo " "
echo " "

echo The newly created LPARs will be activated and shutdown to activate the fiber cards so we can get the WWPN
echo ""
echo "Please wait until the LPARs are getting recycled"
for i in `echo $lname`
do
chsysstate -o on -r lpar -m $MS -n $i -f default_profile
sleep 1
chsysstate -o shutdown --immed -r lpar -m $MS -n $i
done


echo Now your WWPNs for newly created AIX LPARs are:
for i in `echo $lname`
do
lshwres -r virtualio --rsubtype fc -m $MS --level lpar -F lpar_name,slot_num,wwpns --header |grep -v null | egrep $i
done |sort -n 

echo ""
echo "Thanks................. Mash ©"
;;

02)
echo "You have selected to create System I LPARs"
echo ""
sleep 2


unset eth i lln lname lparid newnum num vfc1 vfc2 vfc3 vfc4 vios1 vios2
echo "You have The following system(s) managed by this HMC:"
echo ""
lssyscfg -r sys -F name

echo "Please enter your preferred managed sysyem in which you will create the LPAR's In"
read MS
sleep 1


echo ""
lssyscfg -r lpar -m $MS -F name,lpar_env | grep -i vioserver | cut -d "," -f 1 | sort
echo ""
echo "You have the above VIO servers in your $MS"

echo ""
echo "Please enter your first selected VIOS host partition Name"
read vios1
sleep 1


echo "Please enter your second selected VIOS host partition name"
read vios2
sleep 1

export V1P=`lssyscfg -r lpar -m $MS -F name,lpar_env,default_profile | grep -i vioserver | grep $vios1 |sort | cut -d "," -f 3 | sort`
export V2P=`lssyscfg -r lpar -m $MS -F name,lpar_env,default_profile | grep -i vioserver | grep $vios1 |sort | cut -d "," -f 3 | sort`



echo "Please enter The number of System I LPARs you want to create"
read num

echo ""

echo "Please enter the LPAR names you want to create separated by a normal space, then press the enter button once finished"
read lname
export MS vios1 vios2 num lname


export lparid=1
#export eth=10
export vfc1=1
export vfc2=2
export vfc3=3
export vfc4=4
newnum=$(expr $num + 1)

while [[ $lparid -lt $newnum ]]
do
for lln in `echo $lname`
do
export OLDID=`lssyscfg -r lpar -m $MS -F lpar_id | sort -n | tail -1`
export NEWID=$(expr $OLDID + 1)
mksyscfg -r lpar -m $MS -i "name=$lln, profile_name=default_profile,
lpar_env=os400, console_slot=hmc, lpar_id=$NEWID, min_mem=1024, desired_mem=2048, max_mem=2048,
proc_mode=shared, min_procs=1, desired_procs=2, max_procs=4,
min_proc_units=0.5, desired_proc_units=1, max_proc_units=2,
sharing_mode=uncap, uncap_weight=128, conn_monitoring=1,
max_virtual_slots=3000,
\"virtual_eth_adapters=2/0/1//0/0/\",
\"virtual_fc_adapters=$NEWID$vfc1/client//$vios1/$NEWID$vfc1//1,$NEWID$vfc2/client//$vios2/$NEWID$vfc2//1,$NEWID$vfc3/client//$vios1/$NEWID$vfc3//1,$NEWID$vfc4/client//$vios2/$NEWID$vfc4//1\" "
echo " "
echo ""
echo ""
echo #####################################################
export LPNAME=`lssyscfg -m $MS -r prof --filter "lpar_names=$lln" -F lpar_name,virtual_fc_adapters | cut -d "," -f 1`

echo "For $LPNAME LPAR:"
echo The 1st virtual fiber adapter id is: $NEWID$vfc1
echo The 2nd virtual fiber adapter id is: $NEWID$vfc2
echo The 3rd virtual fiber adapter id is: $NEWID$vfc3
echo The 4th virtual fiber adapter id is: $NEWID$vfc4

sleep 2
##########################
##VIOS1_VFC1_CONFIGURATION
##########################
echo ""
echo ""
chhwres -m $MS -r virtualio --rsubtype fc -o a -p $vios1  -a "adapter_type=server,remote_lpar_name=$LPNAME,remote_slot_num=$NEWID$vfc1" -s $NEWID$vfc1
if [[ $? -eq 0 ]]

then
mksyscfg -r prof -m $MS -o save -p $vios1 -n $V1P --force

else
echo ""
echo ""
echo "Something went wrong while dynamically adding the VFC slot number $NEWID$vfc1 in $vios1"
echo ""
echo ""
echo "It will be manually added to $vios1 instead, you just need to shutdown and activate $vios1 after the program ends"
echo ""

chsyscfg -r prof -m $MS -i "name=$V1P, lpar_name=$vios1, \"virtual_fc_adapters+=$NEWID$vfc1/server//$LPNAME/$NEWID$vfc1//1\"" --force

sleep 2
fi



##########################
##VIOS1_VFC3_CONFIGURATION
##########################
echo ""
echo ""
chhwres -m $MS -r virtualio --rsubtype fc -o a -p $vios1  -a "adapter_type=server,remote_lpar_name=$LPNAME,remote_slot_num=$NEWID$vfc3" -s $NEWID$vfc3
if [[ $? -eq 0 ]]
then
mksyscfg -r prof -m $MS -o save -p $vios1 -n $V1P --force

else
echo ""
echo ""

echo "Something went wrong while dynamically adding the VFC slot number $NEWID$vfc3 in $vios1"
echo ""
echo "It will be manually added to $vios1 instead, you just need to shutdown and activate $vios1 after the program ends"
echo ""

chsyscfg -r prof -m $MS -i "name=$V1P, lpar_name=$vios1, \"virtual_fc_adapters+=$NEWID$vfc3/server//$LPNAME/$NEWID$vfc3//1\"" --force

sleep 2
fi



##########################
##VIOS2_VFC2_CONFIGURATION
##########################
echo ""
echo ""
chhwres -m $MS -r virtualio --rsubtype fc -o a -p $vios2  -a "adapter_type=server,remote_lpar_name=$LPNAME,remote_slot_num=$NEWID$vfc2" -s $NEWID$vfc2

if [[ $? -eq 0 ]]
then
mksyscfg -r prof -m $MS -o save -p $vios2 -n $V2P --force

else
echo ""
echo ""

echo "Something went wrong while dynamically adding the VFC slot number $NEWID$vfc2 in $vio2"
echo ""
echo "It will be manually added to $vios2 instead, you just need to shutdown and activate $vios2 after the program ends"

chsyscfg -r prof -m $MS -i "name=$V2P, lpar_name=$vios2, \"virtual_fc_adapters+=$NEWID$vfc2/server//$LPNAME/$NEWID$vfc2//1\"" --force

sleep 2
fi



##########################
##VIOS2_VFC4_CONFIGURATION
##########################
echo ""
echo ""
chhwres -m $MS -r virtualio --rsubtype fc -o a -p $vios2  -a "adapter_type=server,remote_lpar_name=$LPNAME,remote_slot_num=$NEWID$vfc4" -s $NEWID$vfc4

if [[ $? -eq 0 ]]
then
mksyscfg -r prof -m $MS -o save -p $vios2 -n $V2P --force

else
echo ""
echo ""
echo "Something went wrong while dynamically adding the VFC slot number $NEWID$vfc4 in $vio2"
echo ""
echo "It will be manually added to $vios2 instead, you just need to shutdown and activate $vios2 after the program ends"
chsyscfg -r prof -m $MS -i "name=$V2P, lpar_name=$vios2, \"virtual_fc_adapters+=$NEWID$vfc4/server//$LPNAME/$NEWID$vfc4//1\"" --force

sleep 2
fi

export lparid=$(expr $lparid + 1)
done
done
sleep 3
echo ""
echo ""
echo "Saving current configuration.."
sleep 4
clear
echo '   |'
sleep 1
clear
echo '   /'
sleep 1
clear
echo '   -'
sleep 1
clear
echo '   \'
sleep 1
clear
echo '   |'
sleep 1
clear
echo '   /'
sleep 1
clear
echo '   -'
sleep 1
clear
echo '   \'
sleep 1
clear

######################################################

#export V1P=`lssyscfg -r lpar -m $MS -F name,lpar_env,default_profile | grep -i vioserver | grep $vios1 |sort | cut -d "," -f 3 | sort`
#export V2P=`lssyscfg -r lpar -m $MS -F name,lpar_env,default_profile | grep -i vioserver | grep $vios1 |sort | cut -d "," -f 3 | sort`

#mksyscfg -r prof -m $MS -o save -p $vios1 -n $V1P --force
#mksyscfg -r prof -m $MS -o save -p $vios2 -n $V2P --force

echo #####################################################
echo ""
echo "$num LPAR(s) Successfully Created
All with one virtual ethernet adapter and four virtual fibre cards from both $vios1 and $vios2 servers"
sleep 2
echo ""
echo ""
echo ""
echo "You have all the following LPAR's in your $MS"
echo " "
lssyscfg -r lpar -m $MS -F name
echo " "
echo " "
echo " "

echo The newly created LPARs will be activated and shutdown to activate the fiber cards so we can get the WWPN
echo ""
echo "Please wait until the LPARs are getting recycled"
for i in `echo $lname`
do
chsysstate -o on -r lpar -m $MS -n $i -f default_profile
sleep 1
chsysstate -o shutdown --immed -r lpar -m $MS -n $i
done


echo Now your WWPNs for newly created System I LPARs are:
for i in `echo $lname`
do
lshwres -r virtualio --rsubtype fc -m $MS --level lpar -F lpar_name,slot_num,wwpns --header |grep -v null | egrep $i
done |sort -n 

echo ""
echo "Thanks................. Mash ©"

;;
03)
echo ""
echo "See you"
sleep 1
echo "Thanks................. Mash ©"
sleep 1





echo "




                                                  
                  &&&&@@&@&&&*& ,                 
               &&@@&&@@@@@@@@@@&&&#.              
             .&&&@@&&@&&&&&&@&&@@&&&&(            
             &&@&(//******////((((@@@&*           
            &&@#*******************&@@&(          
            &&&/******************/#&&&*          
           &&&&%*******************(&@&&          
           &&@&*//(%%&(****/%&&(/((/&@&%          
           %(%#,*(,%%*(/***///##,/**/(#.          
            //**,****/**************/(*           
             ,**,,********************            
              **********************,             
               .****/#//***//(//***/              
                 ////**********///                
               ,*(*////*****////**&.              
         *//#(&(//(/*/(#(/((((/**/&//#(#(*        
 */,,*%%(((%/%((%##%%#//*****/**%@#(/(**(&#**#%(* 
%**/%%%%%///#%%&#((*(%%%//***/#&&&(*(#&@&&%&#(/%&&
./#*//,*,(%&&%(*%%/(/&%&%&(/(#&&&&((#%&(%/*#*/*/##
%/**%%&&%%%%*,/&%%#/(%#*((%.%(*.(#%//(((/#&&#/*%%@
**%&#%#(,**(%&#(,%&@%**,*&%*%(*/%%%&&#%&&&&&(&&&#/
%%*(&%#,,##%%/,(%%(.(&%(,#/@&#*##%&&&%(&((/%*/%#&@
/*%/*%#,*%%%(,*%%(*,#&%(,/%(%%(&&%%%**#&#**%,*&///
%*#/.%/,/#&%,,%&%*,#%&%**(%&%&%&&#*./#&&(*,*/(&&&#
&%%&*#,,%%#*,#& &%  @  @   @(*  @/,,%(&&#**,##&&/%
(/@&%(&%,*,/&&( @ @@# @@@  .@(  @,,(&//&&###,/&&/#

"

sleep 3

break
;;

*)
echo "Sorry, It seems you have selected invalid option?!"
sleep 1
echo ""
sleep 1
clear

esac
done

