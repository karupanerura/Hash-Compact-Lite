use strict;
use warnings;
use utf8;

use Test::More;

use Hash::Compact::Lite qw/hash_compact hash_uncompact/;

my $data = +{
    entries => [
        map {
            +{
                id   => $_,
                name => "name_$_",
                word => $_,
            },
        } 1 .. 100
    ],
};
my $dict = +{
    id   => 'a',
    name => 'b',
    word => 'c',
    aaa  => 'd',
};

my $deep_data = +{
    aaa => 'bbb',
    ccc => [qw/ddd eee/],
    fff => +{
        fff => 'ggg',
        hhh => 'iii'
    },
    jjj => +{
        aaa => 'bbb',
        ccc => 'ddd',
        eee => 'fff',
    },
};

my $compressed_deep_data = +{
    d   => 'bbb',
    ccc => [qw/ddd eee/],
    fff => +{
        fff => 'ggg',
        hhh => 'iii'
    },
    jjj => +{
        d   => 'bbb',
        ccc => 'ddd',
        eee => 'fff',
    },
};

is_deeply hash_uncompact(hash_compact($data, $dict)), $data;
is_deeply hash_compact($deep_data, $dict)->{data},    $compressed_deep_data;

done_testing;

