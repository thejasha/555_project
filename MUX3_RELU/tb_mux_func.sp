* tb_mux_func.sp -- exhaustive functional test of MUX3_RELU (pre-layout)
* Y<2:0> counts 000 -> 111, one state per ns: state k lives in [k ns, k+1 ns].
* Every output has an FO4 load (4 x INV, 2 NMOS fins / 3 PMOS fins).
* VDD = 0.9 V, input rise/fall = 25 ps (TA spec).

.TEMP 25.0
.options accurate=1 NUMDGT=8 measdgt=5 GMINDC=1e-18 DELMAX=1n method=gear INGOLD=2 POST=1

.include '/srv/auto/apps/asap7pdk/2022-fixed/asap7PDK_r1p7/models/hspice/7nm_TT_160803.pm'
.include 'MUX3_RELU.sp'

.global vdd! vss!
.param SUPPLY=0.9 TR=25p

Vdd vdd! 0 'SUPPLY'
Vss vss! 0 0

* ---- stimulus: 3-bit binary counter ----
Vy0 y0 0 PULSE(0 'SUPPLY' 1n 'TR' 'TR' '1n-TR' 2n)
Vy1 y1 0 PULSE(0 'SUPPLY' 2n 'TR' 'TR' '2n-TR' 4n)
Vy2 y2 0 PULSE(0 'SUPPLY' 4n 'TR' 'TR' '4n-TR' 8n)

* port order = .subckt MUX3_RELU y<0> y<1> y<2> z<0> z<1> vdd vss
XDUT y0 y1 y2 z0 z1 vdd! vss! MUX3_RELU

* ---- FO4 load on every output ----
.subckt INV_FO in out
mn0 out in vss! vss! nmos_rvt w=54e-9 l=20e-9 nfin=2
mp0 out in vdd! vdd! pmos_rvt w=81e-9 l=20e-9 nfin=3
.ends INV_FO

XL0a z0 nl0a INV_FO
XL0b z0 nl0b INV_FO
XL0c z0 nl0c INV_FO
XL0d z0 nl0d INV_FO
XL1a z1 nl1a INV_FO
XL1b z1 nl1b INV_FO
XL1c z1 nl1c INV_FO
XL1d z1 nl1d INV_FO

.tran 1p 8n

* ---- sample outputs at 80% of each state ----
* expected (Z1 Z0): s0=00 s1=01 s2=10 s3=11 s4..s7=00
.meas tran Z0_s0 FIND v(z0) AT=0.8n
.meas tran Z1_s0 FIND v(z1) AT=0.8n
.meas tran Z0_s1 FIND v(z0) AT=1.8n
.meas tran Z1_s1 FIND v(z1) AT=1.8n
.meas tran Z0_s2 FIND v(z0) AT=2.8n
.meas tran Z1_s2 FIND v(z1) AT=2.8n
.meas tran Z0_s3 FIND v(z0) AT=3.8n
.meas tran Z1_s3 FIND v(z1) AT=3.8n
.meas tran Z0_s4 FIND v(z0) AT=4.8n
.meas tran Z1_s4 FIND v(z1) AT=4.8n
.meas tran Z0_s5 FIND v(z0) AT=5.8n
.meas tran Z1_s5 FIND v(z1) AT=5.8n
.meas tran Z0_s6 FIND v(z0) AT=6.8n
.meas tran Z1_s6 FIND v(z1) AT=6.8n
.meas tran Z0_s7 FIND v(z0) AT=7.8n
.meas tran Z1_s7 FIND v(z1) AT=7.8n

.end
