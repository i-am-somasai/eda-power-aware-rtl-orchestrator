#!/usr/bin/perl
use strict;
use warnings;
use YAML::XS 'LoadFile';
use File::Path qw(make_path);

# -----------------------------
# Args
# -----------------------------
my $design = shift @ARGV
    or die "Usage: perl flows/run_sim.pl <design>\n";

# -----------------------------
# Load config
# -----------------------------
my $cfg = LoadFile("config/flow.yaml");

die "Unknown design: $design\n"
    unless exists $cfg->{designs}{$design};

my $rtl_path = $cfg->{designs}{$design}{rtl_path};
my $top_tb   = "alu_tb";

# -----------------------------
# Output paths
# -----------------------------
my $log_dir = $cfg->{reports}{log_path};
make_path($log_dir) unless -d $log_dir;

my $compile_log = "$log_dir/${design}_compile.log";
my $sim_log     = "$log_dir/${design}_sim.log";

# -----------------------------
# File list (explicit = safe)
# -----------------------------
my @rtl_files = (
    "$rtl_path/cla4.v",
    "$rtl_path/cla16_addsub.v",
    "$rtl_path/alu.v",
    "$rtl_path/alu_tb.v"
);

# -----------------------------
# Compile (xvlog)
# -----------------------------
my $compile_cmd = "xvlog " . join(" ", @rtl_files) . " > $compile_log 2>&1";
system($compile_cmd) == 0
    or die "ERROR: Compilation failed. See $compile_log\n";

# -----------------------------
# Elaborate (xelab)
# -----------------------------
my $elab_cmd = "xelab $top_tb -debug typical >> $compile_log 2>&1";
system($elab_cmd) == 0
    or die "ERROR: Elaboration failed. See $compile_log\n";

# -----------------------------
# Simulate (xsim, batch)
# -----------------------------
my $sim_cmd = "xsim $top_tb -runall > $sim_log 2>&1";
system($sim_cmd) == 0
    or die "ERROR: Simulation failed. See $sim_log\n";

# -----------------------------
# Post-checks
# -----------------------------
die "ERROR: VCD not generated\n"
    unless -f "alu.vcd";

print "Simulation completed successfully for $design\n";
exit 0;
