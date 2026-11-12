** Multiplier testbench: 9 valid input combos, 1 ns each
** course guidelines: VDD 0.9 V, 25 ps input edges, FO4 load on every output
*  t(ns)  A<1:0> B<1:0>  expected P<1:0>
*  0-1    00     00      00
*  1-2    00     01      00
*  2-3    00     11      00
*  3-4    01     00      00
*  4-5    01     01      01
*  5-6    01     11      11
*  6-7    11     00      00
*  7-8    11     01      11
*  8-9    11     11      01
.GLOBAL vss! vdd!
.TEMP 25.0
.options accurate=1 NUMDGT=8 measdgt=5 GMINDC=1e-18 DELMAX=1n method=gear INGOLD=2 POST=1
.include "/srv/auto/apps/asap7pdk/2022-fixed/asap7PDK_r1p7/models/hspice/7nm_TT_160803.pm"
.include "Multiplier.sp"

* FO4 load inverter: PMOS 3 fins, NMOS 2 fins
.subckt inv_fo4 in out vdd vss
mp0 out in vdd vdd pmos_rvt w=81e-9 l=20e-9 nfin=3
mn0 out in vss vss nmos_rvt w=54e-9 l=20e-9 nfin=2
.ends inv_fo4

vdd1 vdd! 0 0.9v
vss1 vss! 0 0v
vdd2 VDD  0 0.9v
vss2 VSS  0 0v

* FO4 on P<0> and P<1>
xl00 p<0> l00 VDD VSS inv_fo4
xl01 p<0> l01 VDD VSS inv_fo4
xl02 p<0> l02 VDD VSS inv_fo4
xl03 p<0> l03 VDD VSS inv_fo4
xl10 p<1> l10 VDD VSS inv_fo4
xl11 p<1> l11 VDD VSS inv_fo4
xl12 p<1> l12 VDD VSS inv_fo4
xl13 p<1> l13 VDD VSS inv_fo4

* inputs, 25 ps edges
va0 a<0> 0 pwl 0ns 0v 3ns 0v 3.025ns 0.9v
va1 a<1> 0 pwl 0ns 0v 6ns 0v 6.025ns 0.9v
vb0 b<0> 0 pwl 0ns 0v 1ns 0v 1.025ns 0.9v 3ns 0.9v 3.025ns 0v 4ns 0v 4.025ns 0.9v 6ns 0.9v 6.025ns 0v 7ns 0v 7.025ns 0.9v
vb1 b<1> 0 pwl 0ns 0v 2ns 0v 2.025ns 0.9v 3ns 0.9v 3.025ns 0v 5ns 0v 5.025ns 0.9v 6ns 0.9v 6.025ns 0v 8ns 0v 8.025ns 0.9v

* output levels near the end of each 1 ns window
.measure tran p1_t0 find v(p<1>) at=0.8n
.measure tran p0_t0 find v(p<0>) at=0.8n
.measure tran p1_t1 find v(p<1>) at=1.8n
.measure tran p0_t1 find v(p<0>) at=1.8n
.measure tran p1_t2 find v(p<1>) at=2.8n
.measure tran p0_t2 find v(p<0>) at=2.8n
.measure tran p1_t3 find v(p<1>) at=3.8n
.measure tran p0_t3 find v(p<0>) at=3.8n
.measure tran p1_t4 find v(p<1>) at=4.8n
.measure tran p0_t4 find v(p<0>) at=4.8n
.measure tran p1_t5 find v(p<1>) at=5.8n
.measure tran p0_t5 find v(p<0>) at=5.8n
.measure tran p1_t6 find v(p<1>) at=6.8n
.measure tran p0_t6 find v(p<0>) at=6.8n
.measure tran p1_t7 find v(p<1>) at=7.8n
.measure tran p0_t7 find v(p<0>) at=7.8n
.measure tran p1_t8 find v(p<1>) at=8.8n
.measure tran p0_t8 find v(p<0>) at=8.8n

.TRAN STEP=10p STOP=9n
.end
