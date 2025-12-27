#!/usr/bin/perl
use strict;
use warnings;

# -----------------------------
# Args
# -----------------------------
my $design = shift @ARGV
    or die "Usage: perl flows/orchestrate.pl <design>\n";

print "\n=== EDA Flow Orchestrator ===\n";
print "Design : $design\n\n";

# -----------------------------
# Helper to run a step
# -----------------------------
sub run_step {
    my ($desc, $cmd) = @_;
    print ">> $desc\n";
    system($cmd);
    if ($? != 0) {
        die "ERROR: $desc failed. Aborting flow.\n";
    }
    print ">> $desc completed\n\n";
}

# -----------------------------
# Step 1: Simulation
# -----------------------------
run_step(
    "Simulation (xvlog/xelab/xsim)",
    "perl flows/run_sim.pl $design"
);

# -----------------------------
# Step 2: Activity Extraction
# -----------------------------
run_step(
    "VCD Activity Extraction",
    "perl flows/extract_activity.pl $design"
);

# -----------------------------
# Step 3: Power Proxy Estimation
# -----------------------------
run_step(
    "Power Proxy Estimation",
    "perl flows/power_proxy.pl $design"
);

# -----------------------------
# Step 4: Regression
# -----------------------------
run_step(
    "Regression Analysis",
    "perl flows/regression.pl $design"
);

# -----------------------------
# Summary
# -----------------------------
print "=== FLOW COMPLETED SUCCESSFULLY ===\n";
print "Design : $design\n";
print "Check reports/ directory for results\n";
