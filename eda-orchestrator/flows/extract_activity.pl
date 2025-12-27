#!/usr/bin/perl
use strict;
use warnings;
use YAML::XS 'LoadFile';
use File::Path qw(make_path);

# -----------------------------
# Args
# -----------------------------
my $design = shift @ARGV
    or die "Usage: perl flows/extract_activity.pl <design>\n";

# -----------------------------
# Load config
# -----------------------------
my $cfg = LoadFile("config/flow.yaml");
my $vcd_file = $cfg->{designs}{$design}{vcd};

die "VCD file not found: $vcd_file\n"
    unless -f $vcd_file;

# -----------------------------
# Output paths
# -----------------------------
my $csv_dir = $cfg->{reports}{csv_path};
make_path($csv_dir) unless -d $csv_dir;

my $out_csv = "$csv_dir/${design}_activity.csv";

# -----------------------------
# VCD parsing state
# -----------------------------
my %symbol_to_signal;
my %prev_value;
my %toggle_count;

open my $vcd, "<", $vcd_file or die "Cannot open $vcd_file\n";

my $in_header = 1;

while (my $line = <$vcd>) {
    chomp $line;

    # -------------------------
    # Header parsing
    # -------------------------
    if ($in_header) {
        if ($line =~ /^\$var\s+\w+\s+(\d+)\s+(\S+)\s+(\S+)\s+\$end/) {
            my ($width, $symbol, $signal) = ($1, $2, $3);

            # Strip hierarchy: alu_tb.dut.a → a
            $signal =~ s/^.*\.//;

            $symbol_to_signal{$symbol} = $signal;
            $prev_value{$symbol} = undef;
            $toggle_count{$signal} = 0;
        }
        if ($line =~ /^\$enddefinitions/) {
            $in_header = 0;
        }
        next;
    }

    # -------------------------
    # Vector value change
    # -------------------------
    if ($line =~ /^b([01]+)\s+(\S+)/) {
        my ($val, $sym) = ($1, $2);
        next unless exists $symbol_to_signal{$sym};

        if (defined $prev_value{$sym}) {
            my $prev = $prev_value{$sym};
            my $toggles = 0;

            for (my $i = 0; $i < length($val); $i++) {
                my $c1 = substr($prev, $i, 1);
                my $c2 = substr($val,  $i, 1);
                $toggles++ if ($c1 ne $c2);
            }

            $toggle_count{$symbol_to_signal{$sym}} += $toggles;
        }

        $prev_value{$sym} = $val;
    }

    # -------------------------
    # Scalar value change
    # -------------------------
    elsif ($line =~ /^([01])(\S+)/) {
        my ($val, $sym) = ($1, $2);
        next unless exists $symbol_to_signal{$sym};

        if (defined $prev_value{$sym}) {
            $toggle_count{$symbol_to_signal{$sym}}++
                if $prev_value{$sym} ne $val;
        }

        $prev_value{$sym} = $val;
    }
}

close $vcd;

# -----------------------------
# Write CSV
# -----------------------------
open my $out, ">", $out_csv or die "Cannot write $out_csv\n";
print $out "signal,toggles\n";

my $total_toggles = 0;
for my $sig (sort keys %toggle_count) {
    print $out "$sig,$toggle_count{$sig}\n";
    $total_toggles += $toggle_count{$sig};
}

print $out "TOTAL,$total_toggles\n";
close $out;

print "Activity extraction completed for $design\n";
print "Total toggles: $total_toggles\n";
