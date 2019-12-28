pscp robots.c lee@titan:workspace/robots
plink -batch lee@titan "cd workspace/robots && cmoc robots.c && writecocofile robots.dsk robots.bin"
pscp lee@titan:workspace/robots/robots.dsk .
