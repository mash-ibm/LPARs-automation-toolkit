#####################
Description of the toolkit
#####################
The tools is just a three condensed shell programs to run on HMC V7 and HMC V8, HMC V9
- The first shell program is called: vios_prof.sh
- The second shell program is called: vios_eth
- The third shell program is called: lpars_auto.sh

The three programs aim to quick automation of a Power system implementation to save time.

The tool (three programs) are working on the HMC level to automate create the following:
- VIO(s) profiles creation.
- VIOS VLAN(s) creation and virtual ethernet adapters.
- As much LPARs as needed by just running the program which will interactively take inputs from the Admin,
Like VIO(s) names, number of LPARs to be created, LPARs names to be created.

Plus creating the virtual adapters (virtual ethernet, virtual fiber) into the LPARs newly created by the program.
The program also creates the virtual fiber adapters not only in the LPARs, but also it creates the opposite virtual fibers (vfchosts)
Distributed in the dual VIOS profiles. The Admin will just get into the VIO(s) levels to continue his vfcmaps work and/or SEA, etc.. if needed.

After running the program(s), it will immediately power up the new LPARs created and power them off back to generate
All the WWPN's along with their adapter IDs for SAN work after all.

The toolkit is delivered as shell programs, and it just can be uploaded to an up and running HMC through network (scp).
Calling the program through the HMC shell like any shell script. Example: HMC # . program.sh

This toolkit can be very good for customers who are having very dynamic environment, and It would be beneficial for the
Consultants/partners to help create/implement the Power machines and save time. 

######################
What's new in this version?
######################
In this version I amended the program to create vios profiles interactively and the VLANs in the new VIOS profiles.
In addition to the LPARs automation creation kit which which will add the adapters in newly created LPARS profiles
Plus it will attempt to dynamically create the corresponding virtual fiber adapters in the both VIOS, it has a condition
To just add them into the VIOS profiles in case the dynamic operation fails against the VIOS.
In this version also you can interactively create System i profiles.