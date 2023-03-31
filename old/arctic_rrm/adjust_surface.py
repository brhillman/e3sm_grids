#!/usr/bin/env python

import HICCUP.hiccup_state_adjustment as hsa
import xarray as xr

def main(input_file, topo_file, output_file, **kwargs):
    # Do surface adjustments and write to a new file
    with xr.open_dataset(topo_file) as ds_topo:
        with xr.open_dataset(input_file) as ds_data:
            # Need pressure calculated beforehand (in hPa)
            ds_data['PRES'] = hsa.get_pressure_from_hybrid(ds_data) / 1.0e2
            #adjust_surface_temperature(ds_data, ds_topo, **kwargs)
            hsa.adjust_surface_pressure(ds_data, ds_topo, pressure_var_name='PRES', **kwargs)
            ds_data.to_netcdf(output_file)

if __name__ == '__main__':
    import plac; plac.call(main)
