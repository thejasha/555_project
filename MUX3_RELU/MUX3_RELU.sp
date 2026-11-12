** MUX3_RELU (ReLU 3-bit 2:1 MUX), pruned from Virtuoso hspiceD netlist
** Z<i> = NOR(INV(Y<i>), Y<2>), sign bit Y<2> on NOR2 input b (PMOS next to output)

.subckt INV_fin_larger in out vdd vss
mn0 out in vss vss nmos_rvt w=54e-9 l=20e-9 nfin=2
mp1 out in vdd vdd pmos_rvt w=81e-9 l=20e-9 nfin=3
.ends INV_fin_larger

.subckt NOR2 a b vdd vss y
mn3 y a vss vss nmos_rvt w=54e-9 l=20e-9 nfin=2
mn0 y b vss vss nmos_rvt w=54e-9 l=20e-9 nfin=2
mp2 y b net4 vdd pmos_rvt w=162e-9 l=20e-9 nfin=6
mp1 net4 a vdd vdd pmos_rvt w=162e-9 l=20e-9 nfin=6
.ends NOR2

.subckt MUX3_RELU y<0> y<1> y<2> z<0> z<1> vdd vss
xi1 y<1> net6 vdd vss INV_fin_larger
xi0 y<0> net2 vdd vss INV_fin_larger
xi3 net6 y<2> vdd vss z<1> NOR2
xi2 net2 y<2> vdd vss z<0> NOR2
.ends MUX3_RELU
