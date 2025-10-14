# P3: IO Ring

Version: 2025.0
---

## Due Date:  09:59am, Thursday, October 23, 2025


# Goal

This project will walk you through the basics of setting up an IO ring.  It will also give you some experience in dealing with multiple voltage domains.  

# Setup

```bash
ssh burrow-rhel.luddy.indiana.edu -YCA
git clone https://github.com/engr599-ic/P3_io_ring.git
cd P3_io_ring
make setup
source load_tools.sh
```

# Run Synthesis

First, run synthesis as per previous projects: 

```bash
make synth
```

# Floorplanning w/IO Ring

Now run the new "floorplanning" step.  This will create a basic floorplan that you will need to customize. 

```bash
make floorplan
```
By default, the floorplan should look something like this: 

<img width="499" height="493" alt="image" src="https://github.com/user-attachments/assets/c7b21d1b-c5f0-4173-8ed3-3270dc7f0050" />

You will need to either customize the `floorplan.tcl` script, or to manually edit the floorplan with the GUI.

A (non-exhaustive) list of things that will need fixed: 
 - Corner cells are not placed correctly
 - The "PAD" section of the IO cell should face away from the core
 - You will need to connect all the IO cell's nets either with an `sroute` or using IO filler cells (see below)

Remember you can restore an existing database with: 

```bash
innovus -stylus -db ./dbs/pnr_init.db
```

You can save the floorplan with either the GUI or the CLI:

GUI: File->Save->Floorplan.  

CLI:  
```tcl
write_floorplan floorplan.fp
```

## Place and Route

Once your floorplan is complete, continue on through with PnR: 

```bash
make pnr
```

The `pnr.tcl` script may or may not need further customization.  For example, we recommend adding a `read_floorplan` command that loads the floorplan saved in the previous step. 

You will need to run the flow through and successfully pass the `run_checks.sh`.  

## Jack's Helpful Tips

### Displaying Pin Shapes

It's often helpful to show pin shapes to help debug IO ring connectivity issues: 

<img width="187" height="345" alt="image" src="https://github.com/user-attachments/assets/fa58e5ac-b6ec-41b6-bd48-1e4598895d25" />

### Reset Floorplan

If (or when) you run into floorplanning issues and want to "reset" your floorplan, try the "Clear Floorplan" option in the GUI: 
<img width="335" height="446" alt="image" src="https://github.com/user-attachments/assets/f6f741d9-580b-4a9a-89ed-c2c51df8088e" />  

### IO Grid Snapping

You might need to disable snapping to the grid to get the IO cells to place correctly.  This can be done in the GUI interface, or it can be done with the following flag for `create_floorplan`:

```tcl
   create_floorplan -no_snap_to_grid
```

HINT:  You might also look at "Bottom IO Pad Orientation" options.  

### Saving / Loading IO Files

If you are intending to manually edit IO placement (which you should), we recommend saving / editing / loading IO files rather than trying to directly edit the floorplan file.  It's easier to understand what's going on.  

<img width="324" height="474" alt="image" src="https://github.com/user-attachments/assets/5baf26b4-f184-44a6-845c-7972cffee182" />



### IO Filler Cells

The tool is capable of automatically adding filler cells in the IO ring.  This can be done with the GUI or CLI: 

GUI:
<img width="297" height="420" alt="image" src="https://github.com/user-attachments/assets/3c1c4f1d-bae4-4c85-bb56-26d9966ea5c7" />

CLI: 
```tcl
add_filler_cells
```

The following IO filler cells are available for use: 
```
 - sky130_ef_io__com_bus_slice_1um
 - sky130_ef_io__com_bus_slice_5um
 - sky130_ef_io__com_bus_slice_10um
 - sky130_ef_io__com_bus_slice_20um
```

Correctly placed IO Filler cells should look something like this: 

<img width="382" height="674" alt="image" src="https://github.com/user-attachments/assets/8e0a332a-7697-441d-9725-bd64661df99b" />

# Your Turn

Now it's your turn to run your own flow.  This time we're concerned with getting the `run_checks.sh` script to pass.  We're not so concerned about area or timing, so feel free to relax those to make things run faster.  

Your goal should be to achieve the following: 
 - Have your core layout complete, including SRAMs and power grid
 - Have your IO ring layout complete, including corner cells and fully connected power rings
 - You have an overall pass on `run_checks.sh` command  

