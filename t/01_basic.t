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

is_deeply hash_uncompact(hash_compact($data)),       $data;
is_deeply hash_uncompact(hash_compact($deep_data)), $deep_data;

done_testing;

