use strict;
use warnings;
use utf8;

use Test::More;
use Benchmark qw/cmpthese timethese/;

use Hash::Compact;
use Hash::Compact::Lite;

my %case = (
    small => +{
        benchmark_count => 100000,
        dict => +{
            foo => 'a',
            bar => 'b',
            baz => 'c',
        },
        data => +{
            foo => 'bar',
            bar => 'baz',
            baz => 'foo',
        },
    },
    medium => +{
        benchmark_count => 10000,
        dict => +{
            map {
                sprintf('key_%d', $_) => "m$_"
            } (1 .. 100),
        },
        data => +{
            map {
                sprintf('key_%d', $_) => sprintf('data_%d', $_),
            } (1 .. 100),
        },
    },
    large => +{
        benchmark_count => 1000,
        dict => +{
            map {
                sprintf('key_%d', $_) => "l$_"
            } (1 .. 10000),
        },
        data => +{
            map {
                sprintf('key_%d', $_) => sprintf('data_%d', $_),
            } (1 .. 10000),
        },
    },
);

sub run {
    my ($msg, $code) = @_;
    my $title = '-' x 30 . " $msg " . '-' x 30;
    print $title, "\n";
    subtest "$msg" => $code;
    print '-' x length($title), "\n";
}

plan tests => scalar keys %case;
for my $size (keys %case) {
    run "size:$size" => sub {
        my $data            = $case{$size}->{data};
        my $dict            = $case{$size}->{dict};
        my $benchmark_count = $case{$size}->{benchmark_count};
        my $hash_compact_dict = +{ map { $_ => +{ alias_for => $dict->{$_} } } keys %$dict };

        is_deeply(Hash::Compact->new($data, $hash_compact_dict)->compact, hash_compact($data, $dict)->{data}, 'data');
        cmpthese timethese $benchmark_count => +{
            'Hash::Compact' => sub {
                Hash::Compact->new($data, $hash_compact_dict)->compact;
            },
            'Hash::Compact::Lite' => sub {
                hash_compact($data, $dict)->{data};
            },
        };
    };
}

__END__
1..3
------------------------------ size:large ------------------------------
    ok 1 - data
Benchmark: timing 1000 iterations of Hash::Compact, Hash::Compact::Lite...
Hash::Compact: 62 wallclock secs (57.13 usr +  0.02 sys = 57.15 CPU) @ 17.50/s (n=1000)
Hash::Compact::Lite: 27 wallclock secs (24.54 usr +  0.00 sys = 24.54 CPU) @ 40.75/s (n=1000)
                      Rate       Hash::Compact Hash::Compact::Lite
Hash::Compact       17.5/s                  --                -57%
Hash::Compact::Lite 40.7/s                133%                  --
    1..1
ok 1 - size:large
------------------------------------------------------------------------
------------------------------ size:small ------------------------------
    ok 1 - data
Benchmark: timing 100000 iterations of Hash::Compact, Hash::Compact::Lite...
Hash::Compact:  3 wallclock secs ( 2.22 usr +  0.00 sys =  2.22 CPU) @ 45045.05/s (n=100000)
Hash::Compact::Lite:  1 wallclock secs ( 1.03 usr +  0.00 sys =  1.03 CPU) @ 97087.38/s (n=100000)
                       Rate       Hash::Compact Hash::Compact::Lite
Hash::Compact       45045/s                  --                -54%
Hash::Compact::Lite 97087/s                116%                  --
    1..1
ok 2 - size:small
------------------------------------------------------------------------
------------------------------ size:medium ------------------------------
    ok 1 - data
Benchmark: timing 10000 iterations of Hash::Compact, Hash::Compact::Lite...
Hash::Compact:  5 wallclock secs ( 5.02 usr +  0.00 sys =  5.02 CPU) @ 1992.03/s (n=10000)
Hash::Compact::Lite:  2 wallclock secs ( 1.52 usr +  0.00 sys =  1.52 CPU) @ 6578.95/s (n=10000)
                      Rate       Hash::Compact Hash::Compact::Lite
Hash::Compact       1992/s                  --                -70%
Hash::Compact::Lite 6579/s                230%                  --
    1..1
ok 3 - size:medium
-------------------------------------------------------------------------
