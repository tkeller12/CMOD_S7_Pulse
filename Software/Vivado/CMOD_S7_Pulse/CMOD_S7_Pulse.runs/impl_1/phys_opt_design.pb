
B
Command: %s
53*	vivadotcl2
phys_opt_designZ4-113h px� 
~
@Attempting to get a license for feature '%s' and/or device '%s'
308*common2
Implementation2
xc7s25Z17-347h px� 
n
0Got license for feature '%s' and/or device '%s'
310*common2
Implementation2
xc7s25Z17-349h px� 
R

Starting %s Task
103*constraints2
Initial Update TimingZ18-103h px� 
�

%s
*constraints2a
_Time (s): cpu = 00:00:00 ; elapsed = 00:00:00.054 . Memory (MB): peak = 2143.891 ; gain = 0.000h px� 
�
^PhysOpt_Tcl_Interface Runtime Before Starting Physical Synthesis Task | CPU: %ss |  WALL: %ss
566*	vivadotcl2
0.002
0.06Z4-1435h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Netlist sorting complete. 2

00:00:002

00:00:002

2143.8912
0.000Z17-268h px� 
O

Starting %s Task
103*constraints2
Physical SynthesisZ18-103h px� 
^

Phase %s%s
101*constraints2
1 2#
!Physical Synthesis InitializationZ18-101h px� 
n
EMultithreading enabled for phys_opt_design using a maximum of %s CPUs380*physynth2
2Z32-721h px� 
s
(%s %s Timing Summary | WNS=%s | TNS=%s |333*physynth2
	Estimated2
 2
-3.1712

-130.654Z32-619h px� 
[
%s*common2B
@Phase 1 Physical Synthesis Initialization | Checksum: 2160fb72d
h px� 
�

%s
*constraints2a
_Time (s): cpu = 00:00:00 ; elapsed = 00:00:00.051 . Memory (MB): peak = 2143.891 ; gain = 0.000h px� 
s
(%s %s Timing Summary | WNS=%s | TNS=%s |333*physynth2
	Estimated2
 2
-3.1712

-130.654Z32-619h px� 
V

Phase %s%s
101*constraints2
2 2
DSP Register OptimizationZ18-101h px� 
j
FNo candidate cells for DSP register optimization found in the design.
274*physynthZ32-456h px� 
�
aEnd %s Pass. Optimized %s %s. Created %s new %s, deleted %s existing %s and moved %s existing %s
415*physynth2
22
02
net or cell2
02
cell2
02
cell2
02
cellZ32-775h px� 
S
%s*common2:
8Phase 2 DSP Register Optimization | Checksum: 2160fb72d
h px� 
�

%s
*constraints2a
_Time (s): cpu = 00:00:00 ; elapsed = 00:00:00.053 . Memory (MB): peak = 2143.891 ; gain = 0.000h px� 
W

Phase %s%s
101*constraints2
3 2
Critical Path OptimizationZ18-101h px� 
s
(%s %s Timing Summary | WNS=%s | TNS=%s |333*physynth2
	Estimated2
 2
-3.1712

-130.654Z32-619h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2,
u_ppc/count_reg[29]u_ppc/count_reg[29]8Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2�
Vu_clock_wizard_wrapper/clock_wizard_i/clk_wiz_0/inst/clk_out1_clock_wizard_clk_wiz_0_0Vu_clock_wizard_wrapper/clock_wizard_i/clk_wiz_0/inst/clk_out1_clock_wizard_clk_wiz_0_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2<
u_ppc/count_reg[24]_i_1_n_0u_ppc/count_reg[24]_i_1_n_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2<
u_ppc/count_reg[20]_i_1_n_0u_ppc/count_reg[20]_i_1_n_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2<
u_ppc/count_reg[16]_i_1_n_0u_ppc/count_reg[16]_i_1_n_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2<
u_ppc/count_reg[12]_i_1_n_0u_ppc/count_reg[12]_i_1_n_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2:
u_ppc/count_reg[8]_i_1_n_0u_ppc/count_reg[8]_i_1_n_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2:
u_ppc/count_reg[4]_i_1_n_0u_ppc/count_reg[4]_i_1_n_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2:
u_ppc/count_reg[0]_i_1_n_0u_ppc/count_reg[0]_i_1_n_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth22
u_ppc/count[0]_i_6_n_0u_ppc/count[0]_i_6_n_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth26
u_ppc/addr0_carry__2_n_0u_ppc/addr0_carry__2_n_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth26
u_ppc/addr0_carry__1_n_0u_ppc/addr0_carry__1_n_08Z32-702h px� 
_
!Optimized %s %s.  Swapped %s %s.
322*physynth2
12
net2
342
pinsZ32-608h px� 
�
;Processed net %s. Optimization improves timing on the net.
394*physynth2>
u_ppc/addr0_carry__1_i_8_n_0u_ppc/addr0_carry__1_i_8_n_08Z32-735h px� 
s
(%s %s Timing Summary | WNS=%s | TNS=%s |333*physynth2
	Estimated2
 2
-3.1672

-130.478Z32-619h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth26
u_ppc/addr0_carry__0_n_0u_ppc/addr0_carry__0_n_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth20
u_ppc/addr0_carry_n_0u_ppc/addr0_carry_n_08Z32-702h px� 
_
!Optimized %s %s.  Swapped %s %s.
322*physynth2
12
net2
342
pinsZ32-608h px� 
�
;Processed net %s. Optimization improves timing on the net.
394*physynth28
u_ppc/addr0_carry_i_7_n_0u_ppc/addr0_carry_i_7_n_08Z32-735h px� 
s
(%s %s Timing Summary | WNS=%s | TNS=%s |333*physynth2
	Estimated2
 2
-3.1592

-130.126Z32-619h px� 
_
!Optimized %s %s.  Swapped %s %s.
322*physynth2
12
net2
342
pinsZ32-608h px� 
�
;Processed net %s. Optimization improves timing on the net.
394*physynth28
u_ppc/addr0_carry_i_7_n_0u_ppc/addr0_carry_i_7_n_08Z32-735h px� 
s
(%s %s Timing Summary | WNS=%s | TNS=%s |333*physynth2
	Estimated2
 2
-3.1182

-128.322Z32-619h px� 
_
!Optimized %s %s.  Swapped %s %s.
322*physynth2
12
net2
342
pinsZ32-608h px� 
�
;Processed net %s. Optimization improves timing on the net.
394*physynth2>
u_ppc/addr0_carry__0_i_5_n_0u_ppc/addr0_carry__0_i_5_n_08Z32-735h px� 
s
(%s %s Timing Summary | WNS=%s | TNS=%s |333*physynth2
	Estimated2
 2
-3.1082

-127.882Z32-619h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2>
u_ppc/addr0_carry__0_i_7_n_0u_ppc/addr0_carry__0_i_7_n_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2<
u_ppc/count_reg[28]_i_1_n_6u_ppc/count_reg[28]_i_1_n_68Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth28
u_RAM_2Port/o_Rd_Data[10]u_RAM_2Port/o_Rd_Data[10]8Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2,
u_ppc/count_reg[29]u_ppc/count_reg[29]8Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2�
Vu_clock_wizard_wrapper/clock_wizard_i/clk_wiz_0/inst/clk_out1_clock_wizard_clk_wiz_0_0Vu_clock_wizard_wrapper/clock_wizard_i/clk_wiz_0/inst/clk_out1_clock_wizard_clk_wiz_0_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth22
u_ppc/count[0]_i_6_n_0u_ppc/count[0]_i_6_n_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth26
u_ppc/addr0_carry__2_n_0u_ppc/addr0_carry__2_n_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2>
u_ppc/addr0_carry__0_i_7_n_0u_ppc/addr0_carry__0_i_7_n_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2<
u_ppc/count_reg[28]_i_1_n_6u_ppc/count_reg[28]_i_1_n_68Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth28
u_RAM_2Port/o_Rd_Data[10]u_RAM_2Port/o_Rd_Data[10]8Z32-702h px� 
s
(%s %s Timing Summary | WNS=%s | TNS=%s |333*physynth2
	Estimated2
 2
-3.1082

-127.882Z32-619h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Netlist sorting complete. 2

00:00:002
00:00:00.0012

2143.8912
0.000Z17-268h px� 
T
%s*common2;
9Phase 3 Critical Path Optimization | Checksum: 2160fb72d
h px� 
�

%s
*constraints2a
_Time (s): cpu = 00:00:00 ; elapsed = 00:00:00.089 . Memory (MB): peak = 2143.891 ; gain = 0.000h px� 
W

Phase %s%s
101*constraints2
4 2
Critical Path OptimizationZ18-101h px� 
s
(%s %s Timing Summary | WNS=%s | TNS=%s |333*physynth2
	Estimated2
 2
-3.1082

-127.882Z32-619h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2,
u_ppc/count_reg[29]u_ppc/count_reg[29]8Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2�
Vu_clock_wizard_wrapper/clock_wizard_i/clk_wiz_0/inst/clk_out1_clock_wizard_clk_wiz_0_0Vu_clock_wizard_wrapper/clock_wizard_i/clk_wiz_0/inst/clk_out1_clock_wizard_clk_wiz_0_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2<
u_ppc/count_reg[24]_i_1_n_0u_ppc/count_reg[24]_i_1_n_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2<
u_ppc/count_reg[20]_i_1_n_0u_ppc/count_reg[20]_i_1_n_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2<
u_ppc/count_reg[16]_i_1_n_0u_ppc/count_reg[16]_i_1_n_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2<
u_ppc/count_reg[12]_i_1_n_0u_ppc/count_reg[12]_i_1_n_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2:
u_ppc/count_reg[8]_i_1_n_0u_ppc/count_reg[8]_i_1_n_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2:
u_ppc/count_reg[4]_i_1_n_0u_ppc/count_reg[4]_i_1_n_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2:
u_ppc/count_reg[0]_i_1_n_0u_ppc/count_reg[0]_i_1_n_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth22
u_ppc/count[0]_i_6_n_0u_ppc/count[0]_i_6_n_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth26
u_ppc/addr0_carry__2_n_0u_ppc/addr0_carry__2_n_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth26
u_ppc/addr0_carry__1_n_0u_ppc/addr0_carry__1_n_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth26
u_ppc/addr0_carry__0_n_0u_ppc/addr0_carry__0_n_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2>
u_ppc/addr0_carry__0_i_7_n_0u_ppc/addr0_carry__0_i_7_n_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2<
u_ppc/count_reg[28]_i_1_n_6u_ppc/count_reg[28]_i_1_n_68Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth28
u_RAM_2Port/o_Rd_Data[10]u_RAM_2Port/o_Rd_Data[10]8Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2,
u_ppc/count_reg[29]u_ppc/count_reg[29]8Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2�
Vu_clock_wizard_wrapper/clock_wizard_i/clk_wiz_0/inst/clk_out1_clock_wizard_clk_wiz_0_0Vu_clock_wizard_wrapper/clock_wizard_i/clk_wiz_0/inst/clk_out1_clock_wizard_clk_wiz_0_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth22
u_ppc/count[0]_i_6_n_0u_ppc/count[0]_i_6_n_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth26
u_ppc/addr0_carry__2_n_0u_ppc/addr0_carry__2_n_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2>
u_ppc/addr0_carry__0_i_7_n_0u_ppc/addr0_carry__0_i_7_n_08Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth2<
u_ppc/count_reg[28]_i_1_n_6u_ppc/count_reg[28]_i_1_n_68Z32-702h px� 
�
BPorcessed net %s. Optimizations did not improve timing on the net.366*physynth28
u_RAM_2Port/o_Rd_Data[10]u_RAM_2Port/o_Rd_Data[10]8Z32-702h px� 
s
(%s %s Timing Summary | WNS=%s | TNS=%s |333*physynth2
	Estimated2
 2
-3.1082

-127.882Z32-619h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Netlist sorting complete. 2

00:00:002

00:00:002

2143.8912
0.000Z17-268h px� 
T
%s*common2;
9Phase 4 Critical Path Optimization | Checksum: 2160fb72d
h px� 
�

%s
*constraints2a
_Time (s): cpu = 00:00:00 ; elapsed = 00:00:00.104 . Memory (MB): peak = 2143.891 ; gain = 0.000h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Netlist sorting complete. 2

00:00:002

00:00:002

2143.8912
0.000Z17-268h px� 
x
>Post Physical Optimization Timing Summary | WNS=%s | TNS=%s |
318*physynth2
-3.1082

-127.882Z32-603h px� 
B
-
Summary of Physical Synthesis Optimizations
*commonh px� 
B
-============================================
*commonh px� 


*commonh px� 


*commonh px� 
�
�-------------------------------------------------------------------------------------------------------------------------------------------------------------
*commonh px� 
�
�|  Optimization   |  WNS Gain (ns)  |  TNS Gain (ns)  |  Added Cells  |  Removed Cells  |  Optimized Cells/Nets  |  Dont Touch  |  Iterations  |  Elapsed   |
-------------------------------------------------------------------------------------------------------------------------------------------------------------
*commonh px� 
�
�|  DSP Register   |          0.000  |          0.000  |            0  |              0  |                     0  |           0  |           1  |  00:00:00  |
|  Critical Path  |          0.063  |          2.772  |            0  |              0  |                     4  |           0  |           2  |  00:00:00  |
|  Total          |          0.063  |          2.772  |            0  |              0  |                     4  |           0  |           3  |  00:00:00  |
-------------------------------------------------------------------------------------------------------------------------------------------------------------
*commonh px� 


*commonh px� 


*commonh px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Netlist sorting complete. 2

00:00:002

00:00:002

2143.8912
0.000Z17-268h px� 
P
%s*common27
5Ending Physical Synthesis Task | Checksum: 24d845770
h px� 
�

%s
*constraints2a
_Time (s): cpu = 00:00:00 ; elapsed = 00:00:00.108 . Memory (MB): peak = 2143.891 ; gain = 0.000h px� 
H
Releasing license: %s
83*common2
ImplementationZ17-83h px� 

G%s Infos, %s Warnings, %s Critical Warnings and %s Errors encountered.
28*	vivadotcl2
1672
02
02
0Z4-41h px� 
O
%s completed successfully
29*	vivadotcl2
phys_opt_designZ4-42h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Write ShapeDB Complete: 2

00:00:002

00:00:002

2143.8912
0.000Z17-268h px� 
H
&Writing timing data to binary archive.266*timingZ38-480h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Wrote PlaceDB: 2

00:00:002
00:00:00.0162

2143.8912
0.000Z17-268h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Wrote PulsedLatchDB: 2

00:00:002

00:00:002

2143.8912
0.000Z17-268h px� 
=
Writing XDEF routing.
211*designutilsZ20-211h px� 
J
#Writing XDEF routing logical nets.
209*designutilsZ20-209h px� 
J
#Writing XDEF routing special nets.
210*designutilsZ20-210h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Wrote RouteStorage: 2

00:00:002
00:00:00.0092

2143.8912
0.000Z17-268h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Wrote Netlist Cache: 2

00:00:002

00:00:002

2143.8912
0.000Z17-268h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Wrote Device Cache: 2

00:00:002
00:00:00.0032

2143.8912
0.000Z17-268h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Write Physdb Complete: 2

00:00:002
00:00:00.0322

2143.8912
0.000Z17-268h px� 
�
 The %s '%s' has been generated.
621*common2

checkpoint2s
qC:/Users/jkell/Repositories/CMOD_S7_Pulse/Software/Vivado/CMOD_S7_Pulse/CMOD_S7_Pulse.runs/impl_1/top_physopt.dcpZ17-1381h px� 


End Record