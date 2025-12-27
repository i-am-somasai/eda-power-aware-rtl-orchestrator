#!/usr/bin/perl
use strict;
use warnings;
use YAML::XS 'LoadFile';
use File::Copy qw(copy);

# -----------------------------
# Args
# -----------------------------
my $design = shift @ARGV
    or die "Usage: perl flows/regression.pl <design>\n";

# -----------------------------
# Load config
# -----------------------------
my $cfg = LoadFile("config/flow.yaml");

my $csv_dir   = $cfg->{reports}{csv_path};
my $threshold = $cfg->{power}{regression_threshold_percent};

my $curr_csv  = "$csv_dir/${design}_power.csv";
my $base_csv  = "$csv_dir/${design}_power_baseline.csv";
my $out_csv   = "$csv_dir/${design}_regression.csv";

die "Current power CSV not found\n" unless -f $curr_csv;

# -----------------------------
# Read TOTAL power from CSV
# -----------------------------
sub read_total_power {
    my ($file) = @_;
    open my $fh, "<", $file or die "Cannot open $file\n";
    while (my $line = <$fh>) {
        chomp $line;
        my ($sig, $val) = split /,/, $line;
        if ($sig eq "TOTAL") {
            close $fh;
            return $val;
        }
    }
    close $fh;
    die "TOTAL not found in $file\n";
}

my $curr_power = read_total_power($curr_csv);

# -----------------------------
# Baseline handling
# -----------------------------
if (!-f $base_csv) {
    copy($curr_csv, $base_csv)
        or die "Failed to create baseline\n";

    open my $out, ">", $out_csv or die "Cannot write $out_csv\n";
    print $out "status,message\n";
    print $out "BASELINE_CREATED,No previous baseline found\n";
    close $out;

    print "Baseline created for $design\n";
    exit 0;
}

my $base_power = read_total_power($base_csv);

# -----------------------------
# Regression calculation
# -----------------------------
my $delta = $curr_power - $base_power;
my $pct   = ($delta / $base_power) * 100;

my $status = "PASS";
my $msg    = "Power change within limits";

if ($pct > $threshold) {
    $status = "FAIL";
    $msg    = sprintf("Power increased by %.2f%%", $pct);
}

# -----------------------------
# Write regression CSV
# -----------------------------
open my $out, ">", $out_csv or die "Cannot write $out_csv\n";
print $out "baseline_power,current_power,delta,delta_percent,status,message\n";
printf $out "%d,%d,%d,%.2f,%s,%s\n",
    $base_power, $curr_power, $delta, $pct, $status, $msg;
close $out;

# -----------------------------
# Console summary
# -----------------------------
print "Regression completed for $design\n";
print "Baseline power : $base_power\n";
print "Current power  : $curr_power\n";
printf "Delta          : %.2f%%\n", $pct;
print "Status         : $status\n";
