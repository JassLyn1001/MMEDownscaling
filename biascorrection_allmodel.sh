#!/bin/sh

cd /mnt/d/Skripsi/Data_Jassica/Prog_Statistik/Index_to_correct/Baseline_period/
for j in *
  do
    mkdir /mnt/d/Skripsi/Data_Jassica/Prog_Statistik/Hasil_BC/base_period/regcoef_gumbel/${j}
    echo "mengolah model ${j}"
    export iPATH1=/mnt/d/Skripsi/Data_Jassica/Prog_Statistik/Index_to_correct/Baseline_period/${j}/
    export iPATH2=/mnt/d/Skripsi/Data_Jassica/Prog_Statistik/observasi_improved/
    export oPATH=/mnt/d/Skripsi/Data_Jassica/Prog_Statistik/Hasil_BC/base_period/regcoef_gumbel/${j}/
    export oMAPS=/mnt/d/Skripsi/Data_Jassica/Prog_Statistik/OutputMaps/

    for i in cdd cwd r10mm r20mm rx1day rx5day
    do
      echo "mengolah index ${i}"
      export iFILE1="corrected_Regrid_${i}ETCCDI_yr_${j}_historical_r1i1p1_1981-2005"
      export iFILE2="Regrid_eca_${i}_ina_combined_chirpsv2p0_1981_2015_days_p05_ncgen"
      echo "mulai run ${i}"
      ncl  /mnt/d/Skripsi/Data_Jassica/Prog_Statistik/scriptfor_bc/bc_gev/bc_gevgumbel_${i}.ncl > /mnt/d/Skripsi/Data_Jassica/Prog_Statistik/log/regCoef_gumbel_log/${j}_${i}.log
    done
  done
cd ..
