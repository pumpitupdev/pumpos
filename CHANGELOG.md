# Release history
## 1.06
* Use pumpos base system as a foundation for ITG 2 cabinets
* Refactor deployment infrastructure to enable deploying of PIU games or ITG 2 and ddr-mame
* deployment pipeline scripts to streamline full deployments which reduces the amount of commands to
input a lot (see readme)
* Base OS does not need to be booted anymore on the target hardware for post installation. All
installation is done in the chroot environment
* Bugfix: Execute grub-install manually, auto grub-install got removed from package installation

## 1.05
* sgl: Dist files with optional support for piu (pro) button board
* Readme: Add short version with commands only for full cabinet deployment
* Add backup save script to easily backup all save folders from a piu deployment:
`./pumpos.sh backup-save`
* Add dist data for piu pro to prime
* Various bugfixes

## 1.04
* Add support for NX2 deployment
* Add support for SGL deployment
* Add option for local caching of packages to speed up installation 
* Various bugfixes

## 1.03
* Add support for NX deployment

## 1.02
* Add support for Zero deployment

## 1.01
* Add support for exceed 2 deployment
* Bugfixes

## 1.00
* Initial release