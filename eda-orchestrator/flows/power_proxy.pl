#!/usr/bin/perl
use strict;
use warnings;
use YAML::XS 'LoadFile';
use File::Path qw(make_path);

# -----------------------------
# Args
# -----------------------------
my $design = shift @ARGV
    or die "Usage: perl flows/power_proxy.pl <design>\n";

# -----------------------------
# Load config
# -----------------------------
my $cfg = LoadFile("config/flow.yaml");

my $csv_dir    = $cfg->{reports}{csv_path};
my $bit_weight = $cfg->{power}{bit_weight};

my $in_csv  = "$csv_dir/${design}_activity.csv";
my $out_csv = "$csv_dir/${design}_power.csv";

die "Activity CSV not found: $in_csv\n"
    unless -f $in_csv;

# -----------------------------
# Read activity CSV
# -----------------------------
open my $in, "<", $in_csv or die "Cannot open $in_csv\n";

my $header = <$in>;  # skip header

my %signal_power;
my $total_power = 0;

while (my $line = <$in>) {
    chomp $line;

    my ($signal, $toggles) = split /,/, $line;
    next if $signal eq "TOTAL";

    my $power = $toggles * $bit_weight;
    $signal_power{$signal} = $power;
    $total_power += $power;
}

close $in;

# -----------------------------
# Write power CSV
# -----------------------------
open my $out, ">", $out_csv or die "Cannot write $out_csv\n";
print $out "signal,power_proxy\n";

for my $sig (sort keys %signal_power) {
    print $out "$sig,$signal_power{$sig}\n";
}

print $out "TOTAL,$total_power\n";
close $out;

print "Power proxy estimation completed for $design\n";
print "Total power proxy: $total_power\n";
