# BarrionuevoCao_Reproduction

An attempt to reproduce results from:
P. A. Barrionuevo and D. Cao, “Contributions of rhodopsin, cone opsins, and melanopsin to postreceptoral pathways inferred from natural image statistics,” Journal of the Optical Society of America A, vol. 31, no. 4, p. A131, Apr. 2014.

Whereas the paper reports average component weightings, here I have broken it down for individual images. See 'figures' folder.
e.g. f2_imX = reproducing figure 2 in the original paper for image X. 


---

## Requires:

- Psychtoolbox (could probably be done without, but it makes it easy)
    Version: 3.0.14 - Flavor: beta - Corresponds to SVN Revision 8424
    Uses basic functions, presumably will be compatible with other versions.
- MATLAB Statistics and Machine Learning Toolbox

## Variables:
```
im = image
D_CCT = Correlated colour temperature of the D series ill to be used
level = which level do you want to do this at? 
	(1 = LMSRI, 2 = lsri (with luminance removed before analysis)
Tn = number of sensitivities (T in psychtoolbox terminology)
	(3/4/5 = LMS/LMSR/LMSRI or 2/3/4 = ls/lsr/lsri)   
```

## TO DO list
- Get a better estimate of CCT range
- Reproduce the data tables 

