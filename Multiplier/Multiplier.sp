** Generated for: hspiceD
** Generated on: Nov 10 00:20:07 2026
** Design library name: ECE555
** Design cell name: Multiplier
** Design view name: schematic


.OPTION
+    INGOLD=2
+    PARHIER=LOCAL
+    HIER_DELIM=0

** Library name: ECE555
** Cell name: NAND2
** View name: schematic
.subckt NAND2 a b vdd vss y
mn3 net5 b vss vss nmos_rvt w=108e-9 l=20e-9 nfin=4
mn0 y a net5 vss nmos_rvt w=108e-9 l=20e-9 nfin=4
mp2 y a vdd vdd pmos_rvt w=81e-9 l=20e-9 nfin=3
mp1 y b vdd vdd pmos_rvt w=81e-9 l=20e-9 nfin=3
.ends NAND2
** End of subcircuit definition.

** Library name: ECE555
** Cell name: INV_fin_larger
** View name: schematic
.subckt INV_fin_larger in out vdd vss
mn0 out in vss vss nmos_rvt w=54e-9 l=20e-9 nfin=2
mp1 out in vdd vdd pmos_rvt w=81e-9 l=20e-9 nfin=3
.ends INV_fin_larger
** End of subcircuit definition.

** Library name: ECE555
** Cell name: XNOR
** View name: schematic
.subckt XNOR a b vdd vss y
xi0 a b vdd vss z NAND2
mn2 y b net1 vss nmos_rvt w=27e-9 l=20e-9 nfin=1
mn1 y a net1 vss nmos_rvt w=27e-9 l=20e-9 nfin=1
mn0 net1 z vss vss nmos_rvt w=27e-9 l=20e-9 nfin=1
mp3 y z vdd vdd pmos_rvt w=27e-9 l=20e-9 nfin=1
mp4 y b net10 vdd pmos_rvt w=27e-9 l=20e-9 nfin=1
mp5 net10 a vdd vdd pmos_rvt w=27e-9 l=20e-9 nfin=1
.ends XNOR
** End of subcircuit definition.

** Library name: ECE555
** Cell name: NOR2
** View name: schematic
.subckt NOR2 a b vdd vss y
mn3 y a vss vss nmos_rvt w=54e-9 l=20e-9 nfin=2
mn0 y b vss vss nmos_rvt w=54e-9 l=20e-9 nfin=2
mp2 y b net4 vdd pmos_rvt w=162e-9 l=20e-9 nfin=6
mp1 net4 a vdd vdd pmos_rvt w=162e-9 l=20e-9 nfin=6
.ends NOR2
** End of subcircuit definition.

** Library name: ECE555
** Cell name: Multiplier
** View name: schematic
xi0 a<0> b<0> vdd vss n0 NAND2
xi1 n0 p<0> vdd vss INV_fin_larger
xi2 a<1> b<1> vdd vss xn XNOR
xi3 n0 xn vdd vss p<1> NOR2
